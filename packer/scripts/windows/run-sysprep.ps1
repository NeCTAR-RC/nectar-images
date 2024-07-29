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
##############################################
#
# Final cleanup and shutdown after sysprep.
#
##############################################

Start-Sleep -Seconds 6
Remove-LocalUser -Name "vagrant"
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

## Change ownership and remove bcd processing in the sysprep run
## This is necessary when the drive was converted to GPT
#$ACL = Get-Acl -Path "C:\windows\system32\sysprep\ActionFiles\Generalize.xml"
#$User = New-Object System.Security.Principal.Ntaccount("Administrator")
#$ACL.SetOwner($User)
#$ACL | Set-Acl -Path "C:\windows\system32\sysprep\ActionFiles\Generalize.xml"
#cacls.exe "C:\windows\system32\sysprep\ActionFiles\Generalize.xml" /E /G Administrator:F
## We can now remove the module from the sysprep run...
#Set-Content -Path "C:\windows\system32\sysprep\ActionFiles\Generalize.xml" -Value (get-content -Path "C:\windows\system32\sysprep\ActionFiles\Generalize.xml" | Select-String -Pattern 'spbcd.dll' -NotMatch)
#$result = Get-ACL -Path "C:\windows\system32\sysprep\ActionFiles\Generalize.xml"
#Write-Host $result

Write-Host 'Running Sysprep...'
$unattendedXmlPath = "c:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\Unattend.xml"
c:\windows\system32\sysprep\Sysprep /generalize /oobe /quit /unattend:"$unattendedXmlPath"

# Give sysprep time to finish
Start-Sleep -Seconds 120

#$content = get-content "C:\windows\system32\sysprep\Panther\setupact.log"
#write-host $content
#write-host "Error log file:"
#$content = get-content "C:\windows\system32\sysprep\Panther\setuperr.log"
#write-host $content

# Spawn final cleanup script
Start-Process -FilePath "powershell" -ArgumentList "c:\windows\finish.ps1"
