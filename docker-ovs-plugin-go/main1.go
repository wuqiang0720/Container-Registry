package main

import (
    "fmt"
    "log"
    "math/rand"
    "os/exec"
    "strings"
    "time"

    "github.com/docker/go-plugins-helpers/network"
)

const (
    OVS_BRIDGE = "br-int"
    OVS_GW     = "192.168.1.1/24" // 网关 IP
)

// 执行 shell 命令
func sh(cmd ...string) {
    out, err := exec.Command(cmd[0], cmd[1:]...).CombinedOutput()
    if err != nil {
        log.Printf("cmd %v failed: %v, output: %s", cmd, err, string(out))
    }
}

// 初始化 OVS 网桥
func initBridge() {
    // 检查桥是否存在
    err := exec.Command("ovs-vsctl", "br-exists", OVS_BRIDGE).Run()
    if err != nil {
        log.Printf("创建 OVS 桥 %s", OVS_BRIDGE)
        sh("ovs-vsctl", "add-br", OVS_BRIDGE)
        sh("ip", "link", "set", OVS_BRIDGE, "up")
        sh("ip", "addr", "add", OVS_GW, "dev", OVS_BRIDGE)
    } else {
        log.Printf("OVS 桥 %s 已存在，确保 up 并配置网关", OVS_BRIDGE)
        sh("ip", "link", "set", OVS_BRIDGE, "up")
        // 检查 IP 是否存在
        out, _ := exec.Command("ip", "addr", "show", "dev", OVS_BRIDGE).Output()
        if !strings.Contains(string(out), strings.Split(OVS_GW, "/")[0]) {
            sh("ip", "addr", "add", OVS_GW, "dev", OVS_BRIDGE)
        }
    }
}

// 随机 MAC
func randomMAC() string {
    rand.Seed(time.Now().UnixNano())
    mac := []byte{0x02, 0x42, byte(rand.Intn(256)), byte(rand.Intn(256)), byte(rand.Intn(256)), byte(rand.Intn(256))}
    return fmt.Sprintf("%02x:%02x:%02x:%02x:%02x:%02x", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5])
}

// ContainerID -> veth 名称
func ifNames(containerID string) (hostIf, contIf string) {
    base := containerID
    if len(base) > 8 {
        base = containerID[:8]
    }
    hostIf = "veth" + base + "h"
    contIf = "veth" + base + "c"
    return
}

// Driver 定义
type OVSNetworkDriver struct{}

// Scope
func (d *OVSNetworkDriver) GetCapabilities() (*network.CapabilitiesResponse, error) {
    return &network.CapabilitiesResponse{Scope: network.LocalScope}, nil
}

// 网络生命周期
func (d *OVSNetworkDriver) AllocateNetwork(r *network.AllocateNetworkRequest) (*network.AllocateNetworkResponse, error) {
    return &network.AllocateNetworkResponse{Options: map[string]string{}}, nil
}
func (d *OVSNetworkDriver) FreeNetwork(r *network.FreeNetworkRequest) error { return nil }
func (d *OVSNetworkDriver) CreateNetwork(r *network.CreateNetworkRequest) error { return nil }
func (d *OVSNetworkDriver) DeleteNetwork(r *network.DeleteNetworkRequest) error { return nil }

// Endpoint 生命周期
func (d *OVSNetworkDriver) CreateEndpoint(r *network.CreateEndpointRequest) (*network.CreateEndpointResponse, error) {
    return &network.CreateEndpointResponse{Interface: &network.EndpointInterface{}}, nil
}
func (d *OVSNetworkDriver) DeleteEndpoint(r *network.DeleteEndpointRequest) error { return nil }
func (d *OVSNetworkDriver) EndpointInfo(r *network.InfoRequest) (*network.InfoResponse, error) {
    return &network.InfoResponse{Value: map[string]string{"ovs-bridge": OVS_BRIDGE}}, nil
}

// Join：创建 veth pair + OVS + MAC
func (d *OVSNetworkDriver) Join(r *network.JoinRequest) (*network.JoinResponse, error) {
    // 从 SandboxKey 提取 ContainerID
    parts := strings.Split(r.SandboxKey, "/")
    containerID := parts[len(parts)-1]

    hostIf, contIf := ifNames(containerID)
    mac := randomMAC()

    sh("ip", "link", "add", hostIf, "type", "veth", "peer", "name", contIf)
    sh("ip", "link", "set", hostIf, "up")
    sh("ovs-vsctl", "add-port", OVS_BRIDGE, hostIf)
    sh("ip", "link", "set", contIf, "address", mac)

    return &network.JoinResponse{
        InterfaceName: network.InterfaceName{
            SrcName:   contIf,
            DstPrefix: "eth",
        },
        Gateway: strings.Split(OVS_GW, "/")[0],
    }, nil
}

func (d *OVSNetworkDriver) Leave(r *network.LeaveRequest) error {
    parts := strings.Split(r.SandboxKey, "/")
    containerID := parts[len(parts)-1]

    hostIf, _ := ifNames(containerID)
    sh("ovs-vsctl", "del-port", OVS_BRIDGE, hostIf)
    sh("ip", "link", "del", hostIf)
    return nil
}

// 其他接口不做处理
func (d *OVSNetworkDriver) DiscoverNew(n *network.DiscoveryNotification) error { return nil }
func (d *OVSNetworkDriver) DiscoverDelete(n *network.DiscoveryNotification) error { return nil }
func (d *OVSNetworkDriver) ProgramExternalConnectivity(r *network.ProgramExternalConnectivityRequest) error { return nil }
func (d *OVSNetworkDriver) RevokeExternalConnectivity(r *network.RevokeExternalConnectivityRequest) error { return nil }

func main() {
    // 初始化 OVS 桥和网关
    initBridge()

    driver := &OVSNetworkDriver{}
    h := network.NewHandler(driver)
    const pluginSockName = "ovs"
    log.Printf("Starting OVS plugin on %s", pluginSockName)
    if err := h.ServeUnix(pluginSockName, 0); err != nil {
        log.Fatalf("Failed to serve unix socket: %v", err)
    }
}

