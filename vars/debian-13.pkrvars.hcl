os_name        = "debian"
os_version     = "13"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/debian-cd/current/amd64/iso-cd/debian-13.7.0-amd64-netinst.iso"
iso_checksum   = "sha256:a7ef94ac2fb9a7fec454552abd629b7cc9d5155c886165a45649f5ce6167e355"
boot_command   = ["<wait><esc><wait>auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian-13-preseed.cfg net.ifnames=0<enter>"]
profile        = "standard"
