NeCTAR Images
=============

This repository contains the scripts used for building the official images
used by the NeCTAR Research Cloud.

We use Ansible to provision images, which are build using Packer with either
the OpenStack builder (newer) or QEMU/KVM from ISO with kickstart/preseed
(older).

For the OpenStack builder, we require a base image to build upon. Most
distribiutions now supply OpenStack or generic cloud images. Once the
base image has been uploaded into Glance, the image ID is then inserted
into the Packer config for that build.

For the distro's that don't have a cloud image, we continue to use the ISO
method.

Testing
-------

A Vagrant file is present which is useful for testing the Ansible roles
are working correctly. These are based on the default Virtualbox backend,
but could be made to work with others.

Run `vagrant status` in the top level directory for a list of available
virtual machine profiles you can test.


Downloading vendor images
-------------------------

Ubuntu vendor images can be found at:
http://cloud-images.ubuntu.com/
For example, xenial-server-cloudimg-amd64-disk1.img

Debian vendor images can be found at:
http://cdimage.debian.org/cdimage/openstack/
For example, debian-8.7.2-20170301-openstack-amd64.qcow2

CentOS vendor images are found at:
http://cloud.centos.org/centos/7/images/

Fedora vendor images are found at:
https://mirror.aarnet.edu.au/pub/fedora/linux/releases/25/CloudImages/x86_64/images/

openSUSE vendor images can be found at:
http://download.opensuse.org/repositories/Cloud:/Images:
These can't be used unfortunately, as they don't contain cloud-init, so boot
up with no SSH keys installed from the metadata.

Image commands
--------------

With the image building credentials for the production cloud loaded in your
environment:

List existing vendor images
`openstack image list --property owner=28eadf5ad64b42a4929b2fb7df99275c | grep vendor`

Upload a new vendor image
`openstack image create --disk-format qcow2 --container-format bare --file file.img vendor-image-nnn-x86_64_vendor`
