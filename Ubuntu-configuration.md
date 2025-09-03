```bash

apt update && apt install -y sssd sssd-ldap libnss-sss libpam-sss ldap-utils sudo-ldap openvswitch-switch docker.io docker-compose

systemctl start openvswitch-switch docker
systemctl enable  openvswitch-switch docker
ovs-vsctl set-manager ptcp:6640
```
dpkg -i [ovs-config_v1.deb](https://github.com/wuqiang0720/Container-Registry/raw/refs/heads/main/galera/deb-build/ovs-config_v1.deb)
```
systemctl start ovs-conf
systemctl enable ovs-conf
docker plugin install ghcr.io/wuqiang0720/ovs:latest --grant-all-permissions


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
