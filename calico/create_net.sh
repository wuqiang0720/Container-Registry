#!/bin/bash
# create_net.sh
# 用法: bash create_net.sh <容器名或ID> <指定IP>

CNI_BIN=/opt/cni/bin
CNI_CONF=/etc/cni/net.d/10-calico.conf

if [ ! -f "$CNI_BIN/calico" ]; then
  echo "❌ Calico CNI 插件未找到，请确保已安装到 $CNI_BIN"
  exit 1
fi

CID=$1
IP=$2

if [ -z "$CID" ] || [ -z "$IP" ]; then
  echo "用法: $0 <docker-container-id或容器名> <指定IP地址>"
  exit 1
fi

# 获取容器PID
PID=$(docker inspect -f '{{.State.Pid}}' "$CID" 2>/dev/null)
if ! [[ "$PID" =~ ^[0-9]+$ ]] || [ "$PID" -eq 0 ]; then
  echo "❌ 获取容器PID失败，容器 $CID 可能未启动或不存在"
  exit 1
fi

NETNS="/proc/$PID/ns/net"
if [ ! -e "$NETNS" ]; then
  echo "❌ 网络命名空间文件不存在: $NETNS"
  exit 1
fi

echo "ℹ️ 为容器 $CID (PID: $PID) 注入 Calico 网络，指定IP: $IP"

# 执行 CNI ADD
CNI_COMMAND=ADD \
CNI_CONTAINERID=$CID \
CNI_NETNS=$NETNS \
CNI_IFNAME=eth0 \
CNI_ARGS="IP=$IP" \
CNI_PATH=$CNI_BIN \
$CNI_BIN/calico < $CNI_CONF

if [ $? -eq 0 ]; then
  echo "✅ 已为容器 $CID 注入 Calico 网络，IP: $IP"
else
  echo "❌ 为容器 $CID 注入 Calico 网络失败"
  exit 1
fi
