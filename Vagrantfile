# -*- mode: ruby -*-
# vi: set ft=ruby :
# vim: noai:ts=2:sw=2:et

# source: https://gist.github.com/mohclips/d4c0edf665f47ed59338c6f7c4a18454

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
sudo apt-get update -yqq && \
sudo apt-get install -yqq software-properties-common \
                   python-software-properties && \
sudo apt-get install -yqq build-essential \
                   libssl-dev \
                   libreadline-dev \
                   wget curl \
                   openssh-server && \
sudo apt-get install -yqq python-setuptools \
                   perl pkg-config \
                   python python-pip \
                   python-dev && \

sudo easy_install --upgrade pip && \
sudo easy_install --upgrade setuptools; \
sudo pip install setuptools --upgrade && \

sudo add-apt-repository -y ppa:git-core/ppa && \
sudo add-apt-repository -y ppa:ansible/ansible && \

sudo apt-get update -yqq && \
sudo apt-get install -yqq git lsof strace ansible && \

sudo mkdir -p /home/vagrant/ansible/{roles,group_vars,inventory}

sudo chown -R vagrant:vagrant /home/vagrant/

cat << EOF > /home/vagrant/ansible/ansible.cfg
[defaults]
# Modern servers come and go too often for host key checking to be useful
roles_path = ./roles
system_errors = False
host_key_checking = False
ask_sudo_pass = False
retry_files_enabled = False
gathering = smart
force_handlers = True

[privilege_escalation]
# Nearly everything requires sudo, so default on
become = True

[ssh_connection]
# Speeds things up, but requires disabling requiretty in /etc/sudoers
pipelining = True
EOF

cat << EOF > /home/vagrant/ansible/playbook.yml
---
- hosts: all
  become: yes
  become_method: sudo
  vars:
    ulimit_config:
      - domain: '*'
        type: soft
        item: nofile
        value: 64000
      - domain: '*'
        type: hard
        item: nofile
        value: 64000
  roles:
    - ulimit
    - sysctl-performance
    - debops.rsyslog
  tasks:
    - name: Set Time Zone
      hosts: Ubuntu
      gather_facts: False
      tasks:
        - name: Set timezone variables
          copy: content='UTC\n'
                dest=/etc/timezone
                owner=root
                group=root
                mode=0644
                backup=yes
          notify:
            - update timezone
      handlers:
        - name: update timezone
          command: dpkg-reconfigure --frontend noninteractive tzdata
EOF

cat << EOF > /home/vagrant/ansible/hosts
localhost ansible_connection=local ansible_python_interpreter=/usr/bin/python2
EOF

cat << EOF > /home/vagrant/ansible/galaxy.txt
debops.ansible_plugins
debops.apache
debops.apt
debops.apt_cacher_ng
debops.apt_install
debops.apt_listchanges
debops.apt_preferences
debops.apt_proxy
debops.atd
debops.auth
debops.authorized_keys
debops.avahi
debops.backporter
debops.bootstrap
debops.boxbackup
debops.console
debops.core
debops.cron
debops.cryptsetup
debops.debops
debops.debops_api
debops.debops_fact
debops.dhcpd
debops.dhparam
debops.dnsmasq
debops.docker
debops.docker_gen
debops.dokuwiki
debops.dovecot
debops.elastic_co
debops.elasticsearch
debops.environment
debops.etc_aliases
debops.etc_services
debops.etherpad
debops.fail2ban
debops.fcgiwrap
debops.ferm
debops.gitlab
debops.gitlab_ci
debops.gitlab_ci_runner
debops.gitlab_runner
debops.gitusers
debops.golang
debops.grub
debops.gunicorn
debops.hashicorp
debops.hwraid
debops.ifupdown
debops.ipxe
debops.iscsi
debops.java
debops.kibana
debops.kvm
debops.librenms
debops.libvirt
debops.libvirtd
debops.libvirtd_qemu
debops.logrotate
debops.lvm
debops.lxc
debops.mailman
debops.mariadb
debops.mariadb_server
debops.memcached
debops.monit
debops.monkeysphere
debops.mosquitto
debops.mysql
debops.netbox
debops.nfs
debops.nfs_server
debops.nginx
debops.nodejs
debops.nsswitch
debops.ntp
debops.nullmailer
debops.opendkim
debops.openvz
debops.owncloud
debops.persistent_paths
debops.php
debops.php5
debops.phpipam
debops.phpmyadmin
debops.pki
debops.postconf
debops.postfix
debops.postgresql
debops.postgresql_server
debops.postscreen
debops.postwhite
debops.preseed
debops.rabbitmq_management
debops.rabbitmq_server
debops.radvd
debops.rails_deploy
debops.redis
debops.reprepro
debops.resources
debops.root_account
debops.rsnapshot
debops.rstudio_server
debops.rsyslog
debops.ruby
debops.salt
debops.samba
debops.saslauthd
debops.secret
debops.sftpusers
debops.sks
debops.slapd
debops.smstools
debops.snmpd
debops.sshd
debops.stunnel
debops.swapfile
debops.sysctl
debops.tcpwrappers
debops.tftpd
debops.tgt
debops.tinc
debops.unattended_upgrades
debops.unbound
debops.users
EOF

