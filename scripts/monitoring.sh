#!/bin/bash
#
# Monitoring of the Production Kubernetes cluster
# https://computingforgeeks.com/setup-prometheus-and-grafana-on-kubernetes/

vagrant ssh master1 -c "sudo dnf install --assumeyes --nogpgcheck git vim wget curl"

vagrant ssh master1 -c "git clone https://github.com/prometheus-operator/kube-prometheus.git && cd kube-prometheus && \
kubectl create -f manifests/setup && sleep 30 && kubectl get ns monitoring && kubectl get pods -n monitoring && \
kubectl create -f manifests/"

sleep 60

vagrant ssh master1 -c "kubectl get pods -n monitoring && \
kubectl get svc -n monitoring"

# kubectl delete --ignore-not-found=true -f manifests/ -f manifests/setup
