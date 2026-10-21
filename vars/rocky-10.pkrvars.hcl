os_name        = "rocky"
os_version     = "10"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/rocky/10/isos/x86_64/Rocky-10-latest-x86_64-boot.iso"
iso_checksum   = "file:http://mirror.aarnet.edu.au/pub/rocky/10/isos/x86_64/CHECKSUM"
boot_command   = ["<up>e<down><down><end> text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/rocky-10-kickstart.cfg net.ifnames=0<wait><f10><wait>"]
profile        = "standard"
