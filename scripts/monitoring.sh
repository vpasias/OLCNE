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

# vagrant ssh master1 -c "kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"

# Delete
# kubectl delete --ignore-not-found=true -f manifests/ -f manifests/setup
 
# Grafana Dashboard access
# kubectl --namespace monitoring port-forward svc/grafana 3000
# Then access Grafana dashboard on your local browser on URL:  http://localhost:3000
# Username: admin
# Password: admin

# Prometheus Dashboard
# kubectl --namespace monitoring port-forward svc/prometheus-k8s 9090
# And web console is accessible through the URL: http://localhost:9090

# Alert Manager Dashboard
# kubectl --namespace monitoring port-forward svc/alertmanager-main 9093
# Access URL is http://localhost:9093
