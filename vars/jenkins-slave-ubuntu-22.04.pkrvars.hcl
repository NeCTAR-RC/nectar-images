build_name     = "jenkins-slave-ubuntu-22.04"
os_name        = "ubuntu"
os_version     = "22.04"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/ubuntu/releases/22.04/ubuntu-22.04.4-live-server-amd64.iso"
iso_checksum   = "file:http://mirror.aarnet.edu.au/pub/ubuntu/releases/22.04/SHA256SUMS"
boot_command   = ["<wait>c<wait>set gfxpayload=keep<enter><wait>linux /casper/vmlinuz quiet autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu-22.04/ ---<enter><wait>initrd /casper/initrd<wait><enter><wait>boot<enter><wait>"]
profile        = "jenkins-slave"
