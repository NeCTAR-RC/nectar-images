Vagrant.configure("2") do |config|

  # Debian 9 (stretch)
  config.vm.define "debian9" do |c|
    c.vm.box = "debian/stretch64"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3" }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Debian 10 (buster)
  config.vm.define "debian10" do |c|
    c.vm.box = "debian/buster64"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3" }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Debian 11 (bullseye)
  config.vm.define "debian11" do |c|
    c.vm.box = "debian/bullseye64"
    c.vm.provision "shell" do |shell|
      shell.inline = "apt update"  # fix lsb-release
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3" }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Debian 12 (bookworm)
  config.vm.define "debian12" do |c|
    c.vm.box = "debian/bookworm64"
    c.vm.provision "shell" do |shell|
      shell.inline = "apt update"  # fix lsb-release
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Ubuntu 16.04 (xenial)
  config.vm.define "ubuntu1604" do |c|
    c.vm.box = "generic/ubuntu1604"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/xenial64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3" }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Ubuntu 18.04 (bionic)
  config.vm.define "ubuntu1804" do |c|
    c.vm.box = "generic/ubuntu1804"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/bionic64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3" }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Ubuntu 18.04 (bionic) with Docker
  config.vm.define "ubuntu1804-docker" do |c|
    c.vm.box = "generic/ubuntu1804"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/bionic64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             murano_image_type: "Docker",
                             nectar_image_name: "Ubuntu 18.04 LTS (Bionic) amd64 (with Docker)",
                             ansible_python_interpreter: "/usr/bin/python3" }
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

  # Ubuntu 20.04 (focal)
  config.vm.define "ubuntu2004" do |c|
    c.vm.box = "generic/ubuntu2004"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/focal64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Ubuntu 20.04 (focal) with NVIDIA vGPU
  config.vm.define "ubuntu2004-nvidia-vgpu" do |c|
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
  config.vm.define "ubuntu2204" do |c|
    c.vm.box = "generic/ubuntu2204"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/jammy64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Ubuntu 22.04 (jammy) with Docker
  config.vm.define "ubuntu2204-docker" do |c|
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
  config.vm.define "ubuntu2204-nvidia-vgpu" do |c|
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
  config.vm.define "ubuntu2404" do |c|
    c.vm.box = "cloud-image/ubuntu-24.04"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/noble64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # CentOS 7
  config.vm.define "centos7" do |c|
    c.vm.box = "centos/7"
    c.vm.provision "shell", inline: "sudo yum -q -y install libselinux-python"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # CentOS 8
  config.vm.define "centos8" do |c|
    c.vm.box = "centos/8"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # CentOS Stream 8
  config.vm.define "centosstream8" do |c|
    c.vm.box = "centos/stream8"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # CentOS Stream 9
  config.vm.define "centosstream9" do |c|
    c.vm.box = "generic/centos9s"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Rocky Linux 8
  config.vm.define "rocky8" do |c|
    c.vm.box = "rockylinux/8"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Rocky Linux 9
  config.vm.define "rocky9" do |c|
    c.vm.box = "generic/rocky9"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Alma Linux 8
  config.vm.define "almalinux8" do |c|
    c.vm.box = "almalinux/8"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Alma Linux 9
  config.vm.define "almalinux9" do |c|
    c.vm.box = "almalinux/9"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end


  # Fedora 37
  config.vm.define "fedora37" do |c|
    c.vm.box = "fedora/37-cloud-base"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Fedora 38
  config.vm.define "fedora38" do |c|
    c.vm.box = "fedora/38-cloud-base"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Fedora 39
  config.vm.define "fedora39" do |c|
    c.vm.box = "fedora/39-cloud-base"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
    end
  end

  # Fedora 40
  config.vm.define "fedora40" do |c|
    c.vm.box = "fedora/40-cloud-base"
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true }
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook.yml"
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
    c.vm.provision "shell" do |shell|
      shell.inline = "/usr/nectar/run_tests.sh"
      shell.privileged = false
      shell.env = { "NECTAR_TEST_BUILD": 1 }
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

  # Trove MySQL (Ubuntu 16.04 xenial)
  config.vm.define "trove-mysql-ubuntu1604" do |c|
    c.vm.box = "generic/ubuntu1604"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/xenial64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3",
                             datastore: "mysql",
                             datastore_version: "5.7"}
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-trove.yml"
      ansible.become = true
    end
  end

  # Trove MySQL (Ubuntu 18.04 bionic)
  config.vm.define "trove-mysql-ubuntu1804" do |c|
    c.vm.box = "generic/ubuntu1804"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/bionic64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3",
                             datastore: "mysql",
                             datastore_version: "8.0"}
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-trove.yml"
      ansible.become = true
    end
  end

  # Trove PostgreSQL (Ubuntu 16.04 xenial)
  config.vm.define "trove-pgsql-ubuntu1604" do |c|
    c.vm.box = "generic/ubuntu1604"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/xenial64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3",
                             datastore: "pgsql",
                             datastore_version: "9.6"}
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-trove.yml"
      ansible.become = true
    end
  end

  # Trove PostgreSQL (Ubuntu 18.04 bionic)
  config.vm.define "trove-pgsql-ubuntu1804" do |c|
    c.vm.box = "generic/ubuntu1804"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/bionic64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3",
                             datastore: "pgsql",
                             datastore_version: "11.3"}
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-trove.yml"
      ansible.become = true
    end
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
  config.vm.define "manila-share-server-ubuntu2004" do |c|
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

  # Ubuntu 16.04 (xenial) Jenkins slave
  config.vm.define "ubuntu1604-jenkins" do |c|
    c.vm.box = "peru/ubuntu-20.04-server-amd64"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/xenial64"
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

  # Ubuntu 18.04 (bionic) Jenkins slave
  config.vm.define "ubuntu1804-jenkins" do |c|
    c.vm.box = "generic/ubuntu1804"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/bionic64"
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

  # Ubuntu 20.04 (focal) Jenkins slave
  config.vm.define "ubuntu2004-jenkins" do |c|
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
  config.vm.define "ubuntu2204-jenkins" do |c|
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

  # Undercloud Ubuntu 16.04 (xenial)
  config.vm.define "undercloud-ubuntu1604" do |c|
    c.vm.box = "generic/ubuntu1604"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/xenial64"
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

  # Undercloud Ubuntu 18.04 (bionic)
  config.vm.define "undercloud-ubuntu1804" do |c|
    c.vm.box = "generic/ubuntu1804"
    c.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/bionic64"
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

  # Undercloud Ubuntu 20.04 (focal)
  config.vm.define "undercloud-ubuntu2004" do |c|
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
  config.vm.define "undercloud-ubuntu2204" do |c|
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

  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider :libvirt do |v|
    v.memory = 2048
    v.cpus = 2
    v.machine_virtual_size = 4  # 4GB disk
    v.graphics_type = "none"
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
