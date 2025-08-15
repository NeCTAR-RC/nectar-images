os_name        = "debian"
os_version     = "13"
os_arch        = "x86_64"
iso_url        = "https://mirror.aarnet.edu.au/pub/debian-cd/current/amd64/iso-cd/debian-13.0.0-amd64-netinst.iso"
iso_checksum   = "sha256:e363cae0f1f22ed73363d0bde50b4ca582cb2816185cf6eac28e93d9bb9e1504"
boot_command   = ["<wait><esc><wait>auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian-13-preseed.cfg net.ifnames=0<enter>"]
profile        = "standard"
