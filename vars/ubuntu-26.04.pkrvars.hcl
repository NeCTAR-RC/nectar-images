os_name        = "ubuntu"
os_version     = "26.04"
os_arch        = "x86_64"
#iso_url        = "http://mirror.aarnet.edu.au/pub/ubuntu/releases/26.04/ubuntu-26.04-live-server-amd64.iso"
iso_url        = "https://releases.ubuntu.com/resolute/ubuntu-26.04-live-server-amd64.iso"
iso_checksum   = "sha256:dec49008a71f6098d0bcfc822021f4d042d5f2db279e4d75bdd981304f1ca5d9"
boot_command   = ["<wait>e<wait><down><down><down><end> net.ifnames=0 autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu-26.04<wait><f10><wait>"]
profile        = "standard"
