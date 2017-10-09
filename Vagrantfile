VAGRANTFILE_API_VERSION = "2"


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Debian 7 (wheezy)
  config.vm.define "debian7" do |c|
    c.vm.box = "debian/wheezy64"
    c.vm.provision "shell", inline: "sudo apt-get -q update"
    c.vm.provision "shell", inline: "sudo apt-get -q -y install python-apt"
    c.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # Debian 8 (jessie)
  config.vm.define "debian8" do |c|
    c.vm.box = "geerlingguy/debian8"
    c.vm.provision "shell", inline: "sudo apt-get -q update"
    c.vm.provision "shell", inline: "sudo apt-get -q -y install python-apt"
    c.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # Ubuntu 14.04 (trusty)
  config.vm.define "ubuntu1404" do |c|
    c.vm.box = "geerlingguy/ubuntu1404"
    c.vm.provision "shell", inline: "sudo apt-get -q update"
    c.vm.provision "shell", inline: "sudo apt-get -q -y install python-apt"
    c.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # Ubuntu 14.04 (trusty) with Murano Agent
  config.vm.define "ubuntu1404-murano-agent" do |c|
    c.vm.box = "geerlingguy/ubuntu1404"
    c.vm.provision "shell", inline: "sudo apt-get -q update"
    c.vm.provision "shell", inline: "sudo apt-get -q -y install python-apt"
    c.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/playbook-murano-agent.yml"
      ansible.become = true
    end
  end

  # Ubuntu 16.04 (xenial)
  config.vm.define "ubuntu1604" do |c|
    c.vm.box = "geerlingguy/ubuntu1604"
    c.vm.provision "shell", inline: "sudo apt-get -q update"
    c.vm.provision "shell", inline: "sudo apt-get -q -y install python-apt"
    c.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # Ubuntu 16.04 (xenial) with Trove Agent and MySQL 5.7
  config.vm.define "ubuntu1604-trove-mysql" do |c|
    c.vm.box = "geerlingguy/ubuntu1604"
    c.vm.provision "shell", inline: "sudo apt-get -q update"
    c.vm.provision "shell", inline: "sudo apt-get -q -y install python-apt"
    c.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/playbook-trove-mysql.yml"
      ansible.become = true
    end
  end

  # Ubuntu 16.04 (xenial) with Murano Agent
  config.vm.define "ubuntu1604-murano-agent" do |c|
    c.vm.box = "geerlingguy/ubuntu1604"
    c.vm.provision "shell", inline: "sudo apt-get -q update"
    c.vm.provision "shell", inline: "sudo apt-get -q -y install python-apt"
    c.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/playbook-murano-agent.yml"
      ansible.become = true
    end
  end

  # CentOS 6
  config.vm.define "centos6" do |c|
    c.vm.box = "centos/6"
    c.vm.provision "shell", inline: "sudo yum -q -y install libselinux-python"
    c.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # CentOS 7
  config.vm.define "centos7" do |c|
    c.vm.box = "centos/7"
    c.vm.provision "shell", inline: "sudo yum -q -y install libselinux-python"
    c.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # CentOS 7 with Murano Agent
  config.vm.define "centos7-murano-agent" do |c|
    c.vm.box = "centos/7"
    c.vm.provision "shell", inline: "sudo yum -q -y install libselinux-python"
    c.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/playbook-murano-agent.yml"
      ansible.become = true
    end
  end

  # Fedora 24
  config.vm.define "fedora24" do |c|
    c.vm.box = "fedora/24-cloud-base"
    c.vm.provision "shell", inline: "sudo dnf -q -y install python2 libselinux-python python2-dnf"
    c.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # Fedora 25
  config.vm.define "fedora25" do |c|
    c.vm.box = "fedora/25-cloud-base"
    c.vm.provision "shell", inline: "sudo dnf -q -y install python2 libselinux-python python2-dnf"
    c.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # openSUSE 42.1
  config.vm.define "opensuse421" do |c|
    c.vm.box = "opensuse/openSUSE-42.1-x86_64"
    c.vm.provision "shell", inline: "zypper --gpg-auto-import-keys refresh"
    c.vm.provision "shell", inline: "zypper -n install python"
    c.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # Scientific
  config.vm.define "scientific6" do |c|
    c.vm.box = "iamc/scientific65_x86_64_minimal"
    c.vm.provision "shell", inline: "sudo yum -q -y install libselinux-python"
    c.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/playbook.yml"
      ansible.become = true
    end
  end

  # Ubuntu 14.04 (trusty) Jenkins slave
  config.vm.define "ubuntu1404-jenkins" do |c|
    c.vm.box = "geerlingguy/ubuntu1404"
    c.vm.provision "shell", inline: "sudo apt-get -q update"
    c.vm.provision "shell", inline: "sudo apt-get -q -y install python-apt"
    c.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/playbook-jenkins-slave.yml"
      ansible.become = true
    end
  end

  # Ubuntu 16.04 (xenial) Jenkins slave
  config.vm.define "ubuntu1604-jenkins" do |c|
    c.vm.box = "geerlingguy/ubuntu1604"
    c.vm.provision "shell", inline: "sudo apt-get -q update"
    c.vm.provision "shell", inline: "sudo apt-get -q -y install python-apt"
    c.vm.provision "ansible" do |ansible|
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
