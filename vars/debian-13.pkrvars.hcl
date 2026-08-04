os_name        = "debian"
os_version     = "13"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/debian-cd/current/amd64/iso-cd/debian-13.6.0-amd64-netinst.iso"
iso_checksum   = "sha256:65273beed27b2df543b68b65630ba525cfbad8df2b12035732b2dff87d6664e7"
boot_command   = ["<wait><esc><wait>auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian-13-preseed.cfg net.ifnames=0<enter>"]
profile        = "standard"
