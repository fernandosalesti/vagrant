#! /bin/bash
 
sudo dnf install -y httpd
sudo setenforce 0
sudo systemctl enable --now httpd
