. "$env:ProgramData\Nectar\lib.ps1"

# Set the administrator group ssh key in case someone defaults the ssh config
Log "Applying Admin SSH key..."
$keyData = Invoke-WebRequest -Uri http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key -UseBasicParsing
out-file -FilePath C:\ProgramData\ssh\administrators_authorized_keys -InputObject $keyData.Content -Encoding ascii
