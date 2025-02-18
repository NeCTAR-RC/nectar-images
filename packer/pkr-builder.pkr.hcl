packer {
  required_version = ">= 1.7.0"

  required_plugins {
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
    openstack = {
      source  = "github.com/hashicorp/openstack"
      version = ">= 1.1.2"
    }
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.0.8"
    }
    windows-update = {
      source  = "github.com/rgl/windows-update"
      version = ">= 0.14.1"
    }
  }
}

locals {
  playbook_file = var.profile == null ? null : "${path.root}/../ansible/playbook-${var.profile}.yml"

  ansible_user = var.is_windows ? var.winrm_username : var.ssh_username

  # Base extra args
  _ansible_extra_arguments = var.is_windows ? ([
    "-e", "ansible_winrm_scheme=http",
    "-e", "image_build_dir=${local.output_directory}",
  ]) : ([
    "-e", "image_build_dir=${local.output_directory}",
  ])

  # Extra args given in vars file
  _ansible_profile_arguments = [for arg in var.profile_args: ["-e", arg]]

  ansible_extra_arguments = flatten(concat(local._ansible_extra_arguments, local._ansible_profile_arguments))
}


# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.qemu.vm"]

  # Windows update
  provisioner "windows-update" {
    search_criteria   = "IsInstalled=0"
    except            = var.is_windows ? null : ["qemu.vm"]  # Windows
  }

  provisioner "windows-restart" {
    except            = var.is_windows ? null : ["qemu.vm"]  # Windows
  }

  # Ansible provisioning for Linux and Windows
  provisioner "ansible" {
    ansible_env_vars  = ["ANSIBLE_CONFIG=${path.cwd}/ansible/ansible.cfg"]
    extra_arguments   = local.ansible_extra_arguments
    user              = local.ansible_user
    playbook_file     = local.playbook_file
    use_proxy         = "false"
    max_retries       = 3
  }

  # Windows provisioning
  provisioner "powershell" {
    elevated_user     = var.winrm_username
    elevated_password = var.winrm_password
    scripts           = [
      "${path.root}/scripts/windows/ui-tweaks.ps1",
      "${path.root}/scripts/windows/enable-sshd.ps1",
      "${path.root}/scripts/windows/install-virtio-tools.ps1",
      "${path.root}/scripts/windows/eject-media.ps1"
    ]
    except            = var.is_windows ? null : ["qemu.vm"]  # Windows
    max_retries       = 1
  }

  provisioner "powershell" {
    elevated_user     = "Administrator"
    elevated_password = var.winrm_password
    scripts           = [
      "${path.root}/scripts/windows/cloudbase-init.ps1",
      "${path.root}/scripts/windows/nectar-specifics.ps1"
    ]
    except            = var.is_windows ? null : ["qemu.vm"]
    max_retries       = 1
  }

  provisioner "windows-restart" {
    except = var.is_windows ? null : ["qemu.vm"]
  }

  provisioner "file" {
    source            = "${path.root}/scripts/windows/run-once.cmd"
    destination       = "C:\\Program Files\\Cloudbase Solutions\\Cloudbase-Init\\LocalScripts\\"
    except            = var.is_windows ? null : ["qemu.vm"]
    max_retries       = 1
  }

  provisioner "file" {
    sources           = [
      "${path.root}/scripts/windows/init.ps1",
      "${path.root}/win_answer_files/background.png"
    ]
    destination       = "C:\\ProgramData\\Nectar\\"
    except            = var.is_windows ? null : ["qemu.vm"]
    max_retries       = 1
  }

  provisioner "windows-restart" {
    except = var.is_windows ? null : ["qemu.vm"]
  }

  provisioner "powershell" {
    elevated_user     = var.winrm_username
    elevated_password = var.winrm_password
    scripts = [
      "${path.root}/scripts/windows/set-background.ps1",
      "${path.root}/scripts/windows/cleanup.ps1",
      "${path.root}/scripts/windows/optimize.ps1",
      "${path.root}/scripts/windows/run-sysprep.ps1"
    ]
    except            = var.is_windows ? null : ["qemu.vm"]  # Windows
    max_retries       = 1
  }

  provisioner "shell" {
    script            = "${path.root}/scripts/_common/cleanup.sh"
    except            = var.is_windows ? ["qemu.vm"] : null  # Linux only
  }

  post-processors {

    post-processor "shell-local" {
      inline = [
        "mv ${local.output_directory}/${local.build_name} ${local.output_directory}/image.${var.qemu_format}"
      ]
    }
    post-processor "artifice" {
      files = [
        "${local.output_directory}/image.${var.qemu_format}",
        "${local.output_directory}/.facts",
        "${local.output_directory}/.tags"
      ]
    }
  }
}


build {
  sources = ["source.openstack.vm"]

  ## Linux and Windows
  provisioner "ansible" {
    ansible_env_vars  = ["ANSIBLE_CONFIG=${path.cwd}/ansible/ansible.cfg"]
    extra_arguments   = local.ansible_extra_arguments
    user              = local.ansible_user
    playbook_file     = local.playbook_file
    use_proxy         = "false"
    max_retries       = 3
  }

  provisioner "shell" {
    execute_command   = "{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script            = "${path.root}/scripts/_common/cleanup.sh"
    except            = var.is_windows ? ["qemu.vm"] : null  # Linux only
  }

  post-processors {

    post-processor "manifest" {
        output = "${local.output_directory}/manifest.json"
        strip_path = true
    }

    post-processor "shell-local" {
      inline = [
        "IMAGE_ID=$(jq -r '.builds[-1].artifact_id' ${local.output_directory}/manifest.json)",
        "echo 'Downloading image...'",
        "openstack image save --file ${local.output_directory}/image $IMAGE_ID",
        "echo 'Cleaning up old image...'",
        "openstack image delete $IMAGE_ID",
        "echo 'Converting image...'",
        "qemu-img convert -c -O qcow2 ${local.output_directory}/image ${local.output_directory}/image.qcow2",
        "rm ${local.output_directory}/image"
      ]
    }
    post-processor "artifice" {
      files = [
        "${local.output_directory}/image.qcow2",
        "${local.output_directory}/.facts",
        "${local.output_directory}/.tags"
      ]
    }
  }
}
