os_name        = "almalinux"
os_version     = "9"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/almalinux/9/isos/x86_64/AlmaLinux-9.7-x86_64-boot.iso"
iso_checksum   = "sha256:494d09f608b325ef42899b5ce38ba1b17755a639f5558b9b98a031b0696e694a"
boot_command   = ["<wait><wait><up><wait><tab> inst.text net.ifnames=0 inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/almalinux-9-kickstart.cfg<enter><wait>"]
profile        = "standard"
