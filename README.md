NeCTAR Images
=============

This repository contains the scripts used for building the OS images
used by the NeCTAR Research Cloud.

We use Ansible to provision images, which are build using Packer and the
QEMU/KVM provider from ISO with kickstart/preseed.

More comprehensive notes can be found in the Nectar Wiki at:
https://wiki.rc.nectar.org.au/wiki/ImageBuilding


Setup
-----

For local building, you will need:
* Ansible v2.16
* Packer (latest)

NOTE: This project Requires Ansible 2.16. Later versions are too old to build
Rocky/AlmaLinux 8 with it's Python 3.6


Building Images
---------------

The repository is intended for use with Jenkins, but it is possible to build
images locally.

A Makefile is included which should handle most of what you might need to do.

First, run the init command to ensure all the dependencies are resolved:
```
make init target=<image name>
```

There are some Packer plugins like QEMU, Ansible, WinRM, etc that will be
installed at this point. For Windows, this step will also download the
latest copy of the VirtIO Win ISO which is also required.

The build can then be started with:
```
make build target=<image name>
```

At the end of this process, you should have a QCOW2 image ready for uploading
to Glance.


Testing
-------

A feature of this codebase is that we do include some testing functionality.

A simple testing framework written in Bash (or PowerShell for Windows) is
deployed as part of the image build process. The specific tests deployed
depend on the functionality included, and this is logic is handled within
Ansible.

We also include some scripts which are used to initiate the tests. These
scripts are used for booting a server from a new image, waiting for it to
become ready, SSH'ing in and then running the tests.

The scripts are:
* `local-image-tests.sh`: Intended for local usage and takes the QCOW2 image
filename as an argument and will upload it to Glance
* `run-image-tests.sh`: Used as part of the Jenkins pipeline, and assumes the
image is already available in Glance.


Promoting to public
-------------------

As part of the Jenkins build pipline, after the tests have been executed
successfully, a promotion step happens.

This step set the new image to `public` visibility and if there is a match to
an older build of the same image, it will _de-promote_ it. This means the
old image will have its visibility set to `community` and be moved into the
`Nectar-Images-Archive` project.

This process is handled by the `aggrandise.py` script.


Updating ISOs
-------------

The ISOs for the OS images do seem to change frequently, and we're now trying
to keep up with the minor releases, so a helper script has been included.

Run `scripts/update-isos.sh` to resolve the latest ISO URL and checksum and
it will update the *base* vars config for that OS. Other images using that same
base OS aren't updated automatically, so you'll need to handle those yourself.
(e.g. VGPU images, Jenkins slaves, etc)


Development
-------

Developing and fixing image build issues can be a long slow process.
Because of this, we include a Vagrant file is which is useful for testing the
Ansible roles are working correctly before committing.

Run `vagrant status` in the top level directory for a list of available
virtual machine profiles you can test.

To launch a test Vagrant instance, use the following command:
```
make vagrant-init
make vagrant-up target=<image name>
```

Vagrant is currently hard-coded to use the libvirt provider, but it is possible
to use virtualbox for example, but that functionality is not currently set up.

Once you're finished with your testing, you can destroy the running VM with:
```
make vagrant-down target=<image name>
```
