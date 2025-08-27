# 使用官方 Golang 镜像作为构建环境
FROM  ghcr.io/wuqiang0720/golang:1.21-alpine AS builder

# 安装必要工具
RUN apk add --no-cache bash git

# 设置工作目录
WORKDIR /app

# 复制源码和本地依赖
COPY main.go .
COPY go.mod .
COPY vendor/ ./vendor/

# 构建插件
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=vendor -o ovs-plugin main.go

# 使用最小镜像运行插件
FROM  ghcr.io/wuqiang0720/alpine:3.20

# 安装必要工具（ip, ovs-vsctl）
RUN apk add --no-cache iproute2 openvswitch bash

# 复制构建好的插件
COPY --from=builder /app/ovs-plugin /usr/local/bin/ovs-plugin

# 创建 Docker 插件 socket 目录
RUN mkdir -p /run/docker/plugins

# 设置工作目录
WORKDIR /run/docker/plugins

# 插件启动命令
CMD ["/usr/local/bin/ovs-plugin"]

