#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import json
import subprocess
from flask import Flask, request, jsonify

app = Flask(__name__)

# 你要让容器进的 OVS 网桥，先在宿主机上创建： ovs-vsctl add-br br-docker
OVS_BRIDGE = os.environ.get("OVS_BRIDGE", "br-docker")

def sh(cmd):
    return subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

@app.route("/Plugin.Activate", methods=["POST"])
def plugin_activate():
    # 声明我们实现的是 NetworkDriver
    return jsonify({"Implements": ["NetworkDriver"]})

@app.route("/NetworkDriver.GetCapabilities", methods=["POST"])
def get_cap():
    # 本地作用域
    return jsonify({"Scope": "local"})

@app.route("/NetworkDriver.CreateNetwork", methods=["POST"])
def create_network():
    # 确保 br-docker 存在（若不存在则尝试创建）
    r = sh(["ovs-vsctl", "br-exists", OVS_BRIDGE])
    if r.returncode != 0:
        sh(["ovs-vsctl", "add-br", OVS_BRIDGE])
        sh(["ip", "link", "set", OVS_BRIDGE, "up"])
    return jsonify({})

@app.route("/NetworkDriver.DeleteNetwork", methods=["POST"])
def delete_network():
    # 这里不自动删除网桥，避免误删生产网桥
    return jsonify({})

@app.route("/NetworkDriver.CreateEndpoint", methods=["POST"])
def create_endpoint():
    data = request.get_json()
    eid = data["EndpointID"][:12]
    host_if = f"veth{eid[:7]}h"
    cont_if = f"veth{eid[:7]}c"

    # 创建 veth pair
    sh(["ip", "link", "add", host_if, "type", "veth", "peer", "name", cont_if])
    # host 侧加入 OVS 网桥
    sh(["ip", "link", "set", host_if, "up"])
    sh(["ovs-vsctl", "add-port", OVS_BRIDGE, host_if])

    # 把容器侧的一端交给 Docker 在 Join 时迁入 sandbox，并重命名为 eth0
    return jsonify({
        "Interface": {
            "SrcName": cont_if,
            "DstPrefix": "eth"
        }
    })

@app.route("/NetworkDriver.DeleteEndpoint", methods=["POST"])
def delete_endpoint():
    data = request.get_json()
    eid = data["EndpointID"][:12]
    host_if = f"veth{eid[:7]}h"

    # 从 OVS 删除端口；再删 veth（如果还在）
    sh(["ovs-vsctl", "--if-exists", "del-port", OVS_BRIDGE, host_if])
    sh(["ip", "link", "del", host_if])
    return jsonify({})

@app.route("/NetworkDriver.Join", methods=["POST"])
def join():
    # 返回容器端接口命名前缀，Docker 会把 CreateEndpoint 里给的 cont_if 迁入并命名为 eth0
    # 这里也可以返回网关、静态路由等；先保持最小实现
    return jsonify({
        "InterfaceName": {
            "SrcName": "",
            "DstPrefix": "eth"
        }
    })

@app.route("/NetworkDriver.Leave", methods=["POST"])
def leave():
    return jsonify({})

@app.route("/NetworkDriver.EndpointOperInfo", methods=["POST"])
def endpoint_oper_info():
    return jsonify({})

def run_server():
    # 与 config.json 的 Interface.Socket 一致
    sock_dir = "/run/docker/plugins"
    os.makedirs(sock_dir, exist_ok=True)
    sock_path = os.path.join(sock_dir, "ovs.sock")
    try:
        os.remove(sock_path)
    except FileNotFoundError:
        pass

    from werkzeug.serving import run_simple
    # 用 unix socket 监听（必要！）
    run_simple("unix://"+sock_path, 5000, app, threaded=True)

if __name__ == "__main__":
    run_server()

