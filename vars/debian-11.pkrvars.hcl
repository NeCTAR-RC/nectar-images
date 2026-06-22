os_name        = "debian"
os_version     = "11"
os_arch        = "x86_64"
iso_url        = "https://cdimage.debian.org/mirror/cdimage/archive/11.11.0/amd64/iso-cd/debian-11.11.0-amd64-netinst.iso"
iso_checksum   = "sha256:cd5b2a6fc22050affa1d141adb3857af07e94ff886dca1ce17214e2761a3b316"
boot_command   = ["<wait><esc><wait>auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian-11-preseed.cfg net.ifnames=0<enter>"]
profile        = "standard"
