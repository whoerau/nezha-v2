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

# 创建工作目录和数据目录
WORKDIR /app
RUN mkdir -p /data && chmod 777 /data

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
    NZ_DISABLE_AUTO_UPDATE="false" \
    NZ_DISABLE_FORCE_UPDATE="false" \
    NZ_DISABLE_COMMAND_EXECUTE="true" \
    NZ_DISABLE_NAT="false" \
    NZ_USE_IPV6="false" \
    NZ_GPU="false" \
    NZ_TEMPERATURE="false" \
    NZ_IP_REPORT_PERIOD="1800" \
    NZ_DEBUG="false"

# 复制启动脚本
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pgrep -f nezha-agent || exit 1

# 启动命令
CMD ["/app/start.sh"]

