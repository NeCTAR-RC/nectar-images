os_name        = "fedora"
os_version     = "39"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/fedora/linux/releases/39/Server/x86_64/iso/Fedora-Server-netinst-x86_64-39-1.5.iso"
iso_checksum   = "sha256:61576ae7170e35210f03aae3102048f0a9e0df7868ac726908669b4ef9cc22e9"
boot_command   = ["<wait><up>e<wait><down><down><end> inst.text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/fedora-39-kickstart.cfg net.ifnames=0<F10><wait>"]
profile        = "standard"
