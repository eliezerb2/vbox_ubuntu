sudo apt-get update
sudo apt-get install openssh-server
sudo systemctl start ssh
sudo systemctl enable ssh
sudo ufw allow ssh
sudo apt-get install qemu-kvm libvirt-daemon-system libvirt-clients virtinst qemu-utils