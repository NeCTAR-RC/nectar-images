$ErrorActionPreference = "Stop"
# The progress bar makes Invoke-WebRequest very slow on Windows PowerShell
$ProgressPreference = "SilentlyContinue"
$resourcesDir = $env:TEMP

# Pinned: fileexecutils.py is patched below, so upgrade deliberately
Write-Host "Downloading Cloudbase-Init..."
$cloudbaseInitMsiUrl = "https://github.com/cloudbase/cloudbase-init/releases/download/1.1.8/CloudbaseInitSetup_1_1_8_x64.msi"
$cloudbaseInitMsiSha256 = "0e7fa42e0cbc0ce7657f85730b0c6cc7afc4087a3639df0ff51a721a0be19bd5"
$cloudbaseInitMsiPath = "$resourcesDir\CloudbaseInit.msi"
Invoke-WebRequest $cloudbaseInitMsiUrl -OutFile $cloudbaseInitMsiPath
if ((Get-FileHash $cloudbaseInitMsiPath -Algorithm SHA256).Hash -ne $cloudbaseInitMsiSha256) {
    throw "Cloudbase-Init MSI checksum mismatch: $cloudbaseInitMsiUrl"
}

Write-Host "Installing Cloudbase-Init..."
$cloudbaseInitInstallDir = Join-Path $ENV:ProgramFiles "Cloudbase Solutions\Cloudbase-Init"
$cloudbaseInitMsiPath = "$resourcesDir\CloudbaseInit.msi"
$cloudbaseInitMsiLog = "$resourcesDir\CloudbaseInit.log"
$cloudbaseInitConfigPath = "$cloudbaseInitInstallDir\conf\cloudbase-init.conf"
$cloudbaseInitUnattendedConfigPath = "$cloudbaseInitInstallDir\conf\cloudbase-init-unattend.conf"

$msiexecArgumentList = "/i $cloudbaseInitMsiPath /qn /l*v $cloudbaseInitMsiLog LOGGINGSERIALPORTNAME=COM1"

$cloudbaseInitUser = 'cloudbase-init'
if ($runCloudbaseInitUnderLocalSystem) {
    $msiexecArgumentList += " RUN_SERVICE_AS_LOCAL_SYSTEM=1"
    $cloudbaseInitUser = "LocalSystem"
}

$p = Start-Process -Wait -PassThru -FilePath msiexec -ArgumentList $msiexecArgumentList
if ($p.ExitCode -ne 0) {
    Write-Host "Failed to install cloudbase-init"
    throw "Installing $cloudbaseInitMsiPath failed. Log: $cloudbaseInitMsiLog"
}

# cloudbase-init logs script output as raw bytes, escaping the newlines on the
# console. Decode it so each line shows on its own. Cosmetic, so only warn if
# a new cloudbase-init release changes the code.
$fileExecUtils = "$cloudbaseInitInstallDir\Python\Lib\site-packages\cloudbaseinit\plugins\common\fileexecutils.py"
$src = Get-Content -Raw -ErrorAction SilentlyContinue $fileExecUtils
$patched = "$src".Replace("'User_data stdout:\n%s', out)", "'User_data stdout:\n%s', out.decode(errors='replace'))").Replace("'User_data stderr:\n%s', err)", "'User_data stderr:\n%s', err.decode(errors='replace'))")
if ($src -and $patched -ne $src) {
    Set-Content -Path $fileExecUtils -Value $patched -Encoding Ascii -NoNewline
} else {
    Write-Host "WARNING: could not patch $fileExecUtils; script output will stay escaped"
}

# The cloudbase-init config is mostly duplicated, so common lines are here
$commonContent = @"
[DEFAULT]
username=Administrator
groups=Administrators
inject_user_password=true
bsdtar_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\bsdtar.exe
mtools_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\
verbose=false
debug=false
log_dir=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\
default_log_levels=comtypes=INFO,suds=INFO,iso8601=WARN,requests=WARN,cloudbaseinit.plugins.common.fileexecutils=DEBUG
netbios_host_name_compatibility=false
logging_serial_port_settings=COM1,115200,N,8
mtu_use_dhcp_config=true
ntp_use_dhcp_config=true
local_scripts_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\LocalScripts\
check_latest_version=false
metadata_services=cloudbaseinit.metadata.services.configdrive.ConfigDriveService,cloudbaseinit.metadata.services.httpservice.HttpService
"@

