package main

import (
	"log"
	"os/exec"

	"github.com/docker/go-plugins-helpers/network"
)

const OVS_BRIDGE = "br-int"

// 简单执行命令并打印失败日志
func sh(cmd ...string) {
	out, err := exec.Command(cmd[0], cmd[1:]...).CombinedOutput()
	if err != nil {
		log.Printf("cmd %v failed: %v, output: %s", cmd, err, string(out))
	}
}

// 由 EndpointID 派生出宿主侧/容器侧接口名（长度取前7位，易读避免过长）
func ifNames(eid string) (hostIf, contIf string) {
	base := eid
	if len(base) > 7 {
		base = eid[:7]
	}
	hostIf = "veth" + base + "h"
	contIf = "veth" + base + "c"
	return
}

// OVSNetworkDriver 实现 network.Driver 全量接口
type OVSNetworkDriver struct{}

// 能力：本地作用域
func (d *OVSNetworkDriver) GetCapabilities() (*network.CapabilitiesResponse, error) {
	return &network.CapabilitiesResponse{Scope: network.LocalScope}, nil
}

// 网络生命周期（按需实现，这里仅记录日志）
func (d *OVSNetworkDriver) AllocateNetwork(r *network.AllocateNetworkRequest) (*network.AllocateNetworkResponse, error) {
	log.Printf("AllocateNetwork: %+v\n", r)
	return &network.AllocateNetworkResponse{Options: map[string]string{}}, nil
}
func (d *OVSNetworkDriver) FreeNetwork(r *network.FreeNetworkRequest) error {
	log.Printf("FreeNetwork: %+v\n", r)
	return nil
}
func (d *OVSNetworkDriver) CreateNetwork(r *network.CreateNetworkRequest) error {
	log.Printf("CreateNetwork: %+v\n", r)
	return nil
}
func (d *OVSNetworkDriver) DeleteNetwork(r *network.DeleteNetworkRequest) error {
	log.Printf("DeleteNetwork: %+v\n", r)
	return nil
}

// 端点生命周期
func (d *OVSNetworkDriver) CreateEndpoint(r *network.CreateEndpointRequest) (*network.CreateEndpointResponse, error) {
	log.Printf("CreateEndpoint: %+v\n", r)
	// 这里不创建 veth，对应的链路在 Join() 中创建（那时有 SandboxKey，可以交还给 libnetwork 重命名/迁移）
	return &network.CreateEndpointResponse{
		Interface: &network.EndpointInterface{}, // 如需返回 MAC/IP，可在此填充
	}, nil
}

func (d *OVSNetworkDriver) DeleteEndpoint(r *network.DeleteEndpointRequest) error {
	log.Printf("DeleteEndpoint: %+v\n", r)
	// 清理逻辑主要在 Leave()，这里通常可不处理
	return nil
}

func (d *OVSNetworkDriver) EndpointInfo(r *network.InfoRequest) (*network.InfoResponse, error) {
	log.Printf("EndpointInfo: %+v\n", r)
	return &network.InfoResponse{
		Value: map[string]string{"ovs-bridge": OVS_BRIDGE},
	}, nil
}

// 加入网络：此处创建 veth pair，将宿主端加入 OVS，并把容器端交给 libnetwork 迁移/重命名
func (d *OVSNetworkDriver) Join(r *network.JoinRequest) (*network.JoinResponse, error) {
	log.Printf("Join: %+v\n", r)

	hostIf, contIf := ifNames(r.EndpointID)

	// 创建 veth pair：hostIf <-> contIf
	sh("ip", "link", "add", hostIf, "type", "veth", "peer", "name", contIf)
	sh("ip", "link", "set", hostIf, "up")

	// 将宿主侧口加入 OVS 桥
	sh("ovs-vsctl", "add-port", OVS_BRIDGE, hostIf)

	// 把容器侧口交给 libnetwork：它会将 contIf 迁入容器 netns 并重命名为 ethX
	return &network.JoinResponse{
		InterfaceName: network.InterfaceName{
			SrcName:   contIf,
			DstPrefix: "eth",
		},
	}, nil
}

func (d *OVSNetworkDriver) Leave(r *network.LeaveRequest) error {
	log.Printf("Leave: %+v\n", r)

	hostIf, _ := ifNames(r.EndpointID)

	// 从 OVS 移除并删除 veth（删除一端会连带另一端）
	sh("ovs-vsctl", "del-port", OVS_BRIDGE, hostIf)
	sh("ip", "link", "del", hostIf)

	return nil
}

// 节点发现（可选，swarm/kv 发现场景），这里做 no-op
func (d *OVSNetworkDriver) DiscoverNew(n *network.DiscoveryNotification) error {
	log.Printf("DiscoverNew: %+v\n", n)
	return nil
}
func (d *OVSNetworkDriver) DiscoverDelete(n *network.DiscoveryNotification) error {
	log.Printf("DiscoverDelete: %+v\n", n)
	return nil
}

// 四层外部连通性（如需要 DNAT/ACL 可在此编程），此处 no-op
func (d *OVSNetworkDriver) ProgramExternalConnectivity(r *network.ProgramExternalConnectivityRequest) error {
	log.Printf("ProgramExternalConnectivity: %+v\n", r)
	return nil
}
func (d *OVSNetworkDriver) RevokeExternalConnectivity(r *network.RevokeExternalConnectivityRequest) error {
	log.Printf("RevokeExternalConnectivity: %+v\n", r)
	return nil
}

func main() {
	driver := &OVSNetworkDriver{}
	h := network.NewHandler(driver)
	// pluginSockPath := "/run/docker/plugins/ovs.sock"
	// 注意：传入 socket 名称，库会创建 /run/docker/plugins/<name>.sock
	 const pluginSockName = "ovs"
	log.Printf("Starting OVS Docker plugin on %s\n", pluginSockName)

	if err := h.ServeUnix(pluginSockName, 0); err != nil {
		log.Fatalf("Failed to serve unix socket: %v", err)
	}
}

