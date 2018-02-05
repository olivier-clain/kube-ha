#!/bin/bash

# local machine ip address
export K8SHA_IPLOCAL={{ hostvars[inventory_hostname]['ansible_eth0']['ipv4']['address'] }}


# local machine etcd name, options: etcd1, etcd2, etcd3
export K8SHA_ETCDNAME={% if inventory_hostname == 'master-1' %}etcd-1{% else %}etcd-2{% endif %}

# local machine keepalived state config, options: MASTER, BACKUP. One keepalived cluster only one MASTER, other's are BACKUP
export K8SHA_KA_STATE={% if inventory_hostname == 'master-1' %}MASTER{% else %}BACKUP{% endif %}

# local machine keepalived priority config, options: 102, 101, 100. MASTER must 102
export K8SHA_KA_PRIO={% if inventory_hostname == 'master-1' %}102{% elif inventory_hostname == 'master-2' %}101{% else %}100{% endif %}

# local machine keepalived network interface name config, for example: eth0
export K8SHA_KA_INTF=eth1

#######################################
# all masters settings below must be same
#######################################

# master keepalived virtual ip address
export K8SHA_IPVIRTUAL={{ keepalived.ip }}

# master01 ip address
export K8SHA_IP1={{ hostvars[groups['masters'][0]]['ansible_eth0']['ipv4']['address'] }}

# master02 ip address
export K8SHA_IP2={{ hostvars[groups['masters'][1]]['ansible_eth0']['ipv4']['address'] }}


# master01 hostname
export K8SHA_HOSTNAME1={{ hostvars[groups['masters'][0]]['ansible_hostname'] }}

# master02 hostname
export K8SHA_HOSTNAME2={{ hostvars[groups['masters'][1]]['ansible_hostname'] }}

# keepalived auth_pass config, all masters must be same
export K8SHA_KA_AUTH=4cdf7dc3b4c90194d1600c483e10ad1d

# kubernetes cluster token, you can use 'kubeadm token generate' to get a new one
export K8SHA_TOKEN=7f276c.0741d82a5337f526

# kubernetes CIDR pod subnet, if CIDR pod subnet is "10.244.0.0/16" please set to "10.244.0.0\\/16"
export K8SHA_CIDR=10.244.0.0\\/16

# calico network settings, set a reachable ip address for the cluster network interface, for example you can use the gateway ip address
# export K8SHA_CALICO_REACHABLE_IP=10.0.2.2

##############################
# please do not modify anything below
##############################

# set etcd cluster docker-compose.yaml file
sed \
-e "s/K8SHA_ETCDNAME/$K8SHA_ETCDNAME/g" \
-e "s/K8SHA_IPLOCAL/$K8SHA_IPLOCAL/g" \
-e "s/K8SHA_IP1/$K8SHA_IP1/g" \
-e "s/K8SHA_IP2/$K8SHA_IP2/g" \
etcd/docker-compose.yaml.tpl > etcd/docker-compose.yaml

echo 'set etcd cluster docker-compose.yaml file success: etcd/docker-compose.yaml'

# set keepalived config file
mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak

cp keepalived/check_apiserver.sh /etc/keepalived/

sed \
-e "s/K8SHA_KA_STATE/$K8SHA_KA_STATE/g" \
-e "s/K8SHA_KA_INTF/$K8SHA_KA_INTF/g" \
-e "s/K8SHA_IPLOCAL/$K8SHA_IPLOCAL/g" \
-e "s/K8SHA_KA_PRIO/$K8SHA_KA_PRIO/g" \
-e "s/K8SHA_IPVIRTUAL/$K8SHA_IPVIRTUAL/g" \
-e "s/K8SHA_KA_AUTH/$K8SHA_KA_AUTH/g" \
keepalived/keepalived.conf.tpl > /etc/keepalived/keepalived.conf

echo 'set keepalived config file success: /etc/keepalived/keepalived.conf'

# set nginx load balancer config file
sed \
-e "s/K8SHA_IP1/$K8SHA_IP1/g" \
-e "s/K8SHA_IP2/$K8SHA_IP2/g" \
nginx-lb/nginx-lb.conf.tpl > nginx-lb/nginx-lb.conf

echo 'set nginx load balancer config file success: nginx-lb/nginx-lb.conf'

# set kubeadm init config file
sed \
-e "s/K8SHA_HOSTNAME1/$K8SHA_HOSTNAME1/g" \
-e "s/K8SHA_HOSTNAME2/$K8SHA_HOSTNAME2/g" \
-e "s/K8SHA_IP1/$K8SHA_IP1/g" \
-e "s/K8SHA_IP2/$K8SHA_IP2/g" \
-e "s/K8SHA_IPVIRTUAL/$K8SHA_IPVIRTUAL/g" \
-e "s/K8SHA_TOKEN/$K8SHA_TOKEN/g" \
-e "s/K8SHA_CIDR/$K8SHA_CIDR/g" \
kubeadm-init.yaml.tpl > kubeadm-init.yaml

echo 'set kubeadm init config file success: kubeadm-init.yaml'

# set calico deployment config file
export K8SHA_ETCDS=http:\\/\\/${K8SHA_IP1}:2379,http:\\/\\/${K8SHA_IP2}:2379,http:\\/\\/${K8SHA_IP3}:2379

# sed \
# -e "s/K8SHA_ETCDS/$K8SHA_ETCDS/g" \
# -e "s/K8SHA_CIDR/$K8SHA_CIDR/g" \
# -e "s/K8SHA_CALICO_REACHABLE_IP/$K8SHA_CALICO_REACHABLE_IP/g" \
# kube-calico/calico.yaml.tpl > kube-calico/calico.yaml
#
# echo 'set calico deployment config file success: kube-calico/calico.yaml'
