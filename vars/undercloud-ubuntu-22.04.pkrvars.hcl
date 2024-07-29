build_name     = "undercloud-ubuntu-22.04"
os_name        = "ubuntu"
os_version     = "22.04"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/ubuntu/releases/22.04/ubuntu-22.04.4-live-server-amd64.iso"
iso_checksum   = "sha256:45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2"
boot_command   = ["c<wait>linux /casper/vmlinuz autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu-22.04/ net.ifnames=0<enter><wait5>initrd /casper/initrd<enter><wait10>boot<enter>"]
profile        = "undercloud"
