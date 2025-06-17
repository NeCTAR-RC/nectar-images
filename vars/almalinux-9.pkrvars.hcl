os_name        = "almalinux"
os_version     = "9"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/almalinux/9/isos/x86_64/AlmaLinux-9.6-x86_64-boot.iso"
iso_checksum   = "sha256:113521ec7f28aa4ab71ba4e5896719da69a0cc46cf341c4ebbd215877214f661"
boot_command   = ["<wait><wait><up><wait><tab> inst.text net.ifnames=0 inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/almalinux-9-kickstart.cfg<enter><wait>"]
profile        = "standard"

