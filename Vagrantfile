Vagrant.configure("2") do |config|

  # Debian 8 (jessie)
  config.vm.define "debian8" do |c|
    c.vm.box = "debian/jessie64"
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

  # Ubuntu 16.04 (xenial)
  config.vm.define "ubuntu1604" do |c|
    c.vm.box = "generic/ubuntu1604"
    config.vm.provider "virtualbox" do |v, override|
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
    config.vm.provider "virtualbox" do |v, override|
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
    config.vm.provider "virtualbox" do |v, override|
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

  # Ubuntu 18.10 (cosmic)
  config.vm.define "ubuntu1810" do |c|
    c.vm.box = "roboxes/ubuntu1810"
    config.vm.provider " virtualbox" do |v, override|
      override.vm.box = "ubuntu/cosmic64"
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

  # Ubuntu 19.10 (eoan)
  config.vm.define "ubuntu1910" do |c|
    c.vm.box = "roboxes/ubuntu1910"
    config.vm.provider " virtualbox" do |v, override|
      override.vm.box = "ubuntu/eoan64"
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


 # CentOS 6
  config.vm.define "centos6" do |c|
    c.vm.box = "centos/6"
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
    #c.vm.provision "shell", inline: "sudo yum -q -y install libselinux-python"
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

  # Fedora 30
  config.vm.define "fedora30" do |c|
    c.vm.box = "fedora/30-cloud-base"
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

  # Fedora 31
  config.vm.define "fedora31" do |c|
    c.vm.box = "fedora/31-cloud-base"
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

  # openSUSE Leap 42
  config.vm.define "opensuse42" do |c|
    c.vm.box = "generic/opensuse42"
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

  # openSUSE Leap 15
  config.vm.define "opensuse15" do |c|
    c.vm.box = "generic/opensuse15"
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

  # Scientific
  config.vm.define "scientific6" do |c|
    c.vm.box = "iamc/scientific65_x86_64_minimal"
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

  # Trove MySQL (Ubuntu 16.04 xenial)
  config.vm.define "trove-mysql-ubuntu1604" do |c|
    c.vm.box = "generic/ubuntu1604"
    config.vm.provider "virtualbox" do |v, override|
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
    config.vm.provider "virtualbox" do |v, override|
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
    config.vm.provider "virtualbox" do |v, override|
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
    config.vm.provider "virtualbox" do |v, override|
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

  # Trove MySQL (Ubuntu 18.04 bionic)
  config.vm.define "octavia-haproxy-ubuntu1804" do |c|
    c.vm.box = "generic/ubuntu1804"
    config.vm.provider "virtualbox" do |v, override|
      override.vm.box = "ubuntu/bionic64"
    end
    c.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3",
                             driver: "haproxy"}
      ansible.config_file = "ansible/ansible.cfg"
      ansible.playbook = "ansible/playbook-octavia.yml"
      ansible.become = true
    end
  end

  # Ubuntu 16.04 (xenial) Jenkins slave
  config.vm.define "ubuntu1604-jenkins" do |c|
    c.vm.box = "generic/ubuntu1604"
    config.vm.provider "virtualbox" do |v, override|
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
    config.vm.provider "virtualbox" do |v, override|
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

  # Undercloud Ubuntu 16.04 (xenial)
  config.vm.define "undercloud-ubuntu1604" do |c|
    c.vm.box = "generic/ubuntu1604"
    config.vm.provider "virtualbox" do |v, override|
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

  # Ubuntu 18.04 (bionic) Jenkins slave
  config.vm.define "ubuntu1804-jenkins" do |c|
    c.vm.box = "generic/ubuntu1804"
    config.vm.provider "virtualbox" do |v, override|
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

  # Undercloud Ubuntu 18.04 (bionic)
  config.vm.define "undercloud-ubuntu1804" do |c|
    c.vm.box = "generic/ubuntu1804"
    config.vm.provider "virtualbox" do |v, override|
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

  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider :libvirt do |v|
    v.memory = 2048
    v.cpus = 2
    v.machine_virtual_size = 4  # 4GB disk
  end

  config.vm.provider :virtualbox do |v|
    v.memory = 2048
    v.cpus = 2
  end

end

# vi: set ft=ruby :