# Config specifically for the cloudbase-init.conf file
$confContent = @"
log_file=cloudbase-init.log
plugins=cloudbaseinit.plugins.windows.ntpclient.NTPClientPlugin,cloudbaseinit.plugins.windows.createuser.CreateUserPlugin,cloudbaseinit.plugins.common.sshpublickeys.SetUserSSHPublicKeysPlugin,cloudbaseinit.plugins.common.userdata.UserDataPlugin,cloudbaseinit.plugins.common.setuserpassword.SetUserPasswordPlugin,cloudbaseinit.plugins.common.localscripts.LocalScriptsPlugin
"@

# Config specifically for the cloudbase-init-unattend.conf file
# SetHostNamePlugin runs here (not in the main config) so the rename is applied
# during the specialize pass. With allow_reboot=false the change is left pending
# and committed by the specialize->OOBE reboot that happens anyway, avoiding an
# extra reboot. This requires the Nova instance name to match the desired hostname.
$unattendContent = @"
log_file=cloudbase-init-unattended.log
allow_reboot=false
plugins=cloudbaseinit.plugins.common.mtu.MTUPlugin,cloudbaseinit.plugins.windows.extendvolumes.ExtendVolumesPlugin,cloudbaseinit.plugins.common.sethostname.SetHostNamePlugin
stop_service_on_exit=false
"@

Write-Host "Creating new Cloudbase-Init config file ..."
Set-Content -Path $cloudbaseInitConfigPath -Value ($commonContent+ "`n" + $confContent)
#Get-Content $cloudbaseInitConfigPath

Write-Host "Creating new Cloudbase-Init unattended config file ..."
Set-Content -Path $cloudbaseInitUnattendedConfigPath -Value ($commonContent+ "`n" + $unattendContent)
#Get-Content $cloudbaseInitUnattendedConfigPath

Write-Host "Cloudbase-Init service set to start using SetupComplete"
& "${cloudbaseInitInstallDir}\bin\SetSetupComplete.cmd"

# Boot scripts directory: provision.cmd runs every *.ps1 here on each boot.
# Created here so the file provisioner has somewhere to upload the base scripts.
Write-Host "Creating Nectar boot scripts directory ..."
New-Item -ItemType Directory -Force -Path "C:\ProgramData\Nectar\scripts" | Out-Null

# Shared helpers dot-sourced by the boot scripts. Log writes a timestamped line
# to stdout (captured to the serial console by cloudbase-init's fileexecutils
# logger) and appends to provision.log. Lives outside the scripts dir so the
# runner doesn't execute it.
Write-Host "Writing Nectar script library ..."
$libPs1 = @'
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = "Continue"

function Log ($m) {
    $msg = "$(Get-Date -Format o): $m"
    Write-Host $msg
    $msg | Out-File -Append -FilePath "$env:ProgramData\Nectar\provision.log"
}

# Fetch a metadata URL with retries. Returns the body as a string, or $null
# on failure. A 404 is authoritative (key not set) and is never retried.
function Get-Metadata ($Uri, $Retries = 3, $DelaySec = 5) {
    for ($i = 1; $i -le $Retries; $i++) {
        try {
            $r = Invoke-WebRequest -Uri $Uri -UseBasicParsing -ErrorAction Stop
            return $r.Content
        } catch {
            if ($_.Exception.Response -and [int]$_.Exception.Response.StatusCode -eq 404) {
                Log "Metadata not found (404): $Uri"
                return $null
            }
            Log "Metadata fetch failed (attempt $i/${Retries}): $($_.Exception.Message)"
            if ($i -lt $Retries) { Start-Sleep -Seconds $DelaySec }
        }
    }
    return $null
}
'@
Set-Content -Path "C:\ProgramData\Nectar\lib.ps1" -Value $libPs1 -Encoding Ascii

# LocalScript runner: cloudbase-init runs this every boot. It runs every *.ps1
# in the scripts dir (in name order) and exits 1002 so the LocalScripts plugin
# re-runs on the next boot. stdout is captured by the fileexecutils logger.
Write-Host "Writing provision.cmd LocalScript ..."
New-Item -ItemType Directory -Force -Path "$cloudbaseInitInstallDir\LocalScripts" | Out-Null
$provisionCmd = @'
@echo off
set SCRIPTS=C:\ProgramData\Nectar\scripts
if exist "%SCRIPTS%" (
  for /f "delims=" %%f in ('dir /b /on "%SCRIPTS%\*.ps1" 2^>nul') do (
    echo Running %%f
    powershell.exe -ExecutionPolicy Unrestricted -File "%SCRIPTS%\%%f"
  )
)
exit 1002
'@
Set-Content -Path "$cloudbaseInitInstallDir\LocalScripts\provision.cmd" -Value $provisionCmd -Encoding Ascii

Write-Host "Cloudbase-Init installed successfully under user ${cloudbaseInitUser}"
