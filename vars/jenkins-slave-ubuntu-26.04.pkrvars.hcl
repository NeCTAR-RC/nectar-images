build_name      = "jenkins-slave-ubuntu-26.04"
os_name         = "ubuntu"
os_version      = "26.04"
os_arch         = "x86_64"
disk_size       = 30
iso_url         = "https://cloud-images.ubuntu.com/releases/resolute/release/ubuntu-26.04-server-cloudimg-amd64.img"
iso_checksum    = "file:https://cloud-images.ubuntu.com/releases/resolute/release/SHA256SUMS"
qemu_disk_image = true
cloud_init_dir  = "ubuntu-26.04"
profile         = "jenkins-slave"
profile_args    = ["nectar_image_name='Jenkins Slave (Ubuntu 26.04)'"]
