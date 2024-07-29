os_name        = "fedora"
os_version     = "40"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/fedora/linux/releases/40/Server/x86_64/iso/Fedora-Server-netinst-x86_64-40-1.14.iso"
iso_checksum   = "sha256:1b4f163c55aa9b35bb08f3d465534aa68899a4984b8ba8976b1e7b28297b61fe"
boot_command   = ["<wait><up>e<wait><down><down><end> inst.text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/fedora-40-kickstart.cfg net.ifnames=0<F10><wait>"]
profile        = "standard"
