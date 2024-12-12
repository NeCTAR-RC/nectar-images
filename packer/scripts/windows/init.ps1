#ps1_sysnative

$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = "Continue"

function Custom-Log ($m) {
    $msg = "$(Get-Date -Format o): $m"
    Write-Host "$msg"
    $msg | Out-File -Append -FilePath "$env:ProgramData\Nectar\init.log"
    # Log to instance console log via serial port if we can
    try {
        $port = new-Object System.IO.Ports.SerialPort COM1,9600,None,8,one
        $port.open()
        $port.WriteLine($msg)
        $port.Close()
    }
    catch {
        Write-Host "Can't log to console: $_"
    }
}

Custom-Log "================================================"
Custom-Log "     Starting Nectar Windows provisioning...    "
Custom-Log "================================================"

Custom-Log "Setting network connection profile to 'Public'..."
Set-NetConnectionProfile -Name "Network" -NetworkCategory Public

# Set the administrator group ssh key in case someone defaults the ssh config
Custom-Log "Applying Admin SSH key..."
$keyData = Invoke-WebRequest -Uri http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key -UseBasicParsing
out-file -FilePath C:\ProgramData\ssh\administrators_authorized_keys -InputObject $keyData.Content -Encoding ascii

Custom-Log "Fetching Vendordata..."
$vendorData = Invoke-WebRequest -Uri http://169.254.169.254/openstack/latest/vendor_data2.json -UseBasicParsing | ConvertFrom-Json

# This must be written in strict ASCII format with no headers ie not utf8bom
Custom-Log "Applying NVIDIA VGPU license token..."
$Folder = 'C:\Program Files\NVIDIA Corporation\vGPU Licensing\ClientConfigToken'
if (Test-Path -Path $Folder) {
    $nvidiaToken = $vendorData.nectar.nvidia_vgpu.license_token | %{[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_))}
    if ([string]::IsNullOrEmpty($nvidiaToken)) {
        Custom-Log "ERROR: License token not found!"
    } else {
        $trunc = $nvidiaToken.SubString(0, 6)
        Custom-Log "Found token starting with: $trunc"
        out-file -FilePath "C:\Program Files\NVIDIA Corporation\vGPU Licensing\ClientConfigToken\license_token.tok" -InputObject $nvidiaToken -Encoding ascii -NoNewLine
    }
} else {
    Custom-Log "SKIP: NVIDIA VGPU Driver not installed"
}

# Create VGPU driver install shortcut if device found...
$videoController = Get-CimInstance Win32_VideoController
if ($videoController.PNPDeviceID -like 'PCI\VEN_10DE*') {
    Custom-Log "NVIDIA VGPU device found!"
    Custom-Log "Creating driver install shortcut..."
    $WshShell = New-Object -comObject WScript.Shell
    $DesktopPath = "C:\Users\Administrator\Desktop"
    $ShortCutPath = Join-Path -Path $DesktopPath -ChildPath 'NVIDIA VGPU Driver Installer.lnk'
    $Shortcut = $WshShell.CreateShortcut($ShortCutPath)
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-ExecutionPolicy Bypass -File C:\ProgramData\Nectar\nvidia_vgpu_driver_install.ps1"
    $Shortcut.WorkingDirectory = "C:\ProgramData\Nectar"
    $Shortcut.Description = "NVIDIA VGPU Driver Installer"
    $Shortcut.IconLocation = "powershell.exe,0"  # Uses default PowerShell icon
    $Shortcut.Save()
    Custom-Log "Shortcut created!"
} else {
    Custom-Log "SKIP: NVIDIA VGPU Device not found"
}

Custom-Log "Checking Windows license status..."
$ActivationStatus = Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $_.PartialProductKey } | Select-Object LicenseStatus
$LicenseResult = switch($ActivationStatus.LicenseStatus){
    0 {"Unlicensed"}
    1 {"Licensed"}
    2 {"OOBGrace"}
    3 {"OOTGrace"}
    4 {"NonGenuineGrace"}
    5 {"Not Activated"}
    6 {"ExtendedGrace"}
    default {"unknown"}
}

if ($ActivationStatus.LicenseStatus -eq 1) {
    Custom-Log "Windows license has already been activated!"
} else {
    Custom-Log "Windows not yet activated. Current status is: $LicenseResult"

    $productKey = $vendorData.nectar.windows_product_key.product_key
    if ([string]::IsNullOrEmpty($productKey)) {
        Custom-Log "ERROR: Product key not found in metadata!"
    } else {
        $trunc = $productKey.SubString(0,5)
        Custom-Log "Activating with product key: $trunc"
        C:\Windows\System32\cscript.exe C:\Windows\System32\slmgr.vbs /ipk $productKey
        C:\Windows\System32\cscript.exe C:\Windows\System32\slmgr.vbs /ato
    }
}

Custom-Log "================================================"
Custom-Log "      Nectar Windows provisioning complete!     "
Custom-Log "================================================"
