os_name        = "rocky"
os_version     = "10"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/rocky/10/isos/x86_64/Rocky-10.2-x86_64-boot.iso"
iso_checksum   = "sha256:bf3a75907948563d0c11f3d1b8546ee9216e18a3ea2dc0a67eb4c45452e210f9"
boot_command   = ["<up>e<down><down><end> text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/rocky-10-kickstart.cfg net.ifnames=0<wait><f10><wait>"]
profile        = "standard"
