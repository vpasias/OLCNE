#!/bin/bash
#
# Kubevirt installation
# https://blogs.oracle.com/cloud-infrastructure/post/running-kvm-and-vmware-vms-in-container-engine-for-kubernetes
# https://kubevirt.io/labs/kubernetes/lab1
# https://kubevirt.io/labs/kubernetes/lab2

vagrant ssh worker1 -c "egrep 'svm|vmx' /proc/cpuinfo"

vagrant ssh worker2 -c "egrep 'svm|vmx' /proc/cpuinfo"

vagrant ssh worker3 -c "egrep 'svm|vmx' /proc/cpuinfo"

vagrant ssh master1 -c "export KUBEVIRT_VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases | grep tag_name | grep -v -- - | sort -V | tail -1 | awk -F':' '{print $2}' | sed 's/,//' | xargs)"

vagrant ssh master1 -c "echo $KUBEVIRT_VERSION"

vagrant ssh master1 -c "kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-operator.yaml"

sleep 60

vagrant ssh master1 -c "kubectl get pods -n kubevirt"

vagrant ssh master1 -c "kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-cr.yaml"

sleep 90

vagrant ssh master1 -c "kubectl get pods -n kubevirt"

vagrant ssh master1 -c "curl -L -o virtctl https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/virtctl-${KUBEVIRT_VERSION}-linux-amd64 && \
chmod +x virtctl"
