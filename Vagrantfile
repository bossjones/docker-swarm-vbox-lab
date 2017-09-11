# -*- mode: ruby -*-
# vi: set ft=ruby :
# vim: noai:ts=2:sw=2:et

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

UBUNTU_BOX='ubuntu/trusty64'
CENTOS_BOX='centos/7'

DOCKER_MEM = 1024
DOCKER_CPUS = 2

$ansible_script = <<SHELL
  # do this to refresh your patch repo db
  sudo yum makecache fast
  sudo yum update -y
  # install stuff
  sudo yum install vim epel-release yum-utils git -y
  # as Ansible comes from EPEL, we install it after we installed EPEL
  sudo yum install ansible python-pip gcc python-devel openssl-devel -y
  # now install winrm to access windows boxes from Ansible
  sudo pip install pywinrm
  # fix for missing/outdated security libs
  sudo pip install requests[security]
  # openstack clients
  sudo pip install python-openstackclient
SHELL

$docker_script = <<SHELL
export DEBIAN_FRONTEND=noninteractive
sudo apt-get autoremove -y && \
sudo apt-get install git -y && \
git clone https://github.com/bossjones/reproduce_travisci_docker_permissions_issue.git && \
git clone https://github.com/KAMI911/ansible-role-sysctl-performance.git && \
echo "
#!/usr/bin/env bash

set -x

_USER=vagrant
_NON_ROOT_USER_UID_OLD=1000
_NON_ROOT_USER_GID_OLD=1000
_NON_ROOT_USER_UID=1100
_NON_ROOT_USER_GID=1100
_PYENV_PYTHON_VERSION=3.5.2

DOCKER_COMPOSE_VERSION=1.8.0
DOCKER_VERSION=1.12.6-0~ubuntu-trusty
DOCKER_PACKAGE_NAME=docker-engine
DEBIAN_FRONTEND=noninteractive
" > reproduce_travisci_docker_permissions_issue/scripts/default.sh && \

sudo bash ./reproduce_travisci_docker_permissions_issue/scripts/bootstrap_with_modified_uid_and_gid.sh
SHELL

$redhat_network = <<SHELL
SHELL

# source: https://github.com/mitchellh/vagrant/issues/886
# INTERNET_INTERFACE = %x(vboxmanage list bridgedifs | grep `route get 8.8.8.8 | grep interface | head -1 | awk -F' '  '{print $2}'` | grep -v VBoxNetworkName | awk -F 'Name: *' '{print $2}').strip
# config.vm.network "public_network", bridge: "#{INTERNET_INTERFACE}"

servers = {
  "ansible01" => { :ip => "172.30.5.60", :bridge => "en0: Wi-Fi (AirPort)", :mem => DOCKER_MEM, :cpus => DOCKER_CPUS, :box => UBUNTU_BOX, :script => '' },
  "docker-engine01" => { :ip => "172.30.5.61", :bridge => "en0: Wi-Fi (AirPort)", :mem => DOCKER_MEM, :cpus => DOCKER_CPUS, :box => UBUNTU_BOX, :script => '' },
  "docker-engine02" => { :ip => "172.30.5.62", :bridge => "en0: Wi-Fi (AirPort)", :mem => DOCKER_MEM, :cpus => DOCKER_CPUS, :box => UBUNTU_BOX, :script => '' },
  "docker-engine03" => { :ip => "172.30.5.63", :bridge => "en0: Wi-Fi (AirPort)", :mem => DOCKER_MEM, :cpus => DOCKER_CPUS, :box => UBUNTU_BOX, :script => '' },
  "docker-engine04" => { :ip => "172.30.5.64", :bridge => "en0: Wi-Fi (AirPort)", :mem => DOCKER_MEM, :cpus => DOCKER_CPUS, :box => UBUNTU_BOX, :script => '' }
}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box_check_update = false
  config.ssh.forward_agent = true
  # enable logging in via ssh with a password
  #config.ssh.username = "vagrant"
  #config.ssh.password = "vagrant"

################################################################################
  servers.each_with_index do |(hostname, info), index|

    #
    # build a vm - from the server dict
    #
    config.vm.define hostname do |cfg|
      cfg.vm.box = info[:box]
      cfg.vm.hostname = hostname

      # note the public network
      cfg.vm.network "public_network", ip: info[:ip], bridge: info[:bridge]

      config.vm.provider "virtualbox" do |v|
        v.name = hostname
        v.memory = info[:mem]
        v.cpus = info[:cpus]
        v.customize ["modifyvm", :id, "--hwvirtex", "on"]
      end

      #
      # do some provisioning - but only once
      #
      config.vm.provision "shell", run: "once" do |s|
        ssh_prv_key = ""
        ssh_pub_key = ""
        if File.file?("#{Dir.home}/.ssh/vagrant")
          ssh_prv_key = File.read("#{Dir.home}/.ssh/vagrant")
          ssh_pub_key = File.readlines("#{Dir.home}/.ssh/vagrant.pub").first.strip
        else
          puts "No SSH key found. You will need to remedy this before pushing to the repository."
        end
        puts "SSH key insertion"
        s.inline = <<-SHELL
          if grep -sq "#{ssh_pub_key}" /home/vagrant/.ssh/authorized_keys; then
            echo "SSH keys already provisioned."
            exit 0;
          fi
          echo "SSH key provisioning."
          mkdir -p /home/vagrant/.ssh/
          touch /home/vagrant/.ssh/authorized_keys
          echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
          echo #{ssh_pub_key} > /home/vagrant/.ssh/id_rsa.pub
          chmod 644 /home/vagrant/.ssh/id_rsa.pub
          echo "#{ssh_prv_key}" > /home/vagrant/.ssh/id_rsa
          chmod 600 /home/vagrant/.ssh/id_rsa
          chown -R vagrant:vagrant /home/vagrant
          exit 0
        SHELL
        #
        # this fixes the centos boxes not enabling their eth1 IPs
        #
        $box = info[:box]
        if $box =~ /redhat|centos/i
          puts "RedHat check and network fix"
          s.inline = <<SHELL
            if [ -e /etc/redhat-release ] ; then
              echo "Redhat release found"
              if [ $(ip a s dev eth1 | grep -c "inet #{info[:ip]}") -eq 0 ] ; then
                echo "Restarting network"
                touch /tmp/network-setup
                sudo nmcli connection reload
                sudo systemctl restart network.service
              else
                echo "Network is already up"
              fi
            else
              echo "Not redhat"
            fi
            exit 0
SHELL
        end
        #
        # any script per vm to install
        #
        s.inline = info[:script]
      # end scripts
      end

    end
  end
################################################################################
end

