#pipework br-int suse15.5 192.168.1.50/24@192.168.1.1
pipework br-int mariadb-node1 192.168.1.121/24@192.168.1.1
pipework br-int mariadb-node2 192.168.1.232/24@192.168.1.1
pipework br-int mariadb-node3 192.168.1.123/24@192.168.1.1
pipework br-int mariadb-haproxy 192.168.1.124/24@192.168.1.1
pipework br-int mariadb-phpadmin 192.168.1.125/24@192.168.1.1
pipework br-int cadvisor 192.168.1.9/24@192.168.1.1
pipework br-int prometheus 192.168.1.10/24@192.168.1.1
pipework br-int collectd 192.168.1.12/24@192.168.1.1


ovs-docker add-port br-int eth1 mariadb-node1 --ipaddress=192.168.1.121/24 --gateway=192.168.1.1
ovs-docker add-port br-int eth1 mariadb-node2 --ipaddress=192.168.1.232/24 --gateway=192.168.1.1
ovs-docker add-port br-int eth1 mariadb-node3 --ipaddress=192.168.1.123/24 --gateway=192.168.1.1
ovs-docker add-port br-int eth1 mariadb-haproxy --ipaddress=192.168.1.124/24 --gateway=192.168.1.1
ovs-docker add-port br-int eth1 mariadb-phpadmin --ipaddress=192.168.1.125/24 --gateway=192.168.1.1
ovs-docker add-port br-int eth1 cadvisor --ipaddress=192.168.1.9/24 --gateway=192.168.1.1
ovs-docker add-port br-int eth1 prometheus --ipaddress=192.168.1.10/24 --gateway=192.168.1.1
ovs-docker add-port br-int eth1 collectd --ipaddress=192.168.1.12/24 --gateway=192.168.1.1


#docker network disconnect macvlan_net suse15.5
docker network disconnect macvlan_net mariadb-node1
docker network disconnect macvlan_net mariadb-node2
docker network disconnect macvlan_net mariadb-node3
docker network disconnect macvlan_net mariadb-haproxy
docker network disconnect macvlan_net mariadb-phpadmin
docker network disconnect macvlan_net cadvisor
docker network disconnect macvlan_net prometheus
docker network disconnect macvlan_net collectd
