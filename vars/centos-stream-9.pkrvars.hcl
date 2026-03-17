os_name        = "centos-stream"
os_version     = "9"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/centos-stream/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-20260316.0-x86_64-boot.iso"
iso_checksum   = "sha256:29f80f9211b0d13d331312a6db0aa1bcbc8be01949c8633faccc327084bb15b3"
boot_command   = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos-stream-9-kickstart.cfg<enter><wait>"]
profile        = "standard"
