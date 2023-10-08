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
      
      file_to_disk1 = 'disk1.vdi'
      unless File.exist?(file_to_disk1)
        vb.customize [
          "createhd",
          "--filename", file_to_disk1,
          "--format", "VDI",
          "--size", 1 * 1024
        ]
        vb.customize [
          'storageattach', :id,
          '--storagectl', 'SATA Controller',
          '--port', 1, '--device', 0,
          '--type', 'hdd', '--medium',
          file_to_disk1
        ]
      end

      file_to_disk2 = 'disk2.vdi'
      unless File.exist?(file_to_disk2)
        vb.customize [
          "createhd",
          "--filename", file_to_disk2,
          "--format", "VDI",
          "--size", 1 * 1024
        ]
        vb.customize [
          'storageattach', :id,
          '--storagectl', 'SATA Controller',
          '--port', 2, '--device', 0,
          '--type', 'hdd', '--medium',
          file_to_disk2
        ]
      end

      file_to_disk3 = 'disk3.vdi'
      unless File.exist?(file_to_disk3)
        vb.customize [
          "createhd",
          "--filename", file_to_disk3,
          "--format", "VDI",
          "--size", 1 * 1024
        ]
        vb.customize [
          'storageattach', :id,
          '--storagectl', 'SATA Controller',
          '--port', 3, '--device', 0,
          '--type', 'hdd', '--medium',
          file_to_disk3
        ]
      end

      file_to_disk4 = 'disk4.vdi'
      unless File.exist?(file_to_disk4)
        vb.customize [
          "createhd",
          "--filename", file_to_disk4,
          "--format", "VDI",
          "--size", 1 * 1024
        ]
        vb.customize [
          'storageattach', :id,
          '--storagectl', 'SATA Controller',
          '--port', 4, '--device', 0,
          '--type', 'hdd', '--medium',
          file_to_disk4
        ]
      end

      file_to_disk5 = 'disk5.vdi'
      unless File.exist?(file_to_disk5)
        vb.customize [
          "createhd",
          "--filename", file_to_disk5,
          "--format", "VDI",
          "--size", 1 * 1024
        ]
        vb.customize [
          'storageattach', :id,
          '--storagectl', 'SATA Controller',
          '--port', 5, '--device', 0,
          '--type', 'hdd', '--medium',
          file_to_disk5
        ]
      end

    end
  end

  config.vm.provision "prov1", type: "shell", inline: <<-SHELL
    sudo apt update && sudo apt upgrade -yy
    sudo apt autoclean && sudo apt autoremove -y
    sudo apt install -y parted mdadm smartmontools hdparm gdisk e2fsprogs nano lshw rsync
  SHELL

  config.vm.provision "shell", path: "raid.sh"

end
