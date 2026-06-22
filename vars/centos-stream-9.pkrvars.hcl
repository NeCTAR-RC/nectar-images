os_name        = "centos-stream"
os_version     = "9"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/centos-stream/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-20260615.0-x86_64-boot.iso"
iso_checksum   = "sha256:efc4101ddddab139d2dda7d805e1b6e10ecc682890d2d37209f1d1cb54e8a98c"
boot_command   = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos-stream-9-kickstart.cfg<enter><wait>"]
profile        = "standard"
