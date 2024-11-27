$ErrorActionPreference = "Stop"

# Enable SSH
Write-Host "Enabling OpenSSH..."
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
Set-Service -Name ssh-agent -StartupType 'Automatic'

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
