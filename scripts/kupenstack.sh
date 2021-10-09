#!/bin/bash
#
# Kupenstack installation
# https://github.com/Kupenstack/kupenstack/tree/main/config/demo2

vagrant ssh master1 -c "kubectl apply -f https://raw.githubusercontent.com/Kupenstack/kupenstack/main/config/demo2/crds.yaml"

vagrant ssh master1 -c "cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: kupenstack

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: kupenstack-config
  namespace: kupenstack
data:
  config.yaml: |
    apiVersion: kupenstack.io/v1alpha1
    kind: KupenstackConfiguration
    metadata:
      name: configfile
    spec:
      defaultProfile:
        name: occp
        namespace: default

      # List of k8s nodes to disable for osk cluster.
      nodes:
        - name: worker1.vagrant.vm
          type: control,compute
        - name: worker2.vagrant.vm
          type: control,compute
        - name: worker3.vagrant.vm
          type: control,compute
EOF"

vagrant ssh master1 -c "kubectl config set-context --current --namespace=kupenstack"

vagrant ssh master1 -c "kubectl apply -f https://raw.githubusercontent.com/Kupenstack/kupenstack/main/config/demo2/occp.yaml"

vagrant ssh master1 -c "kubectl apply -f https://raw.githubusercontent.com/Kupenstack/kupenstack/main/config/demo2/kupenstack-controller-manager.yaml"

sleep 360

vagrant ssh master1 -c "kubectl get pods -n kupenstack"

vagrant ssh master1 -c "cat << EOF | kubectl apply -f -
apiVersion: kupenstack.io/v1alpha1
kind: Image
metadata:
  name: image-sample
spec:
  src: http://download.cirros-cloud.net/0.5.1/cirros-0.5.1-x86_64-disk.img
  format: raw

---
apiVersion: kupenstack.io/v1alpha1
kind: Flavor
metadata:
  name: flavor-sample
spec:
  vcpu: 2
  ram: 500
  disk: 1
  rxtx: "1.0"

---
apiVersion: kupenstack.io/v1alpha1
kind: VirtualMachine
metadata:
  name: virtualmachine-sample
spec:
  image: image-sample
  flavor: flavor-sample         
EOF"

vagrant ssh master1 -c "kubectl get virtualmachines && kubectl get vm -o wide && \
kubectl get networks && kubectl get flavors && kubectl get images && \
kubectl get keypairs -o wide && kubectl describe ns default"
