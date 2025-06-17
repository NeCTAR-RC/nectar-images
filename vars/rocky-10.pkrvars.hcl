os_name        = "rocky"
os_version     = "10"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/rocky/10/isos/x86_64/Rocky-10.0-x86_64-boot.iso"
iso_checksum   = "sha256:2bb073606d8d83cbd3c0e25c5e6cd8e5c60c0e989e6e84f0c415c05e163640d3"
boot_command   = ["<up>e<down><down><end> text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/rocky-10-kickstart.cfg net.ifnames=0<wait><f10><wait>"]
#boot_command   = ["<wait10><wait10><wait10><wait10><wait10><wait10><wait10><wait10><wait10>"]
profile        = "standard"
