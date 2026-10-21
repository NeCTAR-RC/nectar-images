os_name        = "rocky"
os_version     = "9"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/rocky/9/isos/x86_64/Rocky-9-latest-x86_64-boot.iso"
iso_checksum   = "file:http://mirror.aarnet.edu.au/pub/rocky/9/isos/x86_64/CHECKSUM"
boot_command   = ["<tab><bs><bs><bs><bs><bs> text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/rocky-9-kickstart.cfg net.ifnames=0<enter><wait>"]
profile        = "standard"
