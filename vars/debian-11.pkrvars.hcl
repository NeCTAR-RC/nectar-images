os_name        = "debian"
os_version     = "11"
os_arch        = "x86_64"
iso_url        = "https://cdimage.debian.org/mirror/cdimage/archive/11.10.0/amd64/iso-cd/debian-11.10.0-amd64-netinst.iso"
iso_checksum   = "file:https://cdimage.debian.org/mirror/cdimage/archive/11.10.0/amd64/iso-cd/SHA256SUMS"
boot_command   = ["<wait><esc><wait>auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian-11-preseed.cfg net.ifnames=0<enter>"]
profile        = "standard"
