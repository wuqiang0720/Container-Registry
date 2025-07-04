# 使用基础镜像
FROM nginx:alpine

# 拷贝静态页面（可自定义）
COPY index.html /usr/share/nginx/html/index.html

# 添加 Open Containers 标签（OCI 标准）以实现自动关联仓库
LABEL org.opencontainers.image.source = "https://github.com/wuqiang0720/Container-Registry"

# 可选的作者信息
LABEL maintainer="wuqiang0720@126.com"
