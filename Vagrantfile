# -*- mode: ruby -*-

# vi: set ft=ruby :

boxes = [
    {
        :name => "master-1",
        :port => "40022",
        :mem => "1512",
        :cpu => "2"
    },
    {
        :name => "master-2",
        :port => "50022",
        :mem => "1512",
        :cpu => "2"
    },
    {
        :name => "minion-1",
        :eth1 => "11.0.0.55",
        :port => "55022",
        :mem => "512",
        :cpu => "2"
    },
    {
        :name => "minion-3",
        :eth1 => "11.0.0.57",
        :port => "57022",
        :mem => "512",
        :cpu => "2"
    },
    {
        :name => "minion-2",
        :eth1 => "11.0.0.56",
        :port => "56022",
        :mem => "2048",
        :cpu => "2"
    }
    
]


Vagrant.configure(2) do |config|

  config.vm.box = "centos/7"

  # Turn off shared folders
  config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

  boxes.each do |opts|
    config.vm.define opts[:name] do |config|
      config.vm.hostname = opts[:name]
      config.vm.box_check_update = false

      config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", opts[:mem]]
        v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]
      end

      config.vm.network :forwarded_port, guest: 22, host: opts[:port], id: "ssh"

    end
  end
end
