. "$env:ProgramData\Nectar\lib.ps1"

Log "Setting network connection profile to 'Public'..."
Set-NetConnectionProfile -Name "Network" -NetworkCategory Public
