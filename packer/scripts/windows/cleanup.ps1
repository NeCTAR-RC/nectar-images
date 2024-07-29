Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

trap {
    Write-Host
    Write-Host "ERROR: $_"
    ($_.ScriptStackTrace -split '\r?\n') -replace '^(.*)$','ERROR: $1' | Write-Host
    ($_.Exception.ToString() -split '\r?\n') -replace '^(.*)$','ERROR EXCEPTION: $1' | Write-Host
    Write-Host
    Write-Host 'Sleeping for 60m to give you time to look around the virtual machine before self-destruction...'
    Start-Sleep -Seconds (60*60)
    Exit 1
}

Write-Host 'Clean all of the event logs'
@(
    'Application',
    'Security',
    'Setup',
    'System'
) | ForEach-Object {
    wevtutil clear-log $_
}

Write-Host "Cleaning Temp Files..."
try {
  Takeown /d Y /R /f "C:\Windows\Temp\*"
  Icacls "C:\Windows\Temp\*" /GRANT:r administrators:F /T /c /q  2>&1
  Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
} catch { }

#
# remove temporary files.
# NB we ignore the packer generated files so it won't complain in the output.

Write-Host 'Stopping services that might interfere with temporary file removal...'
function Stop-ServiceForReal($name) {
    while ($true) {
        Stop-Service -ErrorAction SilentlyContinue $name
        if ((Get-Service $name).Status -eq 'Stopped') {
            break
        }
    }
}
Stop-ServiceForReal TrustedInstaller   # Windows Modules Installer
Stop-ServiceForReal wuauserv           # Windows Update
Stop-ServiceForReal BITS               # Background Intelligent Transfer Service
@(
"$env:LOCALAPPDATA\Temp\*"
"$env:windir\Temp\*"
"$env:windir\Logs\*"
"$env:windir\Panther\*"
"$env:windir\WinSxS\ManifestCache\*"
"$env:windir\SoftwareDistribution\Download"
"C:\Users\vagrant\Favorites\*"
) | Where-Object {Test-Path $_} | ForEach-Object {
    Write-Host "Removing temporary files $_..."
    try {
        takeown.exe /D Y /R /F $_ | Out-Null
        icacls.exe $_ /grant:r Administrators:F /T /C /Q 2>&1 | Out-Null
    } catch {
        Write-Host "Ignoring taking ownership of temporary files error: $_"
    }
    try {
        Remove-Item $_ -Exclude 'packer-*' -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    } catch {
        Write-Host "Ignoring failure to remove files error: $_"
    }
}

#
# cleanup the WinSxS folder.

# NB even thou the automatic maintenance includes a component cleanup task,
#    it will not clean everything, as such, dism will clean the rest.
# NB to analyse the used space use: dism.exe /Online /Cleanup-Image /AnalyzeComponentStore
# see https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/clean-up-the-winsxs-folder
Write-Host 'Cleaning up the WinSxS folder...'
dism.exe /Online /Quiet /Cleanup-Image /StartComponentCleanup /ResetBase
if ($LASTEXITCODE) {
    throw "Failed with Exit Code $LASTEXITCODE"
}

# NB even after cleaning up the WinSxS folder the "Backups and Disabled Features"
#    field of the analysis report will display a non-zero number because the
#    disabled features packages are still on disk. you can remove them with:

# \/ Some features are impossible to enable unless you have an updated windows image mounted

#Get-WindowsOptionalFeature -Online | Where-Object {$_.State -eq 'Disabled'} | ForEach-Object {
#    Write-Host "Removing feature $($_.FeatureName)..."
#    dism.exe /Online /Quiet /Disable-Feature "/FeatureName:$($_.FeatureName)" /Remove
#}
#    NB a removed feature can still be installed from other sources (e.g. windows update).
Write-Host 'Analyzing the WinSxS folder...'
dism.exe /Online /Cleanup-Image /AnalyzeComponentStore

Write-Host 'Remove pagefile, it will get created on boot next time.'
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name PagingFiles -Value '' -Force
