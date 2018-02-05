export http_proxy="{{ http_proxy }}"
export https_proxy="{{ https_proxy }}"
export no_proxy="localhost, 127.0.0.1, {{ hostvars[inventory_hostname]['ansible_ens33']['ipv4']['address'] }}, {{ service_cidr }}, {{ pod_network_cidr }}"
