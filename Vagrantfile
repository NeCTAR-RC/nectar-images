Vagrant.configure("2") do |config|

  # Debian 11 (bullseye)
  config.vm.define "debian-11" do |c|
    c.vm.box = "debian/bullseye64"
    c.vm.provision "shell" do |shell|
      shell.inline = "apt update"  # fix lsb-release
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3" }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-standard.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Debian 12 (bookworm)
  config.vm.define "debian-12" do |c|
    c.vm.box = "debian/bookworm64"
    c.vm.provision "shell" do |shell|
      shell.inline = "apt update"  # fix lsb-release
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-standard.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Ubuntu 20.04 (focal)
  config.vm.define "ubuntu-20.04" do |c|
    c.vm.box = "generic/ubuntu2004"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/focal64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-standard.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Ubuntu 20.04 (focal) with NVIDIA vGPU
  config.vm.define "ubuntu-20.04-nvidia-vgpu" do |c|
    c.vm.box = "generic/ubuntu2004"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/focal64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             nectar_image_name: "Ubuntu 20.04 LTS (Jammy) amd64 (NVIDIA vGPU)" }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-nvidia-vgpu.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Ubuntu 22.04 (jammy)
  config.vm.define "ubuntu-22.04" do |c|
    c.vm.box = "generic/ubuntu2204"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/jammy64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-standard.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Ubuntu 22.04 (jammy) with Docker
  config.vm.define "ubuntu-22.04-docker" do |c|
    c.vm.box = "generic/ubuntu2204"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/jammy64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             murano_image_type: "Docker",
                             nectar_image_name: "Ubuntu 22.04 LTS (Jammy) amd64 (with Docker)" }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-docker.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Ubuntu 22.04 (jammy) with NVIDIA vGPU
  config.vm.define "ubuntu-22.04-nvidia-vgpu" do |c|
    c.vm.box = "generic/ubuntu2204"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/jammy64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             nectar_image_name: "Ubuntu 22.04 LTS (Jammy) amd64 (NVIDIA vGPU)" }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-nvidia-vgpu.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Ubuntu 24.04 (noble)
  config.vm.define "ubuntu-24.04" do |c|
    c.vm.box = "cloud-image/ubuntu-24.04"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/noble64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-standard.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # CentOS Stream 9
  config.vm.define "centos-stream-9" do |c|
    c.vm.box = "generic/centos9s"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-standard.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Rocky Linux 8
  config.vm.define "rocky-8" do |c|
    c.vm.box = "rockylinux/8"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-standard.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Rocky Linux 9
  config.vm.define "rocky-9" do |c|
    c.vm.box = "rockylinux/9"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-standard.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Rocky Linux 10
  config.vm.define "rocky-10" do |c|
    c.vm.box = "rockylinux/10"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-standard.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Alma Linux 8
  config.vm.define "almalinux-8" do |c|
    c.vm.box = "almalinux/8"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-standard.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Alma Linux 9
  config.vm.define "almalinux-9" do |c|
    c.vm.box = "almalinux/9"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-standard.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Alma Linux 10
  config.vm.define "almalinux-10" do |c|
    c.vm.box = "almalinux/10"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-standard.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Fedora 41
  config.vm.define "fedora-41" do |c|
    c.vm.box = "fedora/41-cloud-base"
    c.vm.provision "shell" do |shell|
      shell.inline = "sudo dnf install -y python3-libdnf5"  # https://github.com/ansible/ansible/issues/84206
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-standard.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Fedora 42
  config.vm.define "fedora-42" do |c|
    c.vm.box = "fedora/42-cloud-base"
    c.vm.provision "shell" do |shell|
      shell.inline = "sudo dnf install -y python3-libdnf5"  # https://github.com/ansible/ansible/issues/84206
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-standard.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # JupyterLab
  config.vm.define "jupyterlab" do |c|
    c.vm.box = "generic/ubuntu2204"  # doesn't exist yet
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/jammy64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-jupyterlab.yml"
      ansible.become = true
    end
  end

  # R-Studio
  config.vm.define "rstudio" do |c|
    c.vm.box = "generic/ubuntu2204"  # doesn't exist yet
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/jammy64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-rstudio.yml"
      ansible.become = true
    end
    #c.vm.provision "shell" do |shell|
    #  shell.inline = "/usr/nectar/run_tests.sh"
    #  shell.privileged = false
    #  shell.env = { "NECTAR_TEST_BUILD": 1 }
    #end
    config.vm.network :forwarded_port, guest: 80, host: 8080, host_ip: '0.0.0.0'
    config.vm.network :forwarded_port, guest: 443, host: 8443, host_ip: '0.0.0.0'
  end

  # Octavia Amphora (Ubuntu 22.04 focal)
  config.vm.define "octavia-amphora" do |c|
    c.vm.box = "generic/ubuntu2204"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/jammy64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3",
                             driver: "haproxy"}
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-octavia-amphora.yml"
      ansible.become = true
    end
  end

  # Manila Share Server (Ubuntu 20.04 focal)
  config.vm.define "ubuntu-20.04-manila-share-server" do |c|
    c.vm.box = "generic/ubuntu2004"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/focal64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3"}
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-manila.yml"
      ansible.become = true
    end
  end

  # Ubuntu 20.04 (focal) Jenkins slave
  config.vm.define "jenkins-slave-ubuntu-20.04" do |c|
    c.vm.box = "generic/ubuntu2004"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/focal64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3" }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-jenkins-slave.yml"
      ansible.become = true
    end
  end

  # Ubuntu 22.04 (jammy) Jenkins slave
  config.vm.define "jenkins-slave-ubuntu-22.04" do |c|
    c.vm.box = "generic/ubuntu2204"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/jammy64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3" }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-jenkins-slave.yml"
      ansible.become = true
    end
  end

  # Ubuntu 24.04 (noble) Jenkins slave
  config.vm.define "jenkins-slave-ubuntu-24.04" do |c|
    c.vm.box = "cloud-image/ubuntu-24.04"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/noble64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-jenkins-slave.yml"
      ansible.become = true
    end
  end

  # Undercloud Ubuntu 20.04 (focal)
  config.vm.define "undercloud-ubuntu-20.04" do |c|
    c.vm.box = "generic/ubuntu2004"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/focal64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3" }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-undercloud.yml"
      ansible.become = true
    end
  end

  # Undercloud Ubuntu 22.04 (jammy)
  config.vm.define "undercloud-ubuntu-22.04" do |c|
    c.vm.box = "generic/ubuntu2204"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/jammy64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3" }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-undercloud.yml"
      ansible.become = true
    end
  end

  # Undercloud Ubuntu 24.04 (noble)
  config.vm.define "undercloud-ubuntu-24.04" do |c|
    c.vm.box = "cloud-image/ubuntu-24.04"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/noble64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-undercloud.yml"
      ansible.become = true
    end
  end

  # Windows Server 2022
  config.vm.define "windows-2022" do |c|
    c.vm.box = "peru/windows-server-2022-standard-x64-eval"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-windows.yml"
    end
  end

  # Bumblebee Guacamole Server
  config.vm.define "bumblebee-guacamole" do |c|
    c.vm.box = "generic/ubuntu2204"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/jammy64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3" }
      ansible.playbook = "ansible/playbook-bumblebee-guacamole.yml"
      ansible.become = true
    end
  end

  # Bumblebee Scientific Toolbox
  config.vm.define "bumblebee-scientific-toolbox" do |c|
    c.vm.box = "generic/ubuntu2204"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/jammy64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             nectar_image_name: "Scientific Toolbox" }
      ansible.playbook = "ansible/playbook-bumblebee-scientific-toolbox.yml"
      ansible.become = true
    end
    config.vm.network :forwarded_port, guest: 3389, host: 33389, host_ip: '0.0.0.0'
  end

  # Bumblebee Rocky 9
  config.vm.define "bumblebee-rocky-9" do |c|
    c.vm.box = "generic/rocky9"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             nectar_image_name: "Rocky Linux 9 Virtual Desktop" }
      ansible.playbook = "ansible/playbook-bumblebee-desktop.yml"
      ansible.become = true
    end
    config.vm.network :forwarded_port, guest: 3389, host: 33389, host_ip: '0.0.0.0'
  end

  # Bumblebee Ubuntu 22.04 LTS (Jammy)
  config.vm.define "bumblebee-ubuntu-22.04" do |c|
    c.vm.box = "generic/ubuntu2204"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             nectar_image_name: "Ubuntu 22.04 LTS (Jammy) Virtual Desktop" }
      ansible.playbook = "ansible/playbook-bumblebee-desktop.yml"
      ansible.become = true
    end
    config.vm.network :forwarded_port, guest: 3389, host: 33389, host_ip: '0.0.0.0'
  end

  # Bumblebee Ubuntu 24.04 LTS (Noble)
  config.vm.define "bumblebee-ubuntu-24.04" do |c|
    c.vm.box = "cloud-image/ubuntu-24.04"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             nectar_image_name: "Ubuntu 24.04 LTS (Noble) Virtual Desktop" }
      ansible.playbook = "ansible/playbook-bumblebee-desktop.yml"
      ansible.become = true
    end
    config.vm.network :forwarded_port, guest: 3389, host: 33389, host_ip: '0.0.0.0'
  end

  # Bumblebee Neurodesktop
  config.vm.define "bumblebee-neurodesk" do |c|
    c.vm.box = "cloud-image/ubuntu-24.04"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             nectar_image_name: "Neurodesktop" }
      ansible.playbook = "ansible/playbook-bumblebee-neurodesk.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "cp -rT /etc/skel /home/vagrant"
      shell.privileged = false
    end
  config.vm.network :forwarded_port, guest: 3389, host: 33389, host_ip: '0.0.0.0'
  end

  # Ubuntu 22.04 (jammy) - transcription desktop
  config.vm.define "bumblebee-transcription" do |c|
    c.vm.box = "generic/ubuntu2204"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/jammy64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             nectar_image_name: "Transcription desktop" }
      ansible.playbook = "ansible/playbook-bumblebee-transcription.yml"
      ansible.become = true
    end
    config.vm.network :forwarded_port, guest: 3389, host: 33389, host_ip: '0.0.0.0'
  end


  #config.winrm.transport = :plaintext
  #config.winrm.basic_auth_only = true

  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.disk :disk, size: "20GB", primary: true

  config.vm.provider :libvirt do |v|
    v.memory = 4096
    v.cpus = 2
    v.machine_virtual_size = 20  # 4GB disk
    v.graphics_type = "spice"
  end

  config.vm.provider :virtualbox do |v|
    v.gui = false
    v.memory = 2048
    v.cpus = 2
    # Fix for ubuntu images hanging:
    #   https://bugs.launchpad.net/cloud-images/+bug/1829625
    v.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
    v.customize ["modifyvm", :id, "--uartmode1", "file", File::NULL]
  end

end

# vi: set ft=ruby :
