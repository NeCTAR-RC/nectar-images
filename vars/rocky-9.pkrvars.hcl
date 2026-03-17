os_name        = "rocky"
os_version     = "9"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/rocky/9/isos/x86_64/Rocky-9.7-x86_64-boot.iso"
iso_checksum   = "sha256:3b5c87b2f9e62fdf0235d424d64c677906096965aad8a580e0e98fcb9f97f267"
boot_command   = ["<tab><bs><bs><bs><bs><bs> text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/rocky-9-kickstart.cfg net.ifnames=0<enter><wait>"]
profile        = "standard"
