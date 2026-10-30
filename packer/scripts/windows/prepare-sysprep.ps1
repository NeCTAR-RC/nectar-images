# Prepare the image for Sysprep. Sysprep itself runs from packer's
# shutdown_command (C:\Windows\packer-sysprep.ps1, written below), not from
# here. Once Sysprep has generalized the image, WinRM can no longer open a new
# shell: loading the build user's profile fails with "The device is not ready"
# (0x80070015), and packer's WinRM client always asks for a profile. So packer
# must not need WinRM after generalize. Sysprep /shutdown powers the VM off,
# which is all packer waits for.

# Edge gets registered as an Appx package for a single user during the build
# but is not provisioned for all users, which makes sysprep /generalize fail
# validation ("installed for a user, but not provisioned for all users",
# 0x80073cf2). Remove the per-user registration; Edge itself stays installed.
Write-Host 'Removing per-user Microsoft Edge Appx registration (blocks sysprep generalize)...'
Get-AppxPackage -AllUsers Microsoft.MicrosoftEdge* | Remove-AppxPackage -AllUsers

# First-boot cleanup. The build user and the WinRM setup cannot be removed
# before Sysprep, as packer still uses them to send the shutdown command, so
# SetupComplete.cmd runs this once on the instance's first boot instead.
$firstBoot = @'
# Final cleanup of the packer build, run once from SetupComplete.cmd on the
# instance's first boot, before cloudbase-init starts.

# Remove vagrant user and clean up home directory
Remove-LocalUser -Name "vagrant"
Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath -like "*\vagrant" } | Remove-CimInstance

Get-ChildItem -Path C:\Windows\Temp -Include *.* -File -Recurse | foreach { $_.Delete()}

# packer-sysprep.ps1 left WinRM disabled so the build user could not be reached
# over WinRM before this script ran. The WSMan settings below need the service.
Set-Service -Name WinRM -StartupType Automatic
Start-Service -Name WinRM
Set-Item WSMan:\localhost\Service\Auth\Basic -Value False
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value False
winrm delete winrm/config/listener?address=*+transport=HTTP
Set-NetFirewallRule -DisplayName 'Windows Remote Management (HTTP-In)' -Enabled False -PassThru | Select -Property DisplayName, Profile, Enabled
Remove-NetFirewallRule -DisplayName "WINRM-HTTP-In-TCP"
Remove-NetFirewallRule -DisplayName "Port 5985"
Disable-PSRemoting -Force

# Enable Administrator account
Get-LocalUser -Name "Administrator" | Enable-LocalUser

Remove-Item -Force C:\Windows\packer-sysprep.ps1
Remove-Item -Force $PSCommandPath
'@
$firstBootPath = "$env:SystemRoot\Setup\Scripts\nectar-first-boot.ps1"
$firstBoot | Out-File $firstBootPath

# SetupComplete.cmd already starts cloudbase-init (written by its
# SetSetupComplete.cmd). Run the cleanup first, so the build user is gone and
# Administrator is enabled before cloudbase-init sets its password.
$setupComplete = "$env:SystemRoot\Setup\Scripts\SetupComplete.cmd"
$existing = if (Test-Path $setupComplete) { @(Get-Content $setupComplete) } else { @() }
$runFirstBoot = 'powershell -NoProfile -ExecutionPolicy Bypass -File "%SystemRoot%\Setup\Scripts\nectar-first-boot.ps1"'
Set-Content -Path $setupComplete -Value (@($runFirstBoot) + $existing) -Encoding Ascii
Write-Host "SetupComplete.cmd:"
Get-Content $setupComplete

# Run by packer's shutdown_command over WinRM, while profiles still load.
$sysprep = @'
# Keep WinRM off on the instance's first boot until nectar-first-boot.ps1 has
# removed the build user. Changing the start type leaves this session running.
Set-Service -Name WinRM -StartupType Disabled

# Invoke Sysprep natively rather than via Start-Process -ArgumentList. With
# Start-Process the quotes land inside the /unattend: token and Sysprep's own
# parser splits the path at the spaces ("Malformed command line detected; no
# dash or slash present in option"), then sits on its error dialog. PowerShell
# quotes the whole argument when invoking natively, which Sysprep accepts.
# Sysprep is a GUI program, so this call returns straight away and Sysprep
# powers the VM off when it has finished.
$unattendedXmlPath = "c:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\Unattend.xml"
c:\windows\system32\sysprep\Sysprep /generalize /oobe /shutdown /unattend:"$unattendedXmlPath"
'@
$sysprep | Out-File C:\Windows\packer-sysprep.ps1
Write-Host 'Sysprep will run from the packer shutdown command (C:\Windows\packer-sysprep.ps1)'
