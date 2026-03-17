os_name        = "almalinux"
os_version     = "10"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/almalinux/10/isos/x86_64/AlmaLinux-10.1-x86_64-boot.iso"
iso_checksum   = "sha256:68a9e14fa252c817d11a3c80306e5a21b2db37c21173fd3f52a9eb6ced25a4a0"
boot_command   = ["<up>e<down><down><end> text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/almalinux-10-kickstart.cfg net.ifnames=0<wait><f10><wait>"]
profile        = "standard"
