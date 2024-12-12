locals {

  build_name = var.build_name == null ? "${var.os_name}-${var.os_version}" : var.build_name

  output_directory = abspath("${path.cwd}/builds/build_files/packer-${local.build_name}")

  # qemu
  qemuargs = var.qemuargs == null ? (
    var.qemu_efi_boot == true && var.is_windows ? [
      ["-drive", "if=pflash,format=raw,readonly=on,file=${var.qemu_efi_firmware_code}"],
      ["-drive", "if=pflash,format=raw,file=${path.cwd}/builds/build_files/efivars.fd"],
      ["-drive", "file=${path.cwd}/builds/build_files/virtio-win.iso,media=cdrom,index=3"],
      ["-drive", "file=${var.iso_url},media=cdrom,index=2"],
      ["-drive", "file=${local.output_directory}/{{ .Name }},if=virtio,cache=writeback,discard=ignore,format=${var.qemu_format},index=1"],
      ] : (
      var.is_windows ? [
        ["-drive", "file=${path.cwd}/builds/build_files/virtio-win.iso,media=cdrom,index=3"],
        ["-drive", "file=${var.iso_url},media=cdrom,index=2"],
        ["-drive", "file=${local.output_directory}/{{ .Name }},if=virtio,cache=writeback,discard=ignore,format=${var.qemu_format},index=1"],
      ] : [
        [ "-cpu", "host" ],  # Rocky 9 at least needs x86-64-v2 support
      ]
    )
  ) : var.qemuargs

  # Source block common
  boot_wait = var.boot_wait == null ? "-1s" : var.boot_wait

  communicator = var.communicator == null ? (
    var.is_windows ? "winrm" : "ssh"
  ) : var.communicator

  floppy_files = var.floppy_files == null ? (
    var.is_windows ? [
      "${path.root}/win_answer_files/${var.os_version}/Autounattend.xml"
    ] : null
  ) : var.floppy_files

  http_directory = var.http_directory == null ? "${path.root}/http" : var.http_directory

  security_groups = var.security_group != null ? [var.security_group] : null

  shutdown_command = var.shutdown_command == null ? (
    var.is_windows ? "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\"" : "shutdown -P now"
  ) : var.shutdown_command


  # Use packer ssh key on Linux
  ssh_private_key_file = var.ssh_private_key_file == null ? (
      var.is_windows ? null : "${path.root}/packer-ssh-key"
  ) : var.ssh_private_key_file

  # This is not working yet. Packer bug?
  #source_image_filter = var.source_image != null ? (
  #  { "filters": {
  #      "name": var.source_image,
  #      "visibility": "public"
  #    },
  #    "most_recent": true
  #  }
  #): null
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "qemu" "vm" {
  # QEMU specific options
  disk_image           = var.qemu_disk_image
  disk_compression     = true
  efi_boot             = var.qemu_efi_boot
  efi_firmware_code    = var.qemu_efi_firmware_code
  efi_firmware_vars    = var.qemu_efi_firmware_vars
  efi_drop_efivars     = var.qemu_efi_drop_efivars
  format               = var.qemu_format
  qemuargs             = local.qemuargs
  boot_command         = var.boot_command
  boot_wait            = local.boot_wait
  cpus                 = var.cpus
  communicator         = local.communicator
  disk_size            = var.disk_size
  floppy_files         = local.floppy_files
  headless             = var.headless
  http_directory       = local.http_directory
  iso_checksum         = var.iso_checksum
  iso_url              = var.iso_url
  memory               = var.memory
  net_device           = var.qemu_net_device
  output_directory     = local.output_directory
  shutdown_command     = local.shutdown_command
  shutdown_timeout     = var.shutdown_timeout
  ssh_password         = var.ssh_password
  ssh_port             = var.ssh_port
  ssh_private_key_file = local.ssh_private_key_file
  ssh_timeout          = var.ssh_timeout
  ssh_username         = var.ssh_username
  winrm_password       = var.winrm_password
  winrm_timeout        = var.winrm_timeout
  winrm_username       = var.winrm_username
  vm_name              = local.build_name
  vnc_bind_address     = var.vnc_bind_address
}

source "openstack" "vm" {
  availability_zone    = var.availability_zone
  flavor               = var.flavor
  image_name           = local.build_name
  security_groups      = local.security_groups
  source_image_name    = var.source_image_name
  ssh_username         = var.ssh_username
}
