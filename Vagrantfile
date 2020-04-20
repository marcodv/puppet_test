MEMORY_MASTER = 2048
MEMORY_AGENT = 256
VAGRANT_VM_PROVIDER = "virtualbox"

Vagrant.configure("2") do |config|

  config.vm.define :puppet_server do |puppetmaster|
    puppetmaster.vm.box = 'puppetlabs/ubuntu-16.04-64-puppet'
    puppetmaster.vm.network :private_network , ip: "192.168.10.21"
    puppetmaster.vm.hostname = 'puppetmaster.puppetdebug.vlan'
    puppetmaster.vm.provider VAGRANT_VM_PROVIDER do |vb|          
      vb.memory = MEMORY_MASTER
    end
  
    # puppetmaster.vm.provision :hosts
    bootstrap_script = <<-EOF
      if dpkg -s puppetserver > /dev/null 2>&1; then
        echo 'Puppet Server Installed.'
      else
        echo 'Installing Puppet Server.'
        sudo apt-get update && apt-get install puppetserver vim -y --allow-unauthenticated
        sudo echo '*.puppetdebug.vlan' > /etc/puppetlabs/puppet/autosign.conf
        echo "192.168.10.22 domain.com" | sudo tee -a /etc/hosts
        sed -i 's/^JAVA_ARGS.*/JAVA_ARGS="-Xms512m -Xmx512m"/g' /etc/default/puppetserver
         echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/puppetlabs/bin"' > /etc/environment
         puppet resource service puppetserver ensure=running enable=true
         puppet module install puppet-nginx
         puppet module install puppetlabs-apt
         mkdir -p /etc/puppetlabs/code/environments/production/modules/netcentric_puppet/manifests
         cp /vagrant/site.pp /etc/puppetlabs/code/environments/production/manifests
         cp -r /vagrant/netcentric_puppet/manifests/*.pp /etc/puppetlabs/code/environments/production/modules/netcentric_puppet/manifests
      fi
    EOF
    puppetmaster.vm.provision :shell, :inline => bootstrap_script
  end

  config.vm.define :puppetagent do |puppet_agent|
    puppet_agent.vm.box = 'puppetlabs/ubuntu-16.04-64-puppet'
    puppet_agent.vm.hostname = 'puppetagent.puppetdebug.vlan'
    puppet_agent.vm.network :private_network , ip: "192.168.10.22"

    # Set up Puppet Agent to automatically connect with Puppet master
    bootstrap_script = <<-EOF
    echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/puppetlabs/bin"' > /etc/environment
    echo "192.168.10.21 puppetmaster.puppetdebug.vlan puppetmaster.puppetdebug.vlan" | sudo tee -a /etc/hosts
    echo "192.168.10.22 domain.com" | sudo tee -a /etc/hosts
    if which puppet > /dev/null 2>&1; then
      echo 'Puppet Installed.'
    else
      echo 'Installing Puppet Agent.'
      sudo apt-get udpate && apt-get install puppet-agent -y --allow-unauthenticated
      sudo apt-get install -y vim
    fi
      puppet config set --section main server puppetmaster.puppetdebug.vlan
      echo 'server = puppetmaster.puppetdebug.vlan' >> /etc/puppetlabs/puppet/puppet.conf
      puppet agent --server puppetmaster.puppetdebug.vlan --waitforcert 60 --test
    EOF
    puppet_agent.vm.provision :shell, :inline => bootstrap_script
  end
end
