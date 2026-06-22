os_name        = "almalinux"
os_version     = "10"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/almalinux/10/isos/x86_64/AlmaLinux-10.2-x86_64-boot.iso"
iso_checksum   = "sha256:b3f865468075bcada8f208d830289302c67529789d668041d24e8d6fc697ba6a"
boot_command   = ["<up>e<down><down><end> text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/almalinux-10-kickstart.cfg net.ifnames=0<wait><f10><wait>"]
profile        = "standard"
