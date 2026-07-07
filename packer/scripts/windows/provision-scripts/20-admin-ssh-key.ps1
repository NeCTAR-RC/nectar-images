. "$env:ProgramData\Nectar\lib.ps1"

# Set the administrator group ssh key in case someone defaults the ssh config
Log "Applying Admin SSH key..."
$keyData = Get-Metadata "http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key"
if ($keyData) {
    Out-File -FilePath C:\ProgramData\ssh\administrators_authorized_keys -InputObject $keyData -Encoding ascii
    Log "Admin SSH key applied"
} else {
    Log "SKIP: No SSH public key set for this instance"
}
