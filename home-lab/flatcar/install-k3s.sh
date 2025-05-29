#!/usr/bin/env bash

curl -sfL https://get.k3s.io | sh -

sudo kubectl create namespace metallb-system
sudo kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
sudo kubectl get pods -n metallb-system

sudo kubectl apply -f metallb-config.yaml

sudo kubectl create namespace portainer
sudo kubectl get sc
sudo kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
sudo kubectl apply -n portainer -f https://downloads.portainer.io/ee-lts/portainer-lb.yaml

