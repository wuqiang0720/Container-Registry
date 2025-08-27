package main

import (
    "encoding/json"
    "log"
    "net/http"
    "os"
    "os/exec"
    "net" 
    "github.com/gorilla/mux"
)

const OVS_BRIDGE = "br0"

func sh(cmd ...string) {
    out, err := exec.Command(cmd[0], cmd[1:]...).CombinedOutput()
    if err != nil {
        log.Printf("cmd %v failed: %v, output: %s", cmd, err, out)
    }
}

func createNetwork(w http.ResponseWriter, r *http.Request) {
    data := map[string]interface{}{}
    _ = json.NewDecoder(r.Body).Decode(&data)
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(map[string]interface{}{})
}

func createEndpoint(w http.ResponseWriter, r *http.Request) {
    data := map[string]interface{}{}
    _ = json.NewDecoder(r.Body).Decode(&data)
    eid, ok := data["EndpointID"].(string)
    if !ok {
        eid = "tmpid"
    }
    host_if := "tap" + eid[:7] + "h"
    cont_if := "tap" + eid[:7] + "c"

    // 创建 tap pair
    sh("ip", "link", "add", host_if, "type", "tap", "peer", "name", cont_if)
    sh("ip", "link", "set", host_if, "up")
    sh("ovs-vsctl", "add-port", OVS_BRIDGE, host_if)

    resp := map[string]interface{}{
        "Interface": map[string]string{
            "SrcName": cont_if,
            "DstPrefix": "eth",
        },
        "Err": "",
    }
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(resp)
}

func main() {
    r := mux.NewRouter()
    r.HandleFunc("/Plugin.Activate", func(w http.ResponseWriter, r *http.Request) {
        json.NewEncoder(w).Encode(map[string]interface{}{
            "Implements": []string{"NetworkDriver"},
        })
    }).Methods("POST")

    r.HandleFunc("/NetworkDriver.CreateNetwork", createNetwork).Methods("POST")
    r.HandleFunc("/NetworkDriver.CreateEndpoint", createEndpoint).Methods("POST")

    sock := "/run/docker/plugins/ovs.sock"
    os.Remove(sock)
    listener, err := net.Listen("unix", sock)
    if err != nil {
        log.Fatal(err)
    }
    os.Chmod(sock, 0666)
    log.Println("OVS Docker plugin listening on", sock)
    http.Serve(listener, r)
}

