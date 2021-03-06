#!/bin/bash
#
# Dynamic provisioning of Gluster volumes with the Kubernetes module of Oracle Linux Cloud Native Environment
# https://oracle.github.io/linux-labs/OLCNE-Gluster/
# https://docs.oracle.com/en/operating-systems/oracle-linux/gluster-storage/gluster-heketi.html#gluster-heketi-cli

vagrant ssh master1 -c "cat << EOF | sudo tee /etc/hosts
127.0.0.1 localhost
192.168.99.100 operator.vagrant.vm operator
192.168.99.101 master1.vagrant.vm master1
192.168.199.101 master1.vagrant.vm master1
192.168.99.102 master2.vagrant.vm master2
192.168.199.102 master2.vagrant.vm master2
192.168.99.113 worker3.vagrant.vm worker3
192.168.199.113 worker3.vagrant.vm worker3
192.168.99.112 worker2.vagrant.vm worker2
192.168.199.112 worker2.vagrant.vm worker2
192.168.99.103 master3.vagrant.vm master3
192.168.199.103 master3.vagrant.vm master3
192.168.99.111 worker1.vagrant.vm worker1
192.168.199.111 worker1.vagrant.vm worker1
192.168.199.111 storage1.vagrant.vm storage1
192.168.199.112 storage2.vagrant.vm storage2 
192.168.199.113 storage3.vagrant.vm storage3
EOF"

vagrant ssh master2 -c "cat << EOF | sudo tee /etc/hosts
127.0.0.1 localhost
192.168.99.100 operator.vagrant.vm operator
192.168.99.101 master1.vagrant.vm master1
192.168.199.101 master1.vagrant.vm master1
192.168.99.102 master2.vagrant.vm master2
192.168.199.102 master2.vagrant.vm master2
192.168.99.113 worker3.vagrant.vm worker3
192.168.199.113 worker3.vagrant.vm worker3
192.168.99.112 worker2.vagrant.vm worker2
192.168.199.112 worker2.vagrant.vm worker2
192.168.99.103 master3.vagrant.vm master3
192.168.199.103 master3.vagrant.vm master3
192.168.99.111 worker1.vagrant.vm worker1
192.168.199.111 worker1.vagrant.vm worker1
192.168.199.111 storage1.vagrant.vm storage1
192.168.199.112 storage2.vagrant.vm storage2 
192.168.199.113 storage3.vagrant.vm storage3
EOF"

vagrant ssh master3 -c "cat << EOF | sudo tee /etc/hosts
127.0.0.1 localhost
192.168.99.100 operator.vagrant.vm operator
192.168.99.101 master1.vagrant.vm master1
192.168.199.101 master1.vagrant.vm master1
192.168.99.102 master2.vagrant.vm master2
192.168.199.102 master2.vagrant.vm master2
192.168.99.113 worker3.vagrant.vm worker3
192.168.199.113 worker3.vagrant.vm worker3
192.168.99.112 worker2.vagrant.vm worker2
192.168.199.112 worker2.vagrant.vm worker2
192.168.99.103 master3.vagrant.vm master3
192.168.199.103 master3.vagrant.vm master3
192.168.99.111 worker1.vagrant.vm worker1
192.168.199.111 worker1.vagrant.vm worker1
192.168.199.111 storage1.vagrant.vm storage1
192.168.199.112 storage2.vagrant.vm storage2 
192.168.199.113 storage3.vagrant.vm storage3
EOF"

vagrant ssh worker1 -c "sudo dnf install -y oracle-gluster-release-el8 && sudo dnf install -y glusterfs-server glusterfs-client git vim wget curl" && \
vagrant ssh worker2 -c "sudo dnf install -y oracle-gluster-release-el8 && sudo dnf install -y glusterfs-server glusterfs-client git vim wget curl" && \
vagrant ssh worker3 -c "sudo dnf install -y oracle-gluster-release-el8 && sudo dnf install -y glusterfs-server glusterfs-client git vim wget curl"

vagrant ssh worker1 -c "sudo firewall-cmd --add-service=glusterfs --permanent && sudo firewall-cmd --reload" && \
vagrant ssh worker2 -c "sudo firewall-cmd --add-service=glusterfs --permanent && sudo firewall-cmd --reload" && \
vagrant ssh worker3 -c "sudo firewall-cmd --add-service=glusterfs --permanent && sudo firewall-cmd --reload"

vagrant ssh worker1 -c "sudo cp /etc/olcne/pki/production/ca.cert /etc/ssl/glusterfs.ca && sudo cp /etc/olcne/pki/production/node.key /etc/ssl/glusterfs.key && sudo cp /etc/olcne/pki/production/node.cert /etc/ssl/glusterfs.pem && sudo touch /var/lib/glusterd/secure-access" && \
vagrant ssh worker2 -c "sudo cp /etc/olcne/pki/production/ca.cert /etc/ssl/glusterfs.ca && sudo cp /etc/olcne/pki/production/node.key /etc/ssl/glusterfs.key && sudo cp /etc/olcne/pki/production/node.cert /etc/ssl/glusterfs.pem && sudo touch /var/lib/glusterd/secure-access" && \
vagrant ssh worker3 -c "sudo cp /etc/olcne/pki/production/ca.cert /etc/ssl/glusterfs.ca && sudo cp /etc/olcne/pki/production/node.key /etc/ssl/glusterfs.key && sudo cp /etc/olcne/pki/production/node.cert /etc/ssl/glusterfs.pem && sudo touch /var/lib/glusterd/secure-access"

