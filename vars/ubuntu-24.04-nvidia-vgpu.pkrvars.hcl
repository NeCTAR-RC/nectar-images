build_name     = "ubuntu-24.04-nvidia-vgpu"
os_name        = "ubuntu"
os_version     = "24.04"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/ubuntu/releases/24.04/ubuntu-24.04.1-live-server-amd64.iso"
iso_checksum   = "sha256:e240e4b801f7bb68c20d1356b60968ad0c33a41d00d828e74ceb3364a0317be9"
boot_command   = ["<wait>e<wait><down><down><down><end> net.ifnames=0 autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu-24.04<wait><f10><wait>"]
disk_size      = "30G"
profile        = "nvidia-vgpu"
profile_args   = ["nectar_image_name='Ubuntu 24.04 LTS (Noble) amd64 (NVIDIA vGPU)'"]
