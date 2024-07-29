os_name        = "debian"
os_version     = "12"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/debian-cd/current/amd64/iso-cd/debian-12.6.0-amd64-netinst.iso"
iso_checksum   = "sha256:ade3a4acc465f59ca2496344aab72455945f3277a52afc5a2cae88cdc370fa12"
boot_command   = ["<wait><esc><wait>auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian-12-preseed.cfg net.ifnames=0<enter>"]
profile        = "standard"
