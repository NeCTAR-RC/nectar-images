os_name        = "rocky"
os_version     = "8"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/rocky/8/isos/x86_64/Rocky-8.10-x86_64-boot.iso"
iso_checksum   = "sha256:5987b4b0bdbb3189e91248353d45e0bf37f05747b0ba746664a2d1e8e7936ed7"
boot_command   = ["<wait><up><wait><tab> inst.text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/rocky-8-kickstart.cfg net.ifnames=0<enter><wait>"]
profile        = "standard"
