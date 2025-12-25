# 构建指南

本文档说明如何在本地构建 Nezha Agent Docker 镜像。

## 快速测试构建

### 单架构构建（本地架构）

```bash
# 构建本地架构镜像
docker build -t nezha-agent-v2:test .

# 测试运行
docker run --rm -it \
  -e NZ_SERVER=your-server:port \
  -e NZ_TLS=true \
  -e NZ_CLIENT_SECRET=your-secret \
  nezha-agent-v2:test
```

### 多架构构建

需要先设置 Docker Buildx：

```bash
# 创建并使用 buildx builder
docker buildx create --name mybuilder --use
docker buildx inspect --bootstrap

# 构建多架构镜像（amd64 + arm64 + armv7）
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t whoerau/nezha-agent-v2:test \
  --load \
  .

# 注意：--load 只能用于单架构，多架构需要用 --push
# 多架构推送到 registry
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t whoerau/nezha-agent-v2:test \
  --push \
  .
```

### 只构建 amd64 和 arm64

如果不需要 armv7 支持：

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t whoerau/nezha-agent-v2:test \
  .
```

## 使用 Docker Compose 本地构建

修改 `docker-compose.yml`，取消注释 build 部分：

```yaml
services:
  nezha-agent:
    # image: whoerau/nezha-agent-v2:latest
    build:
      context: .
      dockerfile: Dockerfile
    # ... 其他配置
```

然后运行：

```bash
# 构建并启动
docker-compose up -d --build

# 只构建不启动
docker-compose build
```

## 构建过程说明

### 1. 架构检测

Dockerfile 会自动检测构建平台的架构：
- `x86_64` / `amd64` → 下载 amd64 版本
- `aarch64` / `arm64` → 下载 arm64 版本
- `armv7l` / `armhf` → 下载 arm 版本

### 2. 版本获取

构建时会自动获取 Nezha Agent 的最新版本：
1. 首先尝试从 GitHub API 获取最新版本号
2. 如果失败，使用备用版本（v0.18.11）

### 3. 下载 Agent

从 GitHub Releases 下载对应架构的 nezha-agent 二进制文件：
```
https://github.com/nezhahq/agent/releases/download/{VERSION}/nezha-agent_linux_{ARCH}.zip
```

## 常见问题

### 1. GitHub API 限制

如果频繁构建可能遇到 GitHub API 限制，可以：

**方法 1：使用 GitHub Token**

修改 Dockerfile，在 wget 命令中添加认证：

```dockerfile
VERSION=$(wget --header="Authorization: token YOUR_GITHUB_TOKEN" ...)
```

**方法 2：手动指定版本**

修改 Dockerfile，直接设置版本号：

```dockerfile
VERSION="v0.18.11"
```

### 2. 下载速度慢

如果从 GitHub 下载慢，可以：

**方法 1：使用代理**

```bash
docker build \
  --build-arg HTTP_PROXY=http://proxy:port \
  --build-arg HTTPS_PROXY=http://proxy:port \
  -t nezha-agent-v2:test .
```

**方法 2：使用镜像加速**

修改 Dockerfile，使用 GitHub 镜像站点。

### 3. 多架构构建失败

确保启用了 QEMU 模拟器：

```bash
# 安装 QEMU 模拟器
docker run --privileged --rm tonistiigi/binfmt --install all

# 验证支持的平台
docker buildx inspect --bootstrap
```

### 4. 构建缓存

如果需要清除缓存重新构建：

```bash
# 清除构建缓存
docker builder prune -a

# 无缓存构建
docker build --no-cache -t nezha-agent-v2:test .

# buildx 无缓存构建
docker buildx build --no-cache --platform linux/amd64,linux/arm64 .
```

## GitHub Actions 自动构建

推送代码到 GitHub 后，会自动触发构建：

1. **触发条件**：
   - 每月 1 号自动构建
   - 推送到 main 分支
   - 修改 Dockerfile 或 workflow 文件
   - 手动触发

2. **构建架构**：
   - linux/amd64
   - linux/arm64
   - linux/arm/v7

3. **推送目标**：
   - DockerHub: `whoerau/nezha-agent-v2`

## 验证镜像

构建完成后验证镜像：

```bash
# 查看镜像信息
docker images | grep nezha-agent-v2

# 查看镜像详情
docker inspect whoerau/nezha-agent-v2:test

# 查看镜像层
docker history whoerau/nezha-agent-v2:test

# 运行测试
docker run --rm nezha-agent-v2:test /opt/nezha/agent/nezha-agent --version
```

## 镜像大小优化

当前镜像基于 Alpine Linux，已经比较小了。如果需要进一步优化：

### 1. 使用多阶段构建

```dockerfile
# 构建阶段
FROM alpine:latest AS builder
# ... 下载和解压 ...

# 运行阶段
FROM alpine:latest
COPY --from=builder /opt/nezha/agent/nezha-agent /opt/nezha/agent/
# ... 其他配置 ...
```

### 2. 清理不必要的包

如果某些包只在构建时需要，可以在构建后删除。

## 调试构建

如果构建失败，可以逐步调试：

```bash
# 构建到特定阶段
docker build --target builder -t nezha-agent-debug .

# 进入中间容器调试
docker run --rm -it alpine:latest sh

# 在容器中手动执行构建命令
apk add wget unzip bash
wget https://github.com/nezhahq/agent/releases/download/v0.18.11/nezha-agent_linux_amd64.zip
# ...
```

## 生产环境构建建议

1. **固定版本号**：生产环境建议固定 Agent 版本，而不是使用 latest
2. **添加标签**：构建时添加版本标签和构建信息
3. **安全扫描**：使用 `docker scan` 或 Trivy 扫描镜像漏洞
4. **签名验证**：使用 Docker Content Trust 签名镜像

```bash
# 固定版本构建
docker build --build-arg VERSION=v0.18.11 -t nezha-agent-v2:0.18.11 .

# 扫描镜像
docker scan nezha-agent-v2:0.18.11
# 或使用 Trivy
trivy image nezha-agent-v2:0.18.11
```

## 参考链接

- [Docker Buildx 文档](https://docs.docker.com/buildx/working-with-buildx/)
- [多架构构建指南](https://docs.docker.com/desktop/multi-arch/)
- [Nezha Agent Releases](https://github.com/nezhahq/agent/releases)

