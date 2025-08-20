[Generate Tokens](https://github.com/settings/tokens/)

`git clone --recursive https://github.com/wuqiang0720/Container-Registry.git`
# 我的 Docker 镜像集合

## 📦 镜像列表

### 1. subnet-tool
- 镜像地址：`ghcr.io/wuqiang0720/subnetcalc:latest`
- 说明：用于子网划分计算，基于 Flask 的 Web 应用
- 启动方式：
  ```bash
  docker run -d -p 8080:80 ghcr.io/wuqiang0720/subnetcalc:latest

### 2. ldap+PHPadmin 
- 镜像地址：
    `ghcr.io/wuqiang0720/phpldapadmin:https`
    `ghcr.io/wuqiang0720/openldap:latest`
- 说明：容器部署ldapserver，并可以https访问
- 启动方式：
  ```bash
  ubuntu@ubuntu:~/docker-compose/ldap+phpadmin$ cat docker-compose.yaml
  buntu@ubuntu:~/docker-compose/ldap+phpadmin$ docker compose up -d
  [+] Running 3/3
   ✔ Network ldapphpadmin_default  Created                                                                                                                        0.0s
   ✔ Container openldap            Started                                                                                                                        0.3s
   ✔ Container phpldapadmin        Started                                                                                                                        0.5s
  ubuntu@ubuntu:~/docker-compose/ldap+phpadmin$ docker ps
  CONTAINER ID   IMAGE                                       COMMAND                  CREATED          STATUS          PORTS                                                                                NAMES
  f7cd7d88f66a   ghcr.io/wuqiang0720/phpldapadmin:https      "/container/tool/run"    4 seconds ago    Up 3 seconds    0.0.0.0:8080->80/tcp, [::]:8080->80/tcp, 0.0.0.0:6443->443/tcp, [::]:6443->443/tcp   phpldapadmin
  4d5b8b9d070d   ghcr.io/wuqiang0720/openldap:latest         "/container/tool/run"    4 seconds ago    Up 3 seconds    0.0.0.0:389->389/tcp, [::]:389->389/tcp, 0.0.0.0:636->636/tcp, [::]:636->636/tcp     openldap
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
