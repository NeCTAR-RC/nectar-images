os_name        = "debian"
os_version     = "13"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/debian-cd/current/amd64/iso-cd/debian-13.5.0-amd64-netinst.iso"
iso_checksum   = "sha256:95838884f5ea6c82421dfe6baaa5a639dbbe6756c1e380f9fe7a7cb0c1949d2a"
boot_command   = ["<wait><esc><wait>auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian-13-preseed.cfg net.ifnames=0<enter>"]
profile        = "standard"
