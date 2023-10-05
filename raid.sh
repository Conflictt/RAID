#!/bin/bash

# Занулити суперблоки
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}

# Створити рейд5 із 5 дисків
mdadm --create --verbose /dev/md0 -l 5 -n 5 /dev/sd{b,c,d,e,f}

# Створити папку для файла конфігурації mdadm
mkdir /etc/mdadm

# Додавання інформаціх про масив в конфігураційний файл
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

# Створити gpt розділ на рейд масиві
parted -s /dev/md0 mklabel gpt

# Створити розділи
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%

# Створити файлові системи на розділах
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done

# Створення каталогів для монтування
mkdir -p /raid/part{1,2,3,4,5}

# Монтування розділів
for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done

# Додавання інформації про пристрої в fstab
cat /etc/mtab | grep raid >> /etc/fstab
