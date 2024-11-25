os_name        = "rocky"
os_version     = "8"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/rocky/8/isos/x86_64/Rocky-8.10-x86_64-boot.iso"
iso_checksum   = "sha256:203744a255ea6579e49ca7f7f0f17e2fda94e50945d8183a254490e454c7c5b4"
boot_command   = ["<wait><up><wait><tab> inst.text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/rocky-8-kickstart.cfg net.ifnames=0<enter><wait>"]
profile        = "standard"
