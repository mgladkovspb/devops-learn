snap install lxd
lxd init
lxc remote list
lxc launch ubuntu:22.04 ubuntu-container
lxc list
lxc exec ubuntu-container bash

apt update
apt upgrade
apt install apache2
systemctl start apache2
systemctl status apache2
exit