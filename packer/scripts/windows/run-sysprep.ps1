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

# Edge gets registered as an Appx package for a single user during the build
# but is not provisioned for all users, which makes sysprep /generalize fail
# validation ("installed for a user, but not provisioned for all users",
# 0x80073cf2). Remove the per-user registration; Edge itself stays installed.
Write-Host 'Removing per-user Microsoft Edge Appx registration (blocks sysprep generalize)...'
Get-AppxPackage -AllUsers Microsoft.MicrosoftEdge* | Remove-AppxPackage -AllUsers

Write-Host 'Running Sysprep...'
$unattendedXmlPath = "c:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\Unattend.xml"
# Invoke Sysprep natively rather than via Start-Process -ArgumentList. With
# Start-Process the quotes land inside the /unattend: token and Sysprep's own
# parser splits the path at the spaces ("Malformed command line detected; no
# dash or slash present in option"), then sits on its error dialog. PowerShell
# quotes the whole argument when invoking natively, which Sysprep accepts.
# Sysprep is a GUI program, so this call returns straight away.
c:\windows\system32\sysprep\Sysprep /generalize /oobe /quit /unattend:"$unattendedXmlPath"

# Poll the Setup State key until Windows reports the reseal. A successful run
# takes a minute or two. A failed Sysprep never gets there: it sits on its
# error dialog instead, so cap the wait, then dump the Sysprep logs to the
# packer output and fail the build.
$stateKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State'
$targetState = 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE'
$timeoutMinutes = 10
$deadline = (Get-Date).AddMinutes($timeoutMinutes)
Write-Host "Waiting up to $timeoutMinutes minutes for Sysprep to reseal the image..."
do {
    Start-Sleep -Seconds 10
    $imageState = (Get-ItemProperty $stateKey).ImageState
} until ($imageState -eq $targetState -or (Get-Date) -ge $deadline)

if ($imageState -ne $targetState) {
    Write-Host "ERROR: Sysprep did not reseal the image within $timeoutMinutes minutes (ImageState=$imageState)"
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
