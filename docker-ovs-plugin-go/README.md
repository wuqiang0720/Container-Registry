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









```
