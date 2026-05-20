os_name        = "centos-stream"
os_version     = "9"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/centos-stream/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-20260513.0-x86_64-boot.iso"
iso_checksum   = "sha256:7a5e54ff1a6f0692351388555bb7fc5467629cbf721c6cb60a6d723463504d5f"
boot_command   = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos-stream-9-kickstart.cfg<enter><wait>"]
profile        = "standard"
