package main

import (
	"log"
	"os"
	"os/exec"

	"github.com/docker/go-plugins-helpers/network"
)

const OVS_BRIDGE = "br-int"

// Helper: 执行系统命令
func sh(cmd ...string) {
	out, err := exec.Command(cmd[0], cmd[1:]...).CombinedOutput()
	if err != nil {
		log.Printf("cmd %v failed: %v, output: %s", cmd, err, out)
	}
}

// OVSNetworkDriver 实现 Docker NetworkDriver 接口
type OVSNetworkDriver struct{}

func (d *OVSNetworkDriver) GetCapabilities() (*network.CapabilitiesResponse, error) {
	return &network.CapabilitiesResponse{Scope: "local"}, nil
}

func (d *OVSNetworkDriver) CreateNetwork(r *network.CreateNetworkRequest) error {
	log.Printf("CreateNetwork: %+v\n", r)
	return nil
}

func (d *OVSNetworkDriver) DeleteNetwork(r *network.DeleteNetworkRequest) error {
	log.Printf("DeleteNetwork: %+v\n", r)
	return nil
}

func (d *OVSNetworkDriver) CreateEndpoint(r *network.CreateEndpointRequest) (*network.CreateEndpointResponse, error) {
	log.Printf("CreateEndpoint: %+v\n", r)

	eid := r.EndpointID
	hostIf := "tap" + eid[:7] + "h"
	contIf := "tap" + eid[:7] + "c"

	// 创建 tap pair 并加入 OVS 桥
	sh("ip", "link", "add", hostIf, "type", "tap", "peer", "name", contIf)
	sh("ip", "link", "set", hostIf, "up")
	sh("ovs-vsctl", "add-port", OVS_BRIDGE, hostIf)

	return &network.CreateEndpointResponse{
		Interface: &network.EndpointInterface{
			SrcName:   contIf,
			DstPrefix: "eth",
		},
	}, nil
}

func (d *OVSNetworkDriver) DeleteEndpoint(r *network.DeleteEndpointRequest) error {
	log.Printf("DeleteEndpoint: %+v\n", r)
	// 可自行删除 tap pair
	return nil
}

func main() {
	driver := &OVSNetworkDriver{}
	h := network.NewHandler(driver)

	// Docker 插件 UNIX socket
	socket := "/run/docker/plugins/ovs.sock"
	if _, err := os.Stat(socket); err == nil {
		os.Remove(socket)
	}
	log.Printf("Starting OVS Docker plugin on %s\n", socket)

	if err := h.ServeUnix(socket, 0); err != nil {
		log.Fatalf("Failed to serve unix socket: %v", err)
	}
}