cd /home/vagrant/ansible/roles
git clone https://github.com/KAMI911/ansible-role-sysctl-performance sysctl-performance
git clone https://github.com/picotrading/ansible-ulimit ulimit
ansible-galaxy install debops.rsyslog

cd /home/vagrant/ansible

ansible-playbook -i hosts playbook.yml

cd /home/vagrant

git clone https://github.com/bossjones/reproduce_travisci_docker_permissions_issue.git && \
git clone https://github.com/KAMI911/ansible-role-sysctl-performance.git && \
git clone https://github.com/dev-sec/ansible-os-hardening.git && \
echo "#!/usr/bin/env bash" > reproduce_travisci_docker_permissions_issue/scripts/default.sh && \
echo "set -x" >> reproduce_travisci_docker_permissions_issue/scripts/default.sh && \
echo "_USER=vagrant" >> reproduce_travisci_docker_permissions_issue/scripts/default.sh && \
echo "_NON_ROOT_USER_UID_OLD=1000" >> reproduce_travisci_docker_permissions_issue/scripts/default.sh && \
echo "_NON_ROOT_USER_GID_OLD=1000" >> reproduce_travisci_docker_permissions_issue/scripts/default.sh && \
echo "_NON_ROOT_USER_UID=1000" >> reproduce_travisci_docker_permissions_issue/scripts/default.sh && \
echo "_NON_ROOT_USER_GID=1000" >> reproduce_travisci_docker_permissions_issue/scripts/default.sh && \
echo "_PYENV_PYTHON_VERSION=3.5.2" >> reproduce_travisci_docker_permissions_issue/scripts/default.sh && \
echo "DOCKER_COMPOSE_VERSION=1.8.0" >> reproduce_travisci_docker_permissions_issue/scripts/default.sh && \
echo "DOCKER_VERSION=1.12.6-0~ubuntu-trusty" >> reproduce_travisci_docker_permissions_issue/scripts/default.sh && \
echo "DOCKER_PACKAGE_NAME=docker-engine" >> reproduce_travisci_docker_permissions_issue/scripts/default.sh && \
echo "DEBIAN_FRONTEND=noninteractive" >> reproduce_travisci_docker_permissions_issue/scripts/default.sh && \
sudo chmod +x ./reproduce_travisci_docker_permissions_issue/scripts/bootstrap_with_modified_uid_and_gid.sh && \
sudo ./reproduce_travisci_docker_permissions_issue/scripts/bootstrap_with_modified_uid_and_gid.sh
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
  config.ssh.keep_alive  = 5
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

    # source: https://github.com/mitchellh/vagrant/issues/1673
    #   config.vm.provision "fix-no-tty", type: "shell" do |s|
    #     s.privileged = false
    #     s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
    # end

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

