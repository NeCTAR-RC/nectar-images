os_name        = "rocky"
os_version     = "8"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/rocky/8.10/isos/x86_64/Rocky-8.10-x86_64-minimal.iso"
iso_checksum   = "file:http://mirror.aarnet.edu.au/pub/rocky/8.10/isos/x86_64/Rocky-8.10-x86_64-minimal.iso.CHECKSUM"
boot_command   = ["<wait><up><wait><tab> inst.text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/rocky-8-kickstart.cfg net.ifnames=0<enter><wait>"]
profile        = "standard"
