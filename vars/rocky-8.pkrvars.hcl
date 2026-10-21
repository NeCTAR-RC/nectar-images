os_name        = "rocky"
os_version     = "8"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/rocky/8/isos/x86_64/Rocky-8-latest-x86_64-boot.iso"
iso_checksum   = "file:http://mirror.aarnet.edu.au/pub/rocky/8/isos/x86_64/CHECKSUM"
boot_command   = ["<wait><up><wait><tab> inst.text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/rocky-8-kickstart.cfg net.ifnames=0<enter><wait>"]
profile        = "standard"
