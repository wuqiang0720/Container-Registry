#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import subprocess
from flask import Flask, request, jsonify
import multiprocessing
import time

app = Flask(__name__)

# OVS 网桥名称，可通过环境变量覆盖
OVS_BRIDGE = os.environ.get("OVS_BRIDGE", "br-int")

def sh(cmd):
    """执行 shell 命令并返回结果"""
    return subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

# --------------------------
# 打印 Docker 发来的请求（调试用）
@app.before_request
def log_request():
    try:
        data = request.get_json(force=True)
    except Exception:
        data = request.get_data()
    print("\n=== Docker Request ===")
    print(f"Path: {request.path}")
    print(f"Method: {request.method}")
    print(f"Headers: {dict(request.headers)}")
    print(f"Body: {data}")
    print("====================\n")
# --------------------------

@app.route("/Plugin.Activate", methods=["POST"])
def plugin_activate():
    return jsonify({"Implements": ["NetworkDriver"]})

@app.route("/NetworkDriver.GetCapabilities", methods=["POST"])
def get_cap():
    return jsonify({"Scope": "local"})

@app.route("/NetworkDriver.CreateNetwork", methods=["POST"])
def create_network():
    # 确保 OVS 网桥存在
    r = sh(["ovs-vsctl", "br-exists", OVS_BRIDGE])
    if r.returncode != 0:
        sh(["ovs-vsctl", "add-br", OVS_BRIDGE])
        sh(["ip", "link", "set", OVS_BRIDGE, "up"])
    return jsonify({})

@app.route("/NetworkDriver.DeleteNetwork", methods=["POST"])
def delete_network():
    return jsonify({})

@app.route("/NetworkDriver.CreateEndpoint", methods=["POST"])
def create_endpoint():
    data = request.get_json(force=True)
    eid = data["EndpointID"][:12]
    host_if = f"tap{eid[:7]}h"
    cont_if = f"tap{eid[:7]}c"

    # 创建 tap pair
    sh(["ip", "link", "add", host_if, "type", "tap", "peer", "name", cont_if])
    sh(["ip", "link", "set", host_if, "up"])
    sh(["ovs-vsctl", "add-port", OVS_BRIDGE, host_if])

    return jsonify({
        "Interface": {
            "SrcName": cont_if,
            "DstPrefix": "eth"
        }
    })

@app.route("/NetworkDriver.DeleteEndpoint", methods=["POST"])
def delete_endpoint():
    data = request.get_json(force=True)
    eid = data["EndpointID"][:12]
    host_if = f"tap{eid[:7]}h"
    sh(["ovs-vsctl", "--if-exists", "del-port", OVS_BRIDGE, host_if])
    sh(["ip", "link", "del", host_if])
    return jsonify({})

@app.route("/NetworkDriver.Join", methods=["POST"])
def join():
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

# --------------------------
# 自动启动 Gunicorn 监听 Unix Socket
# --------------------------
def run_gunicorn():
    import gunicorn.app.base
#    from gunicorn.six import iteritems

    class StandaloneApplication(gunicorn.app.base.BaseApplication):
        def __init__(self, app, options=None):
            self.options = options or {}
            self.application = app
            super().__init__()

        def load_config(self):
            config = {key: value for key, value in self.options.items()
                      if key in self.cfg.settings and value is not None}
            for key, value in config.items():
                self.cfg.set(key.lower(), value)

        def load(self):
            return self.application

    sock_dir = "/run/docker/plugins"
    os.makedirs(sock_dir, exist_ok=True)
    sock_path = os.path.join(sock_dir, "ovs.sock")
    try:
        os.remove(sock_path)
    except FileNotFoundError:
        pass

    options = {
        "bind": f"unix:{sock_path}",
        "workers": 1,
        "threads": 2,
        "timeout": 60,
        "loglevel": "info",
    }

    # 后台启动 Gunicorn
    StandaloneApplication(app, options).run()
    os.chmod(sock_path, 0o666)

if __name__ == "__main__":
    print("启动 OVS Docker 插件（Gunicorn 后台模式）…")
    p = multiprocessing.Process(target=run_gunicorn)
    p.start()
    # 等待 socket 文件生成
    time.sleep(1)
    print("插件启动完成，socket 文件：/run/docker/plugins/ovs.sock")

