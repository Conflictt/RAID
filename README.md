# `Дискова підсистема`

Навички роботи з mdadm

## `Завдання`

1. Додати у Vagrantfile ще дисків
2. Зламати/відновити raid
3. Зібрати R0/R5/R10 на вибір
4. Прописати зібраний рейд в конфігураційний файл, щоб рейд збирався при завантаженні
5. Створити GPT розділ та 5 partition

### `Додаткові завдання`

1. Vagrantfile, який одразу збирає систему з підключенним рейдом та змонтованими розділами. Після перезавантаження стенду розділи мають автоматично примонтовуватись
2. Перенести працюючу систему з одним диском на RAID 1. Downtime на завантаження з нового диску передбачається

### `Вирішення`

<details><summary>CentOS 7</summary><blockquote>

```ruby
# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
    :otuslinux => {
        :box_name => "centos/7",
        :ip_addr => '192.168.11.101',
    :disks => {
        :sata1 => {
        :dfile => './sata1.vdi',
        :size => 250,
        :port => 1
        },
        :sata2 => {
        :dfile => './sata2.vdi',
        :size => 250,
        :port => 2
        },
        :sata3 => {
        :dfile => './sata3.vdi',
        :size => 250,
        :port => 3
        },
        :sata4 => {
        :dfile => './sata4.vdi',
        :size => 250,
        :port => 4
        },
        :sata5 => {
        :dfile => './sata5.vdi',
        :size => 250,
        :port => 5
        },
        }
    },
}

Vagrant.configure("2") do |config|
    MACHINES.each do |boxname, boxconfig|
        config.vm.define boxname do |box|
            box.vm.box = boxconfig[:box_name]
            box.vm.host_name = boxname.to_s
            box.vm.network "private_network", ip: boxconfig[:ip_addr]
            box.vm.provider :virtualbox do |vb|
                vb.customize ["modifyvm", :id, "--memory", "1024"]
                needsController = false
                boxconfig[:disks].each do |dname, dconf|
                    unless File.exist?(dconf[:dfile])
                        vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
                    needsController =  true
                    end
                end
                if needsController == true
                    vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
                    boxconfig[:disks].each do |dname, dconf|
                        vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
                    end
                end
            end
            box.vm.provision "prov1", type: "shell", inline: <<-SHELL
                mkdir -p ~root/.ssh
                cp ~vagrant/.ssh/auth* ~root/.ssh
                yum install -y mdadm smartmontools hdparm gdisk e2fsprogs nano
            SHELL
            box.vm.provision "shell", path: "raid.sh"
        end
    end
end
```
В конфігурацію Vagrantfile додані додаткові диски та прописаний шлях до скрипта який виконує сбір рейд-масиву при створенні віртуальної машини
Необохідно розмістити raid.sh в одній директорії з Vagrantfile після чого можна виконати `vagrant up`

</blockquote></details>

<details><summary>Debian 11</summary><blockquote>

Використовується `box` Debian11 з оновленим ядром `linux-image-6.1.0-0.deb11.7` та `Virtualbox` `7.0.8`

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
```

## Корисні посилання

<https://gist.github.com/leifg/4713995?permalink_comment_id=1277833>

<https://rtfm.co.ua/ru/vagrant-dobavit-vtoroy-disk/>

<https://everythingshouldbevirtual.com/virtualization/vagrant-adding-a-second-hard-drive/>

<https://gist.github.com/drmalex07/e9f543766eea14ececc6a8c668921871>

<https://stackoverflow.com/questions/58141200/disk-file-creation-error-with-vbox-and-vagrant>

<https://superuser.com/questions/709055/ide-controller-on-virtualbox>

<https://stackoverflow.com/questions/52264706/storage-attach-id-different-from-the-vagrant-customisation-id>

</blockquote></details>

## Корисні посилання

<details><summary>Розгорнути</summary>

<https://habr.com/ru/company/raidix/blog/326816/>

<https://blog.open-e.com/how-does-raid-5-work/>

<http://xgu.ru/wiki/mdadm>

<https://github.com/erlong15/otus-linux>

<https://docs.google.com/document/d/1m4niuv-rxMbLjdQ4qS8xG-UpMlMUA8C5yKRQ3IVEi-M/edit>

</details>

## Підсумки

<details><summary>Розгорнути</summary>

З віртуалкою на базі Debian була проблема з підключенням диска, потрібно було в `'--storagectl', 'SATA Controller',` Змінити назву контролера з `SATA` на `SATA Controller`. Назву контролера який використовує `ВМ` можнжа подивитсь після її створення (навіть невдалого) у `Virtualbox`, в налаштуваннях дисків. Іноді потрібно вказувати `IDE` або `IDE Controller`, цей параметр схоже можна контролювати на етапі створення `box`a  або це ще може залежати від операційної системи.
Також виникла проблема з `'--port', 1, '--device', 0,` яка вирішилась підбиранням значень `0` або `1` (в помилці була підказка)

</details>
