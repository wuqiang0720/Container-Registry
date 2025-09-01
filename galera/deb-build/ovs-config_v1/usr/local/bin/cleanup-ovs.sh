#!/bin/bash
# cleanup-ovs.sh
# 停止 OVS 网络并清理桥、端口和 Docker 网络

set -e

BRIDGES=("br-int" "br_prv")
DOCKER_NET="ovs-net"

echo "==== 停止容器相关网络 ===="
# 删除 Docker 网络（如果存在）
if docker network inspect "$DOCKER_NET" >/dev/null 2>&1; then
    echo "Removing Docker network $DOCKER_NET"
    docker network rm "$DOCKER_NET" || true
fi

echo "==== 删除 OVS 桥上的端口 ===="
for br in "${BRIDGES[@]}"; do
    if ovs-vsctl br-exists "$br"; then
        for port in $(ovs-vsctl list-ports "$br"); do
            echo "Deleting port $port from bridge $br"
            ovs-vsctl --if-exists del-port "$br" "$port"
        done
    fi
done

echo "==== 删除 OVS 桥 ===="
for br in "${BRIDGES[@]}"; do
    ovs-vsctl --if-exists del-br "$br"
done

echo "==== 清理残留 veth 接口 ===="
# 删除所有 DOWN 或 LOWERLAYERDOWN 的 veth，不删物理网卡
for iface in $(ip -o link show | awk -F': ' '{print $2}'); do
    state=$(cat /sys/class/net/$iface/operstate 2>/dev/null)
    if [[ "$state" == "down" ]] && [[ ! "$iface" =~ ^(lo|eth|eno|enp|br-.*)$ ]]; then
        echo "Deleting residual interface $iface"
        ip link delete "$iface" 2>/dev/null || true
    fi
done

echo "==== OVS 清理完成 ===="

