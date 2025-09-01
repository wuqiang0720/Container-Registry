> [!NOTE]
> [Generate Tokens](https://github.com/settings/tokens/)  
> [OS Configuration](https://github.com/wuqiang0720/Container-Registry/blob/main/Ubuntu-configuration.md)  
> [New SSH key](https://github.com/settings/ssh/new)  
```bash
cd Container-Registry/
git remote -v
git config --global user.email "wuqiang0720@126.com"
ssh-keygen -t ed25519 -C "wuqiang0720@126.com"
cat /root/.ssh/id_ed25519.pub   然后把输出的公钥复制到 GitHub → Settings → SSH and GPG keys → New SSH key
ssh -T git@github.com

git remote -v

git clone --recursive git@github.com:wuqiang0720/Container-Registry.git

git add .
git commit -m "你的提交信息"
git push origin main
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
