#! /bin/bash

sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl enable --now apache2