
sudo apt install -y sssd sssd-ldap libnss-sss libpam-sss ldap-utils

chmod 600 /etc/sssd/sssd.conf


ubuntu@ubuntu:~/docker-compose/ldap$ docker-compose up -d


docker exec -it openldap

自动生成用户家目录:
```
ubuntu@ubuntu:~/docker-compose/ldap$ cat /etc/pam.d/common-session | grep pam_mkhomedir.so
session required pam_mkhomedir.so skel=/etc/skel/ umask=0022
```

