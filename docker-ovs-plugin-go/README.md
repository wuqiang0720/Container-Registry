```
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o ovs-plugin main.go

docker plugin install ghcr.io/wuqiang0720/ovs:latest --grant-all-permissions



```
