build_name     = "undercloud-ubuntu-20.04"
os_name        = "ubuntu"
os_version     = "20.04"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/ubuntu/releases/20.04/ubuntu-20.04.6-live-server-amd64.iso"
iso_checksum   = "sha256:b8f31413336b9393ad5d8ef0282717b2ab19f007df2e9ed5196c13d8f9153c8b"
boot_command   = ["<wait><enter><wait><enter><wait><f6><wait><esc><wait> autoinstall net.ifnames=0 ds=nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu-22.04/<enter><wait>"]
profile        = "undercloud"
profile_args   = ["nectar_image_name='Undercloud Ubuntu 20.04'"]
