build_name     = "jenkins-slave-ubuntu-22.04"
os_name        = "ubuntu"
os_version     = "22.04"
os_arch        = "x86_64"
disk_size      = "30G"
iso_url        = "http://mirror.aarnet.edu.au/pub/ubuntu/releases/22.04/ubuntu-22.04.5-live-server-amd64.iso"
iso_checksum   = "sha256:9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
boot_command   = ["c<wait>linux /casper/vmlinuz autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu-22.04/ net.ifnames=0<enter><wait5>initrd /casper/initrd<enter><wait10>boot<enter>"]
profile        = "jenkins-slave"
profile_args   = ["nectar_image_name='Jenkins Slave (Ubuntu 22.04)'"]
