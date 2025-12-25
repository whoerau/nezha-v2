FROM alpine:latest

LABEL maintainer="nezha-agent-docker"
LABEL description="Nezha Agent Docker Image"

# 安装必要的工具
RUN apk add --no-cache \
    wget \
    unzip \
    bash \
    ca-certificates \
    tzdata \
    && rm -rf /var/cache/apk/*

# 设置时区
ENV TZ=Asia/Shanghai

# 创建工作目录
WORKDIR /app

# 检测架构并下载对应的 nezha-agent
RUN set -ex && \
    # 检测架构
    ARCH=$(uname -m) && \
    case "$ARCH" in \
        x86_64|amd64) ARCH="amd64" ;; \
        aarch64|arm64) ARCH="arm64" ;; \
        armv7l|armhf) ARCH="arm" ;; \
        *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac && \
    echo "Detected architecture: $ARCH" && \
    \
    # 获取最新版本号
    echo "Fetching latest version..." && \
    VERSION=$(wget -qO- --timeout=10 "https://api.github.com/repos/nezhahq/agent/releases/latest" 2>/dev/null | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' || echo "") && \
    \
    # 如果获取失败，使用备用版本
    if [ -z "$VERSION" ]; then \
        echo "Failed to fetch latest version, using fallback version"; \
        VERSION="v0.18.11"; \
    fi && \
    echo "Version to install: $VERSION" && \
    \
    # 下载 nezha-agent
    DOWNLOAD_URL="https://github.com/nezhahq/agent/releases/download/${VERSION}/nezha-agent_linux_${ARCH}.zip" && \
    echo "Downloading from: $DOWNLOAD_URL" && \
    wget --timeout=60 -O /tmp/nezha-agent.zip "$DOWNLOAD_URL" || { \
        echo "Download failed, trying alternative method..."; \
        wget --timeout=60 --no-check-certificate -O /tmp/nezha-agent.zip "$DOWNLOAD_URL"; \
    } && \
    \
    # 创建目录并解压
    mkdir -p /opt/nezha/agent && \
    unzip -o /tmp/nezha-agent.zip -d /opt/nezha/agent && \
    \
    # 设置执行权限
    chmod +x /opt/nezha/agent/nezha-agent && \
    \
    # 清理临时文件
    rm -f /tmp/nezha-agent.zip && \
    \
    # 验证安装
    echo "Verifying installation..." && \
    ls -lh /opt/nezha/agent/ && \
    /opt/nezha/agent/nezha-agent --version || echo "Nezha Agent installed successfully"

# 设置环境变量
ENV NZ_SERVER="" \
    NZ_TLS="false" \
    NZ_CLIENT_SECRET="" \
    NZ_UUID="" \
    NZ_REPORT_DELAY="1" \
    NZ_SKIP_CONN="false" \
    NZ_SKIP_PROCS="false" \
    NZ_DISABLE_AUTO_UPDATE="true" \
    NZ_DISABLE_FORCE_UPDATE="true" \
    NZ_DISABLE_COMMAND_EXECUTE="true" \
    NZ_DISABLE_NAT="false" \
    NZ_USE_IPV6="false" \
    NZ_GPU="false" \
    NZ_TEMPERATURE="false" \
    NZ_IP_REPORT_PERIOD="1800" \
    NZ_DEBUG="false"

# 创建启动脚本
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'if [ -z "$NZ_SERVER" ] || [ -z "$NZ_CLIENT_SECRET" ]; then' >> /app/start.sh && \
    echo '  echo "错误: NZ_SERVER 和 NZ_CLIENT_SECRET 环境变量必须设置"' >> /app/start.sh && \
    echo '  exit 1' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo 'echo "正在启动 Nezha Agent..."' >> /app/start.sh && \
    echo 'echo "服务器: $NZ_SERVER"' >> /app/start.sh && \
    echo 'echo "TLS: $NZ_TLS"' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo 'ARGS="-s $NZ_SERVER -p $NZ_CLIENT_SECRET"' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo 'if [ -n "$NZ_UUID" ]; then' >> /app/start.sh && \
    echo '  ARGS="$ARGS --uuid $NZ_UUID"' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo 'if [ "$NZ_TLS" = "true" ]; then' >> /app/start.sh && \
    echo '  ARGS="$ARGS --tls"' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo 'if [ "$NZ_SKIP_CONN" = "true" ]; then' >> /app/start.sh && \
    echo '  ARGS="$ARGS --skip-conn"' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo 'if [ "$NZ_SKIP_PROCS" = "true" ]; then' >> /app/start.sh && \
    echo '  ARGS="$ARGS --skip-procs"' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo 'if [ -n "$NZ_REPORT_DELAY" ]; then' >> /app/start.sh && \
    echo '  ARGS="$ARGS -d $NZ_REPORT_DELAY"' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo 'if [ "$NZ_DISABLE_AUTO_UPDATE" = "true" ]; then' >> /app/start.sh && \
    echo '  ARGS="$ARGS --disable-auto-update"' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo 'if [ "$NZ_DISABLE_FORCE_UPDATE" = "true" ]; then' >> /app/start.sh && \
    echo '  ARGS="$ARGS --disable-force-update"' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo 'if [ "$NZ_DISABLE_COMMAND_EXECUTE" = "true" ]; then' >> /app/start.sh && \
    echo '  ARGS="$ARGS --disable-command-execute"' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo 'if [ "$NZ_DISABLE_NAT" = "true" ]; then' >> /app/start.sh && \
    echo '  ARGS="$ARGS --disable-nat"' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo 'if [ "$NZ_USE_IPV6" = "true" ]; then' >> /app/start.sh && \
    echo '  ARGS="$ARGS --use-ipv6"' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo 'if [ "$NZ_GPU" = "true" ]; then' >> /app/start.sh && \
    echo '  ARGS="$ARGS --gpu"' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo 'if [ "$NZ_TEMPERATURE" = "true" ]; then' >> /app/start.sh && \
    echo '  ARGS="$ARGS --temperature"' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo 'if [ -n "$NZ_IP_REPORT_PERIOD" ]; then' >> /app/start.sh && \
    echo '  ARGS="$ARGS --ip-report-period $NZ_IP_REPORT_PERIOD"' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo 'if [ "$NZ_DEBUG" = "true" ]; then' >> /app/start.sh && \
    echo '  ARGS="$ARGS --debug"' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo 'exec /opt/nezha/agent/nezha-agent $ARGS' >> /app/start.sh && \
    chmod +x /app/start.sh

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pgrep -f nezha-agent || exit 1

# 启动命令
CMD ["/app/start.sh"]

