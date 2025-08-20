```bash

apt update && apt install -y sssd sssd-ldap libnss-sss libpam-sss ldap-utils sudo-ldap openvswitch-switch docker.io docker-compose

systemctl start openvswitch-switch docker
systemctl enable  openvswitch-switch docker

docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=br-int \
  macvlan_net

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
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl start ovs-br
systemctl enable ovs-br

cat <<EOF >  /etc/sssd/sssd.conf
[sssd]
config_file_version = 2
services = nss, pam，sudo
domains = LDAP
[nss]
reconnection_retries = 3
[pam]
reconnection_retries = 3
[domain/LDAP]
id_provider = ldap
auth_provider = ldap
ldap_uri = ldap://openldap
ldap_search_base = dc=hds8000,dc=ericsson,dc=com
ldap_sudo_search_base = ou=Sudoers,dc=hds8000,dc=ericsson,dc=com
cache_credentials = True
ldap_default_bind_dn = cn=admin,dc=hds8000,dc=ericsson,dc=com
ldap_default_authtok = admin
ldap_auth_disable_tls_never_use_in_production = true
EOF
chmod 600 /etc/sssd/sssd.conf

cat <<EOF > /etc/sudo-ldap.conf
host openldap
base dc=hds8000,dc=ericsson,dc=com
uri ldap://openldap
sudoers_base ou=Sudoers,dc=hds8000,dc=ericsson,dc=com
binddn cn=admin,dc=hds8000,dc=ericsson,dc=com
bindpw admin
ldap_tls_reqcert = demand
EOF
echo "session required pam_mkhomedir.so skel=/etc/skel/ umask=0022" >> /etc/pam.d/common-session

systemctl restart sssd


```
