os_name        = "fedora"
os_version     = "41"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/fedora/linux/releases/41/Server/x86_64/iso/Fedora-Server-netinst-x86_64-41-1.4.iso"
iso_checksum   = "sha256:630c52ba9e7a7f229b026e241ba74b9bc105e60ba5bf7b222693ae0e25f05c97"
boot_command   = ["<wait><up>e<wait><down><down><end> inst.text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/fedora-41-kickstart.cfg net.ifnames=0<F10><wait>"]
profile        = "standard"
