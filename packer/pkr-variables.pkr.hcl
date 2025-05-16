# General variables
variable "build_name" {
  type        = string
  default     = null
  description = "Image build name"
}

variable "os_name" {
  type        = string
  description = "OS Brand Name"
}

variable "os_version" {
  type        = string
  description = "OS version number"
}

variable "os_arch" {
  type        = string
  default     = "x86_64"
  description = "OS architecture type, x86_64 or aarch64"
}

variable "is_windows" {
  type        = bool
  default     = false
  description = "Determines to set setting for Windows or Linux"
}

# qemu
variable "qemu_display" {
  type        = string
  default     = null
  description = "What QEMU -display option to use. Defaults to gtk, use none to not pass the -display option allowing QEMU to choose the default"
}

variable "qemu_use_default_display" {
  type        = bool
  default     = null
  description = "If true, do not pass a -display option to qemu, allowing it to choose the default"
}

variable "qemu_disk_image" {
  type        = bool
  default     = null
  description = "Whether iso_url is a bootable qcow2 disk image"
}

variable "qemu_efi_boot" {
  type        = bool
  default     = false
  description = "Enable EFI boot"
}

variable "qemu_efi_firmware_code" {
  type        = string
  default     = null
  description = "EFI firmware code path"
}

variable "qemu_efi_firmware_vars" {
  type        = string
  default     = null
  description = "EFI firmware vars file path"
}

variable "qemu_efi_drop_efivars" {
  type        = bool
  default     = false
  description = "Drop EFI vars"
}

variable "qemu_format" {
  type    = string
  default = "qcow2"
  validation {
    condition     = var.qemu_format == "qcow2" || var.qemu_format == "raw"
    error_message = "Disk format, takes qcow2 or raw."
  }
  description = "Disk format, takes qcow2 or raw"
}

variable "qemu_net_device" {
  type        = string
  default     = "virtio-net-pci"
}

variable "qemuargs" {
  type    = list(list(string))
  default = null
}

# Source block common variables
variable "boot_command" {
  type        = list(string)
  default     = null
  description = "Commands to pass to gui session to initiate automated install"
}

variable "boot_wait" {
  type    = string
  default = null
}

variable "cpus" {
  type    = number
  default = 2
}

variable "communicator" {
  type    = string
  default = null
}

variable "disk_size" {
  type    = string
  default = "10G"
}

variable "floppy_files" {
  type    = list(string)
  default = null
}

variable "headless" {
  type        = bool
  default     = true
  description = "Start GUI window to interact with VM"
}

variable "http_directory" {
  type    = string
  default = null
}

variable "iso_checksum" {
  type        = string
  default     = null
  description = "ISO download checksum"
}

variable "iso_url" {
  type        = string
  default     = null
  description = "ISO download url"
}

variable "memory" {
  type    = number
  default = 4096
}

variable "output_directory" {
  type    = string
  default = null
}

variable "shutdown_command" {
  type    = string
  default = null
}

variable "shutdown_timeout" {
  type    = string
  default = "15m"
}

variable "ssh_port" {
  type    = number
  default = 22
}

variable "ssh_timeout" {
  type    = string
  default = "30m"
}

variable "ssh_username" {
  type    = string
  default = "root"
}

variable "ssh_password" {
  type    = string
  default = null
}

variable "ssh_private_key_file" {
  type    = string
  default = null
}

variable "winrm_password" {
  type    = string
  default = "vagrant"
}

variable "winrm_timeout" {
  type    = string
  default = "60m"
}

variable "winrm_username" {
  type    = string
  default = "vagrant"
}

variable "vnc_bind_address" {
  type    = string
  default = "0.0.0.0"
}

# OpenStack
variable "availability_zone" {
  type    = string
  default = "ardc-syd-1"
}

variable "flavor" {
  type    = string
  default = "m3.small"
}

variable "security_group" {
  type    = string
  default = "image-build"
}

variable "source_image_name" {
  type    = string
  default = null
}

# builder common block
variable "profile" {
  type    = string
  default = null
}

variable "profile_args" {
  type    = list(string)
  default = []
}

variable "scripts" {
  type    = list(string)
  default = null
}

variable "test_build" {
  type    = bool
  default = false
}
