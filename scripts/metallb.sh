#!/bin/bash
#
# MetalLB installation
# https://metallb.universe.tf/installation/

vagrant ssh master1 -c "PATH=$PATH:/usr/local/bin && curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash"

vagrant ssh master1 -c "kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.3/manifests/namespace.yaml && \
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.3/manifests/metallb.yaml"

vagrant ssh master1 -c "cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.99.230-192.168.99.250
EOF"

vagrant ssh master1 -c "kubectl get pods -o wide -n metallb-system"
