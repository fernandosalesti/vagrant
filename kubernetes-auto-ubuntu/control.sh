#!/bin/bash

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update; sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet

kubeadm config images pull


sudo kubeadm init --pod-network-cidr=172.16.32.0/24 --apiserver-advertise-address=10.10.10.100

sudo mkdir -p $HOME/.kube; sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config; sudo chown $(id -u):$(id -g) $HOME/.kube/config

source <(kubectl completion bash)

echo "source <(kubectl completion bash)" >> ~/.bashrc 

sudo kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

sudo kubeadm token create --print-join-command > /vagrant/ingress.txt

sudo mkdir -p /home/vagrant/.kube; sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config; sudo chown vagrant.vagrant /home/vagrant/.kube/config

source <(kubectl completion bash)

echo "source <(kubectl completion bash)" >> /home/vagrant/.bashrc 

#kubectl get nodes
#kubectl get pods -n kube-system