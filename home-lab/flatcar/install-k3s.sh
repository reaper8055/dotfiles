#!/usr/bin/env bash

curl -sfL https://get.k3s.io | sh -

sudo kubectl create namespace metallb-system
sudo kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
sudo kubectl get pods -n metallb-system

cat > metallb-config.yml << EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: lan-pool
  namespace: metallb-system
spec:
  addresses:
    - 10.10.15.100-10.10.15.200
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: lan-adv
  namespace: metallb-system
spec:
  interfaces:
    - enp2s0
EOF

sudo kubectl apply -f metallb-config

sudo kubectl create namespace portainer
sudo kubectl get sc
sudo kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
sudo kubectl apply -n portainer -f https://downloads.portainer.io/ee-lts/portainer-lb.yaml

