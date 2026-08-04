os_name        = "debian"
os_version     = "12"
os_arch        = "x86_64"
iso_url        = "https://cdimage.debian.org/mirror/cdimage/archive/12.15.0/amd64/iso-cd/debian-12.15.0-amd64-netinst.iso"
iso_checksum   = "sha256:cd4462c06aa8892e692c0c4b9c17802f38c8ab8690e85cbfb5ccaa5956e9af17"
boot_command   = ["<wait><esc><wait>auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian-12-preseed.cfg net.ifnames=0<enter>"]
profile        = "standard"
