build_name     = "jenkins-slave-ubuntu-20.04"
os_name        = "ubuntu"
os_version     = "20.04"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/ubuntu/releases/20.04/ubuntu-20.04.6-live-server-amd64.iso",
iso_checksum   = "file:http://mirror.aarnet.edu.au/pub/ubuntu/releases/20.04/SHA256SUMS"
boot_command   = ["<wait><enter><wait><enter><wait><f6><wait><esc><wait> preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu-20.04-preseed.cfg net.ifnames=0<enter><wait>"]
profile        = "jenkins-slave"
