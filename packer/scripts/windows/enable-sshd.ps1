$ErrorActionPreference = "Stop"

# Enable SSH
Write-Host "Enabling OpenSSH..."
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
Set-Service -Name ssh-agent -StartupType 'Automatic'

# Disable single admin authorized keys
Write-Host "Updating sshd_config"
$line = Get-Content "C:\ProgramData\ssh\sshd_config" | Select-String "Match Group administrators" | Select-Object -ExpandProperty Line
$line2 = Get-Content "C:\ProgramData\ssh\sshd_config" | Select-String "AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators" | Select-Object -ExpandProperty Line
$sshconfig = Get-Content "C:\ProgramData\ssh\sshd_config"
$sshconfig | ForEach-Object {$_ -replace $line,"#Match Group administrators"} | Set-Content "C:\ProgramData\ssh\sshd_config"
$sshconfig = Get-Content "C:\ProgramData\ssh\sshd_config"
$sshconfig | ForEach-Object {$_ -replace $line2,"#       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys"} | Set-Content "C:\ProgramData\ssh\sshd_config"

# Restart Start SSH
Write-Host "Restarting SSH"
Restart-Service sshd
Write-Host "Done"

# Set bash as the default shell for SSH.
#$BashCommand = Get-Command "bash.exe"
#New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value $BashCommand.source -PropertyType String -Force

$FilePath = "C:\ProgramData\ssh\administrators_authorized_keys"
if (!(Test-Path $FilePath)) {
    New-Item -Path $FilePath -ItemType "File"
}

$acl = Get-Acl -Path $FilePath
$acl.SetAccessRuleProtection($true, $false)
$administratorsRule = New-Object system.security.accesscontrol.filesystemaccessrule("Administrators","FullControl","Allow")
$systemRule = New-Object system.security.accesscontrol.filesystemaccessrule("SYSTEM","FullControl","Allow")
$acl.SetAccessRule($administratorsRule)
$acl.SetAccessRule($systemRule)
$acl | Set-Acl
