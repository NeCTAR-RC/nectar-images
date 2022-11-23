openstack security group create image-build
openstack security group rule create --proto icmp image-build
openstack security group rule create --proto tcp --dst-port 22 image-build
