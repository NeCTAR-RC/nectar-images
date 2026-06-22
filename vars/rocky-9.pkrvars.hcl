os_name        = "rocky"
os_version     = "9"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/rocky/9/isos/x86_64/Rocky-9.8-x86_64-boot.iso"
iso_checksum   = "sha256:d6eeefdc8437c593d41a3150fcca4a734c55642ed472eecdda99720bb1370881"
boot_command   = ["<tab><bs><bs><bs><bs><bs> text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/rocky-9-kickstart.cfg net.ifnames=0<enter><wait>"]
profile        = "standard"
