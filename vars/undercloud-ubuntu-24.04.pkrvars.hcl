build_name     = "undercloud-ubuntu-24.04"
os_name        = "ubuntu"
os_version     = "24.04"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/ubuntu/releases/24.04/ubuntu-24.04-live-server-amd64.iso"
iso_checksum   = "sha256:8762f7e74e4d64d72fceb5f70682e6b069932deedb4949c6975d0f0fe0a91be3"
boot_command   = ["<wait>e<wait><down><down><down><end> net.ifnames=0 autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu-24.04<wait><f10><wait>"]
profile        = "undercloud"
