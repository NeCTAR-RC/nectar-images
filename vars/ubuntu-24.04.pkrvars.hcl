os_name        = "ubuntu"
os_version     = "24.04"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/ubuntu/releases/24.04/ubuntu-24.04.2-live-server-amd64.iso"
iso_checksum   = "sha256:d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"
boot_command   = ["<wait>e<wait><down><down><down><end> net.ifnames=0 autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu-24.04<wait><f10><wait>"]
profile        = "standard"
