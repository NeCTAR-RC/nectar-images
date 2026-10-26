# Disable winrm at next boot
#Set-Service WinRM -StartupType Disabled -PassThru
#Write-host "Disabling WinRM..."
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WinRM" -Name "Start" -Value 4
#$result = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WinRM" -Name "Start"
#Write-host $result

# Write a script to run async after sysprep, as packer is often unable
# to shutdown the computer, and the build user cannot be deleted until
# after the last packer command has been sent. Also, WinRM must now be removed.
$finish = @'
# Final cleanup and shutdown after sysprep.

Start-Sleep -Seconds 6

# Remove vagrant user and clean up home directory
Remove-LocalUser -Name "vagrant"
Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath -like "*\vagrant" } | Remove-CimInstance

Get-ChildItem -Path C:\Windows\Temp -Include *.* -File -Recurse | foreach { $_.Delete()}
Set-Item WSMan:\localhost\Service\Auth\Basic -Value False
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value False
winrm delete winrm/config/listener?address=*+transport=HTTP
Set-NetFirewallRule -DisplayName 'Windows Remote Management (HTTP-In)' -Enabled False -PassThru | Select -Property DisplayName, Profile, Enabled
Remove-NetFirewallRule -DisplayName "WINRM-HTTP-In-TCP"
Remove-NetFirewallRule -DisplayName "Port 5985"
Disable-PSRemoting -Force

# Enable Administrator account
Get-LocalUser -Name "Administrator" | Enable-LocalUser

shutdown /s /t 5 /f /d p:4:1 /c "packer shutdown"
'@
$finish | Out-File c:\windows\finish.ps1

Write-Host 'Running Sysprep...'
$unattendedXmlPath = "c:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\Unattend.xml"
# Invoke Sysprep natively rather than via Start-Process -ArgumentList. With
# Start-Process the quotes land inside the /unattend: token and Sysprep's own
# parser splits the path at the spaces ("Malformed command line detected; no
# dash or slash present in option"), then sits on its error dialog. PowerShell
# quotes the whole argument when invoking natively, which Sysprep accepts.
# Sysprep is a GUI program, so this call returns straight away.
c:\windows\system32\sysprep\Sysprep /generalize /oobe /quit /unattend:"$unattendedXmlPath"
Start-Sleep -Seconds 5
$sysprep = Get-Process -Name sysprep -ErrorAction SilentlyContinue | Select-Object -First 1

# Wait for sysprep to reseal the image. Sysprep returns before the generalize
# pass completes, so poll the Setup State key until Windows reports the reseal.
# The wait is bounded: if Sysprep fails it either exits early without
# resealing or sits on an error dialog forever, and the old unbounded loop
# turned that into a build that never finished. On timeout, dump the sysprep
# logs to the packer output and fail the build.
$stateKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State'
$targetState = 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE'
$timeoutMinutes = 30
$deadline = (Get-Date).AddMinutes($timeoutMinutes)
$resealed = $false
$polls = 0
while ((Get-Date) -lt $deadline) {
    $imageState = (Get-ItemProperty $stateKey).ImageState
    if ($imageState -eq $targetState) {
        $resealed = $true
        break
    }
    if ($sysprep -and $sysprep.HasExited) {
        # Sysprep exited without reaching the reseal state. Give the registry
        # a moment to catch up and check once more before calling it a failure.
        Start-Sleep -Seconds 10
        $imageState = (Get-ItemProperty $stateKey).ImageState
        $resealed = ($imageState -eq $targetState)
        break
    }
    if (($polls % 6) -eq 0) {
        Write-Host "Waiting for Sysprep to reseal the image (ImageState=$imageState)..."
    }
    $polls++
    Start-Sleep -Seconds 10
}

if (-not $resealed) {
    $imageState = (Get-ItemProperty $stateKey).ImageState
    $exitCode = if (-not $sysprep) { 'process not found' } elseif ($sysprep.HasExited) { $sysprep.ExitCode } else { 'still running' }
    Write-Host "ERROR: Sysprep did not reseal the image after up to $timeoutMinutes minutes (ImageState=$imageState, Sysprep exit code: $exitCode)"
    # A failed Sysprep stays up on its error dialog and blocks any further
    # Sysprep run, including packer's provisioner retry, so stop it.
    if ($sysprep -and -not $sysprep.HasExited) {
        Stop-Process -Id $sysprep.Id -Force -ErrorAction SilentlyContinue
    }
    foreach ($log in 'setuperr.log', 'setupact.log') {
        $path = "C:\Windows\System32\Sysprep\Panther\$log"
        Write-Host "===== $path (last 100 lines) ====="
        if (Test-Path $path) {
            Get-Content $path -Tail 100
        } else {
            Write-Host '(file not found)'
        }
    }
    exit 1
}
Write-Host "Sysprep finished (ImageState=$imageState)"

# Spawn final cleanup script
Start-Process -FilePath "powershell" -ArgumentList "c:\windows\finish.ps1"
