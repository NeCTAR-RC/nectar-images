

# See existing vendor images
openstack image list --property owner=28eadf5ad64b42a4929b2fb7df99275c | grep vendor

# Upload a new vendor image
openstack image create --os-image-api-version=1 --disk-format qcow2 --container-format bare --file file.img vendor-image-nnn-x86_64_vendor



Ubuntu vendor images:
http://cloud-images.ubuntu.com/

For example, xenial-server-cloudimg-amd64-disk1.img 

Debian vendor images:
http://cdimage.debian.org/cdimage/openstack/
For example, debian-8.7.2-20170301-openstack-amd64.qcow2 

CentOS vendor images:
http://cloud.centos.org/centos/7/images/

Fedora vendor images:
https://mirror.aarnet.edu.au/pub/fedora/linux/releases/25/CloudImages/x86_64/images/

openSUSE vendor images (bad, don't contain cloud-init):
http://download.opensuse.org/repositories/Cloud:/Images:
