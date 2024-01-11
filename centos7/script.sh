#! /bin/bash
 
 sudo yum install -y httpd
 sudo setenforce 0
 sudo systemctl enable --now httpd