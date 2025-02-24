build_name     = "trove-postgresql-16"
os_name        = "ubuntu"
os_version     = "20.04"
os_arch        = "x86_64"
iso_url        = "http://old-releases.ubuntu.com/releases/20.04.1/ubuntu-20.04.1-live-server-amd64.iso"
iso_checksum   = "sha256:b8f31413336b9393ad5d8ef0282717b2ab19f007df2e9ed5196c13d8f9153c8b"
boot_command   = ["<wait><enter><wait><enter><wait><f6><wait><esc><wait> autoinstall net.ifnames=0 ds=nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu-22.04/<enter><wait>"]
profile        = "trove"
profile_args   = ["datastore=mysql", "datastore_version=8.0", "nectar_image_name='Trove MySQL 8.0'"]
