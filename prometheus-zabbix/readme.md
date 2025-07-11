# issue for “cannot use database "zabbix": its "users" table is empty”


```
wget https://cdn.zabbix.com/zabbix/sources/stable/7.4/zabbix-7.4.0.tar.gz
tar zxvf zabbix-7.4.0.tar.gz
cd zabbix-7.4.0/database/mysql
ubuntu@ubuntu:~/docker-compose/prometheus-zabbix/sql/zabbix-7.4.0/database/mysql$ ll
total 46892
drwxr-xr-x 3 ubuntu ubuntu     4096 Jul 11 08:13 ./
drwxr-xr-x 6 ubuntu ubuntu     4096 Jun 30 10:28 ../
-rw-r--r-- 1 ubuntu ubuntu 21802972 Jun 30 10:27 data.sql
-rw-r--r-- 1 ubuntu ubuntu  1978341 Jun 30 10:16 images.sql
-rw-r--r-- 1 ubuntu ubuntu      806 Jun 30 10:16 Makefile.am
-rw-r--r-- 1 ubuntu ubuntu    23191 Jun 30 10:27 Makefile.in
drwxr-xr-x 2 ubuntu ubuntu     4096 Jun 30 10:28 option-patches/
-rw-r--r-- 1 ubuntu ubuntu   202776 Jun 30 10:27 schema.sql
ubuntu@ubuntu:~/docker-compose/prometheus-zabbix/sql/zabbix-7.4.0/database/mysql$ cat schema.sql images.sql data.sql > zabbix.sql
```

```sql
mysql -h 192.168.126.100 -u zabbix -p123456 zabbix
DROP DATABASE zabbix;
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'%';
FLUSH PRIVILEGES;
EXIT;
```


```
mysql -h 192.168.126.100 -u zabbix -p123456 zabbix < zabbix.sql
```

