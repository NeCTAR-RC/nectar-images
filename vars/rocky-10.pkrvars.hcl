os_name        = "rocky"
os_version     = "10"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/rocky/10/isos/x86_64/Rocky-10.1-x86_64-boot.iso"
iso_checksum   = "sha256:18543988d9a1a5632d142c3dc288136dcc48ab71628f92ebcd40ada7f4ecd110"
boot_command   = ["<up>e<down><down><end> text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/rocky-10-kickstart.cfg net.ifnames=0<wait><f10><wait>"]
profile        = "standard"
