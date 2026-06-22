os_name        = "debian"
os_version     = "12"
os_arch        = "x86_64"
iso_url        = "https://cdimage.debian.org/mirror/cdimage/archive/12.14.0/amd64/iso-cd/debian-12.14.0-amd64-netinst.iso"
iso_checksum   = "sha256:adfcbb50782af99d457467f9b38c9e0fb3b1b6e211e0202f099aa58874b3f923"
boot_command   = ["<wait><esc><wait>auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian-12-preseed.cfg net.ifnames=0<enter>"]
profile        = "standard"
