os_name        = "almalinux"
os_version     = "8"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/almalinux/8/isos/x86_64/AlmaLinux-8.10-x86_64-boot.iso"
iso_checksum   = "sha256:cc3e61faf2dd6c9c80d3beeb47eaaba235ac13fe1b617209c3c1e546528ccb99"
boot_command   = ["<wait><up><wait><tab> inst.text net.ifnames=0 inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/almalinux-8-kickstart.cfg<enter><wait>"]
profile        = "standard"
