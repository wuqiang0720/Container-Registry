```sql
CREATE DATABASE metersphere CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER 'msuser'@'%' IDENTIFIED BY 'mspassword';
GRANT ALL PRIVILEGES ON metersphere.* TO 'msuser'@'%';
FLUSH PRIVILEGES
```
`docker run -d -p 8081:8081 --name=metersphere -v ~/.metersphere/data:/opt/metersphere/data ghcr.io/wuqiang0720/metersphere-ce-allinone`
