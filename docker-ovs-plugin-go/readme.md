```
docker build -f build.Dockerfile -t ovs:driver .
cid=$(docker create ovs:driver)
docker export "$cid" | tar -C rootfs -xvf -
docker rm "$cid"
docker plugin create ovs:driver .

docker plugin enable ovs:driver 
docker plugin list
docker plugin rm ovs:driver


  
  
docker plugin inspect ovs:driver --format '{{.PluginReference}}'






docker rm --force suse15.5-ovs
docker network rm ovs-net
docker plugin disable ovs:driver
docker plugin rm ovs:driver

vim .....

docker build -t ovs-plugin-py:latest .
docker plugin create ovs:driver .
docker plugin enable ovs:driver
docker network create \
  -d ovs:driver \
  --subnet=192.168.2.0/24 \
  --gateway=192.168.2.1 \
  ovs-net
  

docker run -dit --name suse15.5-ovs --network none --entrypoint /bin/bash ghcr.io/wuqiang0720/suse/sle15:15.5


curl --unix-socket /run/docker/plugins/ovs.sock \
     -H "Content-Type: application/json" \
     -d '{
           "NetworkID": "123456789",
           "EndpointID": "123456789",
           "Interface": {"Address": "192.168.2.50/24"},
           "Options": {}
         }' \
     http://localhost/NetworkDriver.CreateEndpoint
	 

wget https://dl.google.com/go/go1.22.6.linux-amd64.tar.gz
git clone git@github.com:gorilla/mux.git

docker build -t ovs-plugin-go .


```
