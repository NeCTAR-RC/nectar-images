os_name        = "almalinux"
os_version     = "9"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/almalinux/9/isos/x86_64/AlmaLinux-9.4-x86_64-boot.iso"
iso_checksum   = "sha256:1e5d7da3d84d5d9a5a1177858a5df21b868390bfccf7f0f419b1e59acc293160"
boot_command   = ["<wait><wait><up><wait><tab> inst.text net.ifnames=0 inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/almalinux-9-kickstart.cfg<enter><wait>"]
profile        = "standard"

