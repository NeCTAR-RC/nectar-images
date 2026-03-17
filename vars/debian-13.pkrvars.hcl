os_name        = "debian"
os_version     = "13"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/debian-cd/current/amd64/iso-cd/debian-13.4.0-amd64-netinst.iso"
iso_checksum   = "sha256:0b813535dd76f2ea96eff908c65e8521512c92a0631fd41c95756ffd7d4896dc"
boot_command   = ["<wait><esc><wait>auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian-13-preseed.cfg net.ifnames=0<enter>"]
profile        = "standard"
