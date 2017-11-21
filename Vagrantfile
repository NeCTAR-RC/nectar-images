VAGRANTFILE_API_VERSION = "2"


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Debian 7 (wheezy)
  config.vm.define "debian7" do |c|
    c.vm.box = "debian/wheezy64"
    c.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { nectar_test_build: true }
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # Debian 8 (jessie)
  config.vm.define "debian8" do |c|
    c.vm.box = "debian/jessie64"
    c.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { nectar_test_build: true }
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # Debian 9 (stretch)
  config.vm.define "debian9" do |c|
    c.vm.box = "debian/stretch64"
    c.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3" }
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # Ubuntu 14.04 (trusty)
  config.vm.define "ubuntu1404" do |c|
    c.vm.box = "ubuntu/trusty64"
    c.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { nectar_test_build: true }
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # Ubuntu 14.04 (trusty) with Murano Agent
  config.vm.define "ubuntu1404-murano-agent" do |c|
    c.vm.box = "ubuntu/trusty64"
    c.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { nectar_test_build: true }
      ansible.playbook = "ansible/playbook-murano-agent.yml"
      ansible.become = true
    end
  end

  # Ubuntu 16.04 (xenial)
  config.vm.define "ubuntu1604" do |c|
    c.vm.box = "ubuntu/xenial64"
    c.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3" }
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # Ubuntu 16.04 (xenial) with Murano Agent
  config.vm.define "ubuntu1604-murano-agent" do |c|
    c.vm.box = "ubuntu/xenial64"
    c.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3" }
      ansible.playbook = "ansible/playbook-murano-agent.yml"
      ansible.become = true
    end
  end

  # Ubuntu 17.10 (artful)
  config.vm.define "ubuntu1710" do |c|
    c.vm.box = "ubuntu/artful64"
    c.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3" }
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # CentOS 6
  config.vm.define "centos6" do |c|
    c.vm.box = "centos/6"
    c.vm.provision "shell", inline: "sudo yum -q -y install libselinux-python"
    c.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { nectar_test_build: true }
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # CentOS 7
  config.vm.define "centos7" do |c|
    c.vm.box = "centos/7"
    c.vm.provision "shell", inline: "sudo yum -q -y install libselinux-python"
    c.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { nectar_test_build: true }
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # CentOS 7 with Murano Agent
  config.vm.define "centos7-murano-agent" do |c|
    c.vm.box = "centos/7"
    c.vm.provision "shell", inline: "sudo yum -q -y install libselinux-python"
    c.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { nectar_test_build: true }
      ansible.playbook = "ansible/playbook-murano-agent.yml"
      ansible.become = true
    end
  end

  # Fedora 26
  config.vm.define "fedora26" do |c|
    c.vm.box = "fedora/26-cloud-base"
    c.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3" }
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # Fedora 27
  config.vm.define "fedora27" do |c|
    c.vm.box = "fedora/27-cloud-base"
    c.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3" }
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # openSUSE Leap 42.3
  config.vm.define "opensuse423" do |c|
    c.vm.box = "opensuse/openSUSE-42.3-x86_64"
    c.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { nectar_test_build: true }
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # Scientific
  config.vm.define "scientific6" do |c|
    c.vm.box = "iamc/scientific65_x86_64_minimal"
    c.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { nectar_test_build: true }
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # Trove MySQL (Ubuntu 16.04 xenial)
  config.vm.define "trove-mysql-ubuntu1604" do |c|
    c.vm.box = "ubuntu/xenial64"
    c.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3",
                             datastore: "mysql" }
      ansible.playbook = "ansible/playbook-trove.yml"
      ansible.become = true
    end
  end

  # Trove PostgreSQL (Ubuntu 16.04 xenial)
  config.vm.define "trove-pgsql-ubuntu1604" do |c|
    c.vm.box = "ubuntu/xenial64"
    c.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3",
                             datastore: "pgsql" }
      ansible.playbook = "ansible/playbook-trove.yml"
      ansible.become = true
    end
  end

  # Ubuntu 14.04 (trusty) Jenkins slave
  config.vm.define "ubuntu1404-jenkins" do |c|
    c.vm.box = "ubuntu/trusty64"
    c.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { nectar_test_build: true }
      ansible.playbook = "ansible/playbook-jenkins-slave.yml"
      ansible.become = true
    end
  end

  # Ubuntu 16.04 (xenial) Jenkins slave
  config.vm.define "ubuntu1604-jenkins" do |c|
    c.vm.box = "ubuntu/xenial64"
    c.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { nectar_test_build: true,
                             ansible_python_interpreter: "/usr/bin/python3" }
      ansible.playbook = "ansible/playbook-jenkins-slave.yml"
      ansible.become = true
    end
  end

  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider :virtualbox do |v|
    v.memory = 2048
    v.cpus = 2
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--ioapic", "on"]
  end

end

# vi: set ft=ruby :
