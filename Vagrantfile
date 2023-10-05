# -*- mode: ruby -*-
# vim: set ft=ruby :

ENV["LC_ALL"] = "en_US.UTF-8"

Vagrant.configure("2") do |config|

  config.vm.box = "Conflict/Debian11"
  config.vm.box_check_update = false

  config.vm.define "02-Raid" do |raid|
    raid.vm.hostname = "02-Raid"
    raid.vm.network "public_network"
    
    raid.vm.provider "virtualbox" do |vb|
      vb.check_guest_additions = false
      vb.name = "02-Raid" 
      vb.gui = false
      vb.memory = 1024
      vb.cpus = 2
      
      file_to_disk = 'disk2.vdi'
      unless File.exist?(file_to_disk)
        vb.customize [
          "createhd",
          "--filename", file_to_disk,
          "--format", "VDI",
          "--size", 1 * 1024
        ]
        vb.customize [
          'storageattach', :id,
          '--storagectl', 'SATA Controller',
          '--port', 1, '--device', 0,
          '--type', 'hdd', '--medium',
          file_to_disk
        ]
      end
    end
  end

  config.vm.provision "prov1", type: "shell", inline: <<-SHELL

  SHELL

  #config.vm.provision "shell", path: "raid.sh"

end
