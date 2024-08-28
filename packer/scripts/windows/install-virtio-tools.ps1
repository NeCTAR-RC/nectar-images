$ErrorActionPreference = 'Stop'

#Write-Host 'Installing the VirtIO guest tools...'
#$guestToolsPath = "E:\virtio-win-guest-tools.exe"
#$guestToolsLog = "C:\windows\temp\guesttools.log"
#&$guestToolsPath /install /norestart /quiet /log $guestToolsLog | Out-String -Stream
#if ($LASTEXITCODE) {
#    throw "failed to install guest tools with exit code $LASTEXITCODE"
#}

Write-Host 'Installing the VirtIO drivers...'
$guestToolsPath = "E:\virtio-win-gt-x64.msi.exe"
$guestToolsLog = "C:\windows\temp\guesttools.log"
Start-Process -Wait -PassThru msiexec -ArgumentList "/i $guestToolsPath /log $guestToolsLog /qn /passive /norestart ADDLOCAL=ALL"

Write-Host 'Installing QEMU guest agent...'
$guestAgentPath = "E:\guest-agent\qemu-ga-x86_64.msi"
Start-Process -Wait -PassThru msiexec -ArgumentList "/i $guestAgentPath /qn /passive"
