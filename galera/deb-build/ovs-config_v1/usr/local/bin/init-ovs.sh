#!/bin/bash
# init-ovs.sh

set -e

# 创建 OVS 桥
ovs-vsctl --may-exist add-br br-int -- set bridge br-int datapath_type=system
ovs-vsctl --may-exist add-br br_prv -- set bridge br_prv datapath_type=system

# 创建 patch 端口
ovs-vsctl --may-exist add-port br-int int-br_prv -- set interface int-br_prv type=patch options:peer=phy-br_prv
ovs-vsctl --may-exist add-port br_prv phy-br_prv -- set interface phy-br_prv type=patch options:peer=int-br_prv

# 启动网桥
ip link set br_prv up
ip link set br-int up

# 配置 IP
ip addr show dev br_prv | grep -q 192.168.1.1/24 || ip addr add 192.168.1.1/24 dev br_prv

# 创建 Docker 网络
docker network inspect ovs-net >/dev/null 2>&1 || docker network create -d ghcr.io/wuqiang0720/ovs:latest --subnet=192.168.1.0/24 --gateway=192.168.1.1 -o parent=br-int ovs-net

# 清空 br-int 上的 IP（如果需要）
ip addr flush br-int

