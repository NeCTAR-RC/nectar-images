os_name        = "rocky"
os_version     = "9"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/rocky/9/isos/x86_64/Rocky-9.6-x86_64-boot.iso"
iso_checksum   = "sha256:0fad8d8b19a94a0222ea37152cdf5601229fe0178b651dc476e1cba41d2e6067"
boot_command   = ["<tab><bs><bs><bs><bs><bs> text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/rocky-9-kickstart.cfg net.ifnames=0<enter><wait>"]
profile        = "standard"
