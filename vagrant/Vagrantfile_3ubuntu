
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  #config.vm.provider = 'virtualbox'

  config.vm.define "srv1" do | p |
   p.vm.box = 'ubuntu/xenial64'
   p.vm.host_name = "srv1"
   p.vm.network "public_network", ip: "10.20.8.106", bridge: "wlp7s0" 
       p.vm.provider :virtualbox do |res|
          res.customize ["modifyvm", :id, "--cpus", "2"]
          res.customize ["modifyvm", :id, "--memory", "2000"]
       end
  end

  config.vm.define "srv2" do | b |
   b.vm.box= 'ubuntu/xenial64'
   b.vm.host_name = "srv2"
   b.vm.network "public_network", ip: "10.20.8.107", bridge: "wlp7s0"
      b.vm.provider :virtualbox do |res|
        res.customize ["modifyvm", :id, "--cpus", "2"]
        res.customize ["modifyvm", :id, "--memory", "2000"]
      end
  end

  config.vm.define "srv3" do | b |
    b.vm.box= 'ubuntu/xenial64'
    b.vm.host_name = "srv3"
    b.vm.network "public_network", ip: "10.20.8.108", bridge: "wlp7s0"
       b.vm.provider :virtualbox do |res|
         res.customize ["modifyvm", :id, "--cpus", "2"]
         res.customize ["modifyvm", :id, "--memory", "2000"]
       end
   end
 
  

  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yaml"
  end

end
