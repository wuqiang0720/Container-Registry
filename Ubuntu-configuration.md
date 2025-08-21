```bash

apt update && apt install -y sssd sssd-ldap libnss-sss libpam-sss ldap-utils sudo-ldap openvswitch-switch docker.io docker-compose

systemctl start openvswitch-switch docker
systemctl enable  openvswitch-switch docker

cat <<EOF > /etc/systemd/system/ovs-br.service
[Unit]
Description=Bring up br_prv and br-int at boot
After=network-online.target openvswitch-switch.service
Wants=network-online.target openvswitch-switch.service
[Service]
Type=oneshot
ExecStart=/usr/bin/ovs-vsctl --may-exist add-br br-int -- set bridge br-int datapath_type=system
ExecStart=/usr/bin/ovs-vsctl --may-exist add-br br_prv -- set bridge br_prv datapath_type=system
ExecStart=/usr/bin/ovs-vsctl --may-exist add-port br-int int-br_prv -- set interface int-br_prv type=patch options:peer=phy-br_prv
ExecStart=/usr/bin/ovs-vsctl --may-exist add-port br_prv phy-br_prv -- set interface phy-br_prv type=patch options:peer=int-br_prv
ExecStart=/usr/sbin/ip link set br_prv up
ExecStart=/usr/sbin/ip link set br-int up
ExecStart=/bin/sh -c "ip addr show dev br_prv | grep -q 192.168.1.1/24 || ip addr add 192.168.1.1/24 dev br_prv"
ExecStart=/bin/bash -c 'docker network inspect macvlan_net >/dev/null 2>&1 || docker network create -d macvlan --subnet=192.168.1.0/24 --gateway=192.168.1.1 -o parent=br-int macvlan_net'
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF

systemctl start ovs-br
systemctl enable ovs-br

cp ~/Container-Registry/ldap/sssd.conf /etc/sssd/sssd.conf
cp ~/Container-Registry/ldap/sudo-ldap.conf /etc/sudo-ldap.conf

chmod 600 /etc/sssd/sssd.conf

echo "session required pam_mkhomedir.so skel=/etc/skel/ umask=0022" >> /etc/pam.d/common-session

systemctl restart sssd

# 允许 br_prv 到外网接口的转发
iptables -A FORWARD -i br_prv -o eth0 -j ACCEPT

# 允许外网接口返回流量到 br_prv
iptables -A FORWARD -i eth0 -o br_prv -m state --state ESTABLISHED,RELATED -j ACCEPT

# 然后确认 NAT 规则正确：
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eth0 -j MASQUERADE

```
