build_name     = "jenkins-slave-ubuntu-22.04"
os_name        = "ubuntu"
os_version     = "22.04"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/ubuntu/releases/22.04/ubuntu-22.04.5-live-server-amd64.iso"
iso_checksum   = "sha256:9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
boot_command   = ["<wait>c<wait>set gfxpayload=keep<enter><wait>linux /casper/vmlinuz quiet autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu-22.04/ ---<enter><wait>initrd /casper/initrd<wait><enter><wait>boot<enter><wait>"]
profile        = "jenkins-slave"
