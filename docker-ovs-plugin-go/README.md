```
wget https://dl.google.com/go/go1.21.0.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

root@ubuntu:~/Container-Registry/docker-ovs-plugin-go# GO111MODULE=off CGO_ENABLED=0 GOOS=linux GOARCH=amd64 /usr/local/go/bin/go build -o ovs-plugin main.go
main.go:10:5: cannot find package "github.com/docker/go-plugins-helpers/network" in any of:
        /usr/local/go/src/github.com/docker/go-plugins-helpers/network (from $GOROOT)
        /root/go/src/github.com/docker/go-plugins-helpers/network (from $GOPATH)
root@ubuntu:~/Container-Registry/docker-ovs-plugin-go# mkdir -p /root/go/src/github.com/docker/go-plugins-helpers
root@ubuntu:~/Container-Registry/docker-ovs-plugin-go# git clone git@github.com:docker/go-plugins-helpers.git /root/go/src/github.com/docker/go-plugins-helpers
...
root@ubuntu:~/Container-Registry/docker-ovs-plugin-go# GO111MODULE=off CGO_ENABLED=0 GOOS=linux GOARCH=amd64 /usr/local/go/bin/go build -o ovs-plugin main.go
/root/go/src/github.com/docker/go-plugins-helpers/sdk/unix_listener_systemd.go:10:2: cannot find package "github.com/coreos/go-systemd/activation" in any of:
        /usr/local/go/src/github.com/coreos/go-systemd/activation (from $GOROOT)
        /root/go/src/github.com/coreos/go-systemd/activation (from $GOPATH)
/root/go/src/github.com/docker/go-plugins-helpers/sdk/tcp_listener.go:8:2: cannot find package "github.com/docker/go-connections/sockets" in any of:
        /usr/local/go/src/github.com/docker/go-connections/sockets (from $GOROOT)
        /root/go/src/github.com/docker/go-connections/sockets (from $GOPATH)
root@ubuntu:~/Container-Registry/docker-ovs-plugin-go# git clone git@github.com:coreos/go-systemd.git /root/go/src/github.com/coreos/go-systemd/
root@ubuntu:~/Container-Registry/docker-ovs-plugin-go# mkdir -p /root/go/src/github.com/coreos/go-systemd/ /root/go/src/github.com/docker/go-connections/
root@ubuntu:~/Container-Registry/docker-ovs-plugin-go# git clone git@github.com:coreos/go-systemd.git /root/go/src/github.com/coreos/go-systemd/
root@ubuntu:~/Container-Registry/docker-ovs-plugin-go# git clone git@github.com:docker/go-connections.git /root/go/src/github.com/docker/go-connections/
root@ubuntu:~/Container-Registry/docker-ovs-plugin-go# GO111MODULE=off CGO_ENABLED=0 GOOS=linux GOARCH=amd64 /usr/local/go/bin/go build -o ovs-plugin main.go
root@ubuntu:~/Container-Registry/docker-ovs-plugin-go#



docker build -t rootfsimage .
id=$(docker create rootfsimage true) # id was cd851ce43a403 when the image was created
mkdir -p rootfs
docker export "$id" | sudo tar -x -C rootfs
docker rm -vf "$id"
docker rmi rootfsimage
ls -ld rootfs/


docker plugin create ghcr.io/wuqiang0720/ovs .
docker plugin enable ghcr.io/wuqiang0720/ovs


# 进入plugin查看或者调试
runc --root /run/docker/runtime-runc/plugins.moby exec  3dfee2aeb864051e5ba44a7452927df173a17238c871e666c4ba26b882c52d21 ip a









```
