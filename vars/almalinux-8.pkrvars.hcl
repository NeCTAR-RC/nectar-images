os_name        = "almalinux"
os_version     = "8"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/almalinux/8/isos/x86_64/AlmaLinux-8-latest-x86_64-boot.iso"
iso_checksum   = "file:http://mirror.aarnet.edu.au/pub/almalinux/8/isos/x86_64/CHECKSUM"
boot_command   = ["<wait><up><wait><tab> inst.text net.ifnames=0 inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/almalinux-8-kickstart.cfg<enter><wait>"]
profile        = "standard"
