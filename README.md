> [!NOTE]
> [Generate Tokens](https://github.com/settings/tokens/)  
> [OS Configuration](https://github.com/wuqiang0720/Container-Registry/blob/main/Ubuntu-configuration.md)  
> [New SSH key](https://github.com/settings/ssh/new)  
```bash
git remote -v
git config --global user.email "wuqiang0720@126.com"
ssh-keygen -t ed25519 -C "wuqiang0720@126.com"
cat /root/.ssh/id_ed25519.pub   然后把输出的公钥复制到 GitHub → Settings → SSH and GPG keys → New SSH key
ssh -T git@github.com

git remote -v

git clone --recursive git@github.com:wuqiang0720/Container-Registry.git

git add .
git commit -m "你的提交信息"

git branch
git push origin main
```

```bash

apt update && apt install -y sssd sssd-ldap libnss-sss libpam-sss ldap-utils sudo-ldap openvswitch-switch docker.io docker-compose

systemctl start openvswitch-switch docker
systemctl enable  openvswitch-switch docker
ovs-vsctl set-manager ptcp:6640
```
[点击下载ovs-config_v1.deb](https://github.com/wuqiang0720/Container-Registry/raw/refs/heads/main/galera/deb-build/ovs-config_v1.deb)
```


#安装docker-ovs-plugin
docker plugin install ghcr.io/wuqiang0720/ovs:latest --grant-all-permissions

dpkg -i ovs-config_v1.deb
systemctl start ovs-conf
systemctl enable ovs-conf



cp ~/Container-Registry/ldap/sssd.conf /etc/sssd/sssd.conf
cp ~/Container-Registry/ldap/sudo-ldap.conf /etc/sudo-ldap.conf

chmod 600 /etc/sssd/sssd.conf
echo "192.168.1.2 openldap-server" >> /etc/hosts
echo "session required pam_mkhomedir.so skel=/etc/skel/ umask=0022" >> /etc/pam.d/common-session

systemctl restart sssd

# 允许 br_prv 到外网接口的转发
iptables -A FORWARD -i br_prv -o eth0 -j ACCEPT

# 允许外网接口返回流量到 br_prv
iptables -A FORWARD -i eth0 -o br_prv -m state --state ESTABLISHED,RELATED -j ACCEPT

# 然后确认 NAT 规则正确：
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eth0 -j MASQUERADE

```






# 我的 Docker 镜像集合

## 📦 镜像列表

### 1. subnet-tool
- 镜像地址：`ghcr.io/wuqiang0720/subnetcalc:latest`
- 说明：用于子网划分计算，基于 Flask 的 Web 应用
- 启动方式：
  ```bash
  docker run -d -p 8080:80 ghcr.io/wuqiang0720/subnetcalc:latest

### 2. ldap+PHPadmin 
  ```bash
  root@ubuntu:~# docker-compose -f ~/Container-Registry/ldap/docker-compose.yaml up -d
  Creating volume "ldapphpadmin_openldap_data" with default driver
  Creating volume "ldapphpadmin_openldap_conf" with default driver
  Creating volume "ldapphpadmin_phpldapadmin_data" with default driver
  Pulling openldap (ghcr.io/wuqiang0720/openldap:latest)...
  latest: Pulling from wuqiang0720/openldap
  45b42c59be33: Pulling fs layer
  ae7fb8f59730: Download complete
  55443d9da5d5: Waiting
  edbb56ba2f49: Waiting
  8690d28b09a7: Waiting
  7f3b6edb2b51: Waiting
  176dedf70b8e: Waiting

  ```
### 3. Galera+mariadb+haproxy
```
root@ubuntu:~# docker-compose -f ~/Container-Registry/galera/docker-compose.yaml up -d
Creating volume "galera_mariadb_data1" with default driver
Creating volume "galera_mariadb_data2" with default driver
Creating volume "galera_mariadb_data3" with default driver
Pulling mariadb-node1 (ghcr.io/wuqiang0720/mariadb-galera:10.5data)...
10.5data: Pulling from wuqiang0720/mariadb-galera
82c25e98af0e: Pulling fs layer
78271e8eb0d9: Download complete
1f0785828d8a: Download complete
ac32331704ce: Download complete
```    
