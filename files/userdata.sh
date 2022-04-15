#!/bin/bash



sudo apt update -y
sudo apt install nginx -y
sudo apt install nfs-kernel-server -y
sudo apt update -y
sudo apt install nfs-common -y
sudo systemctl start nginx
sudo systemctl enable nginx
sudo mkdir -p /var/www/html
sudo chown -R $USER:$USER /var/www/html
sudo chmod -R 755 /var/www/html/
sudo chmod 777 /etc/fstab
sudo echo "The page was created by the user data" >> /var/www/html/index.html
