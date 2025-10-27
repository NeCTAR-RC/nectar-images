os_name        = "ubuntu"
os_version     = "24.04"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/ubuntu/releases/24.04/ubuntu-24.04.3-live-server-amd64.iso"
iso_checksum   = "sha256:c3514bf0056180d09376462a7a1b4f213c1d6e8ea67fae5c25099c6fd3d8274b"
boot_command   = ["<wait>e<wait><down><down><down><end> net.ifnames=0 autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu-24.04<wait><f10><wait>"]
profile        = "standard"
