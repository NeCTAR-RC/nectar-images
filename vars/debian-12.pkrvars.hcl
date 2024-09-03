os_name        = "debian"
os_version     = "12"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/debian-cd/current/amd64/iso-cd/debian-12.7.0-amd64-netinst.iso"
iso_checksum   = "sha256:8fde79cfc6b20a696200fc5c15219cf6d721e8feb367e9e0e33a79d1cb68fa83"
boot_command   = ["<wait><esc><wait>auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian-12-preseed.cfg net.ifnames=0<enter>"]
profile        = "standard"
