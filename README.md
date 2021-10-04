NeCTAR Images
=============

This repository contains the scripts used for building the official images
used by the NeCTAR Research Cloud.

We use Ansible to provision images, which are build using Packer and the
QEMU/KVM provider from ISO with kickstart/preseed.

Building an Image
----

Edit one of the image definitions, such as `ubuntu-20.04.json`. Update the
`builders.name` and `builders.vm_name` fields in particular.

Make sure you have `packer` installed and then run:

```
packer build /path/to/image-definition.json
```

The image will be put in a directory with a name like `output-${IMAGE_NAME}`.
It can now be uploaded with glance.


Testing
-------

A Vagrant file is present which is useful for testing the Ansible roles
are working correctly.

Run `vagrant status` in the top level directory for a list of available
virtual machine profiles you can test.

To launch a test Vagrant instance, use the following command:
```
vagrant up --no-destroy-on-error <name>
```

The Vagrant config prefers the `libvirt` backend, which is ideal for Linux
machines but you'll need to set it up yourself and support non-root access.
The `virtualbox` provider is also enabled if you'd prefer to use that.

You can set the provider manually on the command line using the `provder`
argument. For example:

```
vagrant up --provider virtualbox
```
