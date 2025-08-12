```bash
nsenter -n -t $(docker inspect -f '{{.State.Pid}}' mariadb-node1) ip addr show
nsenter -n -t $(docker inspect -f '{{.State.Pid}}' calico-ubuntu) ip addr show

calicoctl get ippool -o wide
calicoctl get workloadendpoints

export ETCD_ENDPOINTS=http://etcd:2379


calicoctl apply -f - <<EOF
apiVersion: projectcalico.org/v3
kind: IPPool
metadata:
  name: custom-ippool
  labels:
    type: ippool
spec:
  cidr: 192.168.1.0/24
  blockSize: 24
  vxlanMode: Always
  ipipMode: Never
  natOutgoing: true
  disabled: false
  nodeSelector: "all()"
EOF
```
