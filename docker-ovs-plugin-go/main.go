package main

import (
    "fmt"
    "log"
    "math/rand"
    "os/exec"
    "time"

    "github.com/docker/go-plugins-helpers/network"
)

const OVS_BRIDGE = "br-int"

// 执行命令
func sh(cmd ...string) {
    out, err := exec.Command(cmd[0], cmd[1:]...).CombinedOutput()
    if err != nil {
        log.Printf("cmd %v failed: %v, output: %s", cmd, err, string(out))
    }
}

// 随机 MAC
func randomMAC() string {
    rand.Seed(time.Now().UnixNano())
    mac := []byte{0x02, 0x42, byte(rand.Intn(256)), byte(rand.Intn(256)), byte(rand.Intn(256)), byte(rand.Intn(256))}
    return fmt.Sprintf("%02x:%02x:%02x:%02x:%02x:%02x", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5])
}

// EndpointID -> veth 名称
func ifNames(eid string) (hostIf, contIf string) {
    base := eid
    if len(base) > 7 {
        base = eid[:7]
    }
    hostIf = "veth" + base + "h"
    contIf = "veth" + base + "c"
    return
}

type OVSNetworkDriver struct{}

// Scope
func (d *OVSNetworkDriver) GetCapabilities() (*network.CapabilitiesResponse, error) {
    return &network.CapabilitiesResponse{Scope: network.LocalScope}, nil
}

// 网络生命周期
func (d *OVSNetworkDriver) AllocateNetwork(r *network.AllocateNetworkRequest) (*network.AllocateNetworkResponse, error) {
    log.Printf("AllocateNetwork: %+v\n", r)
    return &network.AllocateNetworkResponse{Options: map[string]string{}}, nil
}
func (d *OVSNetworkDriver) FreeNetwork(r *network.FreeNetworkRequest) error { return nil }
func (d *OVSNetworkDriver) CreateNetwork(r *network.CreateNetworkRequest) error { return nil }
func (d *OVSNetworkDriver) DeleteNetwork(r *network.DeleteNetworkRequest) error { return nil }

// Endpoint 生命周期
func (d *OVSNetworkDriver) CreateEndpoint(r *network.CreateEndpointRequest) (*network.CreateEndpointResponse, error) {
    log.Printf("CreateEndpoint: %+v", r)
    return &network.CreateEndpointResponse{Interface: &network.EndpointInterface{}}, nil
}
func (d *OVSNetworkDriver) DeleteEndpoint(r *network.DeleteEndpointRequest) error { return nil }
func (d *OVSNetworkDriver) EndpointInfo(r *network.InfoRequest) (*network.InfoResponse, error) {
    return &network.InfoResponse{Value: map[string]string{"ovs-bridge": OVS_BRIDGE}}, nil
}

// Join：创建 veth pair + OVS + MAC
func (d *OVSNetworkDriver) Join(r *network.JoinRequest) (*network.JoinResponse, error) {
    log.Printf("Join: %+v", r)
    hostIf, contIf := ifNames(r.EndpointID)
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
    }, nil
}

func (d *OVSNetworkDriver) Leave(r *network.LeaveRequest) error {
    hostIf, _ := ifNames(r.EndpointID)
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
    driver := &OVSNetworkDriver{}
    h := network.NewHandler(driver)
    const pluginSockName = "ovs"
    log.Printf("Starting OVS plugin on %s", pluginSockName)
    if err := h.ServeUnix(pluginSockName, 0); err != nil {
        log.Fatalf("Failed to serve unix socket: %v", err)
    }
}

