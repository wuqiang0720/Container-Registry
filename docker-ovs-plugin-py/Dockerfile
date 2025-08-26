FROM ghcr.io/wuqiang0720/python:3.12-slim

# 安装必须工具：Flask(HTTP 服务)、iproute2(veth 操作)、openvswitch-switch(ovs-vsctl)
RUN apt-get update && \
    apt-get install -y --no-install-recommends iproute2 openvswitch-switch && \
    pip install --no-cache-dir flask && \
    rm -rf /var/lib/apt/lists/*

# 插件程序
COPY ovs_docker_plugin.py /ovs_docker_plugin.py
RUN chmod +x /ovs_docker_plugin.py

# 插件运行时会监听这个目录下的 unix socket
VOLUME ["/run/docker/plugins"]

# 入口：启动我们的 Python 插件服务
ENTRYPOINT ["/ovs_docker_plugin.py"]

