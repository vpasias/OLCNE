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

### Testing
# Creating a virtual machine
vagrant ssh master1 -c "kubectl apply -f https://raw.githubusercontent.com/kubevirt/demo/master/manifests/vm.yaml"

# After deployment you can manage VMs using the usual verbs:
vagrant ssh master1 -c "kubectl describe vm testvm"

# To start a VM you can use, this will create a VM instance (VMI)
vagrant ssh master1 -c "./virtctl start testvm"

# The interested reader can now optionally inspect the instance
vagrant ssh master1 -c "kubectl describe vmi testvm"

# Connect to the serial console
# vagrant ssh master1
# ./virtctl console testvm
# To shut the VM down again:
# vagrant ssh master1 -c "./virtctl stop testvm"
# To delete
# vagrant ssh master1 -c "kubectl delete vm testvm"

