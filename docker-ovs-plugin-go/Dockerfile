FROM ghcr.io/wuqiang0720/alpine:3.20 AS builder
WORKDIR /app

# 安装 Go
COPY go1.22.6.linux-amd64.tar.gz /tmp/
RUN tar -C /usr/local -xzf /tmp/go1.22.6.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:$PATH"

# 复制源码
COPY go.mod ./ 
COPY mux ./mux
COPY . .

# 构建静态二进制
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GOFLAGS="-mod=mod" go build -o ovs-plugin main.go

FROM ghcr.io/wuqiang0720/alpine:3.20
RUN apk add --no-cache iproute2 openvswitch
COPY --from=builder /app/ovs-plugin /usr/local/bin/
RUN mkdir -p /run/docker/plugins && chmod 666 /run/docker/plugins
ENTRYPOINT ["/usr/local/bin/ovs-plugin"]

