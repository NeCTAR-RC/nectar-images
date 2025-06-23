os_name        = "almalinux"
os_version     = "10"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/almalinux/10/isos/x86_64/AlmaLinux-10.0-x86_64-boot.iso"
iso_checksum   = "sha256:a1549729bfb66a28e3546c953033c9928eae7280917bb1c490983dba3bb9941c"
boot_command   = ["<up>e<down><down><end> text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/almalinux-10-kickstart.cfg net.ifnames=0<wait><f10><wait>"]
profile        = "standard"

