# Trove guest image, containerised model (Victoria+).
#
# One image serves every datastore: the database runs as a docker container
# pulled at runtime, so there are no longer per-datastore variants.
build_name     = "trove"
os_name        = "ubuntu"
os_version     = "24.04"
os_arch        = "x86_64"
iso_url        = "http://mirror.aarnet.edu.au/pub/ubuntu/releases/24.04/ubuntu-24.04.3-live-server-amd64.iso"
iso_checksum   = "sha256:c3514bf0056180d09376462a7a1b4f213c1d6e8ea67fae5c25099c6fd3d8274b"
boot_command   = ["<wait>e<wait><down><down><down><end> net.ifnames=0 autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu-24.04<wait><f10><wait>"]
profile        = "trove"
profile_args   = ["nectar_image_name='Trove Guest'"]

# Keep the ubuntu guest user baked in (pinned to uid/gid 1000 by the trove role)
# rather than letting cleanup delete it. It must exist at boot: the guest agent
# runs as it, and cloud-init write_files chowns injected config to it before it
# would otherwise be recreated. Matches the upstream trovestack image.
keep_default_user = true
