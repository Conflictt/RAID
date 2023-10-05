# `Дискова підсистема`

Навички роботи з mdadm

## `Завдання`

1. Додати у Vagrantfile додаткові диски
2. Зібрати R0/R5/R10 на вибір
3. Прописати зібраний рейд в конфігураційний файл, щоб рейд збирався при завантаженні
4. Створити GPT розділ та 5 partition
5. Зламати/відновити raid

### `Додаткові завдання`

1. Vagrantfile, який одразу збирає систему з підключенним рейдом та змонтованими розділами. Після перезавантаження стенду розділи мають автоматично примонтовуватись
2. Перенести працюючу систему з одним диском на RAID 1. Downtime на завантаження з нового диску передбачається

### `Вирішення`

Використовується `box` Debian 11 з оновленим ядром `linux-image-6.1.0-0.deb11.7` та `Virtualbox` `7.0.8`

В конфігурацію Vagrantfile додані додаткові диски та прописаний шлях до скрипта який виконує сбір рейд-масиву при створенні віртуальної машини
Необохідно розмістити raid.sh в одній директорії з Vagrantfile після чого можна виконати `vagrant up`

```ruby
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
    sudo apt install -y parted mdadm smartmontools hdparm gdisk e2fsprogs nano
  SHELL

  config.vm.provision "shell", path: "raid.sh"

end

```

## Корисні посилання

<https://gist.github.com/leifg/4713995?permalink_comment_id=1277833>

<https://rtfm.co.ua/ru/vagrant-dobavit-vtoroy-disk/>

<https://everythingshouldbevirtual.com/virtualization/vagrant-adding-a-second-hard-drive/>

<https://gist.github.com/drmalex07/e9f543766eea14ececc6a8c668921871>

<https://stackoverflow.com/questions/58141200/disk-file-creation-error-with-vbox-and-vagrant>

<https://superuser.com/questions/709055/ide-controller-on-virtualbox>

<https://stackoverflow.com/questions/52264706/storage-attach-id-different-from-the-vagrant-customisation-id>

<https://habr.com/ru/company/raidix/blog/326816/>

<https://blog.open-e.com/how-does-raid-5-work/>

<http://xgu.ru/wiki/mdadm>

<https://github.com/erlong15/otus-linux>

<https://docs.google.com/document/d/1m4niuv-rxMbLjdQ4qS8xG-UpMlMUA8C5yKRQ3IVEi-M/edit>

## Підсумки

З віртуалкою на базі Debian була проблема з підключенням диска, потрібно було в `'--storagectl', 'SATA Controller',` Змінити назву контролера з `SATA` на `SATA Controller`. Назву контролера який використовує `ВМ` можнжа подивитсь після її створення (навіть невдалого) у `Virtualbox`, в налаштуваннях дисків. Іноді потрібно вказувати `IDE` або `IDE Controller`, цей параметр схоже можна контролювати на етапі створення `box`a  або це може залежати від операційної системи.
Також виникла проблема з `'--port', 1, '--device', 0,` яка вирішилась підбиранням значень `0` або `1` (в помилці була підказка)
