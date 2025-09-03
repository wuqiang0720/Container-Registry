FROM ghcr.io/wuqiang0720/alpine:3.20
RUN apk add --no-cache openvswitch iproute2 bash
COPY ovs-plugin /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/ovs-plugin"]

