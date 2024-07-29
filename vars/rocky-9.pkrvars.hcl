os_name        = "rocky"
os_version     = "9"
os_arch        = "x86_64"
iso_url        = "https://mirror.aarnet.edu.au/pub/rocky/9.4/isos/x86_64/Rocky-9.4-x86_64-minimal.iso"
iso_checksum   = "file:https://mirror.aarnet.edu.au/pub/rocky/9.4/isos/x86_64/Rocky-9.4-x86_64-minimal.iso.CHECKSUM"
boot_command   = ["<tab><bs><bs><bs><bs><bs> text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/rocky-9-kickstart.cfg net.ifnames=0<enter><wait>"]
profile        = "standard"