vagrant ssh worker1 -c "sudo systemctl enable --now glusterd.service" && \
vagrant ssh worker2 -c "sudo systemctl enable --now glusterd.service" && \
vagrant ssh worker3 -c "sudo systemctl enable --now glusterd.service"

vagrant ssh worker1 -c "sudo systemctl status glusterd.service" && \
vagrant ssh worker2 -c "sudo systemctl status glusterd.service" && \
vagrant ssh worker3 -c "sudo systemctl status glusterd.service"

vagrant ssh master1 -c "sudo dnf install -y oracle-gluster-release-el8 && sudo dnf install -y heketi heketi-client"

vagrant ssh master1 -c "sudo firewall-cmd --add-port=8080/tcp --permanent && sudo firewall-cmd --reload"

vagrant ssh master1 -c "sudo ssh-keygen -m PEM -t rsa -b 4096 -q -f /etc/heketi/heketi_key -N ''"

vagrant ssh master1 -c "sudo ssh-copy-id -i /etc/heketi/heketi_key.pub worker1 && sudo ssh-copy-id -i /etc/heketi/heketi_key.pub worker2 && sudo ssh-copy-id -i /etc/heketi/heketi_key.pub worker3"

vagrant ssh master1 -c "sudo chown heketi:heketi /etc/heketi/heketi_key*"

vagrant ssh master1 -c "sudo mv /etc/heketi/heketi.json /etc/heketi/old-heketi.json && sudo cp /vagrant/scripts/heketi.json /etc/heketi/heketi.json"

vagrant ssh master1 -c "sudo systemctl enable --now heketi.service"

vagrant ssh master1 -c "curl localhost:8080/hello"

vagrant ssh master1 -c "sudo cp /vagrant/scripts/topology.json /etc/heketi/topology.json"

vagrant ssh master1 -c "heketi-cli --user admin --secret "gprm8350" topology load --json=/etc/heketi/topology.json"

vagrant ssh master1 -c "heketi-cli --secret "gprm8350" --user admin node list"

vagrant ssh master1 -c "heketi-cli --secret "gprm8350" --user admin cluster list && heketi-cli --secret "gprm8350" --user admin topology info && heketi-cli --secret "gprm8350" --user admin volume list"

# vagrant ssh master1 -c "heketi-cli --secret "gprm8350" --user admin volume create --size=50 --replica=3"
# vagrant ssh master1 -c "heketi-cli --secret "gprm8350" --user admin volume list"

vagrant ssh master1 -c "kubectl create secret generic heketi-admin --type='kubernetes.io/glusterfs' --from-literal=key='gprm8350' --namespace=default"

vagrant ssh master1 -c 'cat << EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: hyperconverged
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/glusterfs
parameters:
  resturl: "http://master1.vagrant.vm:8080"
  restauthenabled: "true"
  restuser: "admin"
  secretNamespace: "default"
  secretName: "heketi-admin"
EOF'

vagrant ssh master1 -c 'for x in {0..5}; do
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
 name: gluster-pvc-${x}
spec:
 accessModes:
  - ReadWriteMany
 resources:
  requests:
    storage: 10Gi
EOF
done'

vagrant ssh master1 -c "kubectl get pvc"

vagrant ssh master1 -c "heketi-cli --secret "gprm8350" --user admin volume list"
# Volume Id:2ab33ebc348c2c6dcc3819b2691d0267
# vagrant ssh master1 -c "heketi-cli --secret "gprm8350" --user admin volume info 2ab33ebc348c2c6dcc3819b2691d0267"

# Testing
vagrant ssh master1 -c "cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: demo-nginx
  name: demo-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      run: demo-nginx
  template:
    metadata:
      labels:
        run: demo-nginx
    spec:
      containers:
      - image: nginx
        name: demo-nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: demo-nginx-pvc
          mountPath: /usr/share/nginx/html
      volumes:
      - name: demo-nginx-pvc
        persistentVolumeClaim:
          claimName: gluster-pvc-1
EOF"

vagrant ssh master1 -c "kubectl get pod -l run=demo-nginx"

#pod name: demo-nginx-75fd7f5594-bsqf4
# vagrant ssh master1 -c "kubectl exec demo-nginx-75fd7f5594-bsqf4 -ti -- mount -t fuse.glusterfs"
# vagrant ssh worker1 -c "sudo gluster volume status vol_6fec8524bfeedfe8c11e68a61366761a"
