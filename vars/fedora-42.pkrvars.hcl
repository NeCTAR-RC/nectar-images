os_name        = "fedora"
os_version     = "42"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/fedora/linux/releases/42/Server/x86_64/iso/Fedora-Server-netinst-x86_64-42-1.1.iso"
iso_checksum   = "sha256:231f3e0d1dc8f565c01a9f641b3d16c49cae44530074bc2047fe2373a721c82f"
boot_command   = ["<wait><up>e<wait><down><down><end> inst.text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/fedora-41-kickstart.cfg net.ifnames=0<F10><wait>"]
profile        = "standard"
