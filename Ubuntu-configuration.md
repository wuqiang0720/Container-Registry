```bash
apt install -y sssd sssd-ldap libnss-sss libpam-sss ldap-utils sudo-ldap openvswitch-switch

docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=br-int \
  macvlan_net

cat <<EOF > /etc/netplan/50-cloud-init.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      addresses: [192.168.125.100/24]
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
      routes:
        - to: 0.0.0.0/0
          via: 192.168.125.1
EOF

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

ovs-vsctl add-br br-int -- set bridge br-int datapath_type=system
ovs-vsctl add-br br_prv -- set bridge br_prv datapath_type=system



ovs-vsctl add-port br-int int-br_prv \
  -- set interface int-br_prv type=patch options:peer=phy-br_prv


ovs-vsctl add-port br_prv phy-br_prv \
  -- set interface phy-br_prv type=patch options:peer=int-br_prv
netplan apply

```
