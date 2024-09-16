os_name        = "centos-stream"
os_version     = "9"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/centos-stream/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-20240909.0-x86_64-boot.iso"
iso_checksum   = "sha256:57a1cbecf28252337b72ebbaf08694ab743dca55256f6e546384158284c72ac4"
boot_command   = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos-stream-9-kickstart.cfg<enter><wait>"]
profile        = "standard"
