# 与官方安装脚本的兼容性说明

本文档说明 Docker 镜像与官方 `install.sh` 脚本的参数对应关系和兼容性。

## 官方安装脚本

官方安装脚本位于：
```
https://raw.githubusercontent.com/nezhahq/scripts/main/agent/install.sh
```

## 参数完整对照

### 官方脚本支持的环境变量

从 `install.sh` 脚本中可以看到以下环境变量（第 195 行）：

```bash
env="NZ_UUID=$NZ_UUID \
     NZ_SERVER=$NZ_SERVER \
     NZ_CLIENT_SECRET=$NZ_CLIENT_SECRET \
     NZ_TLS=$NZ_TLS \
     NZ_DISABLE_AUTO_UPDATE=$NZ_DISABLE_AUTO_UPDATE \
     NZ_DISABLE_FORCE_UPDATE=$DISABLE_FORCE_UPDATE \
     NZ_DISABLE_COMMAND_EXECUTE=$NZ_DISABLE_COMMAND_EXECUTE \
     NZ_SKIP_CONNECTION_COUNT=$NZ_SKIP_CONNECTION_COUNT"
```

### Docker 镜像支持的参数

| 官方脚本参数              | Docker 环境变量               | 状态 | 说明                                         |
| ------------------------- | ----------------------------- | ---- | -------------------------------------------- |
| `NZ_UUID`                 | `NZ_UUID`                     | ✅   | 客户端唯一标识                               |
| `NZ_SERVER`               | `NZ_SERVER`                   | ✅   | 服务器地址                                   |
| `NZ_CLIENT_SECRET`        | `NZ_CLIENT_SECRET`            | ✅   | 客户端密钥                                   |
| `NZ_TLS`                  | `NZ_TLS`                      | ✅   | TLS 加密                                     |
| `NZ_DISABLE_AUTO_UPDATE`  | `NZ_DISABLE_AUTO_UPDATE`      | ✅   | 禁用自动更新                                 |
| `NZ_DISABLE_FORCE_UPDATE` | `NZ_DISABLE_FORCE_UPDATE`     | ✅   | 禁用强制更新                                 |
| `NZ_DISABLE_COMMAND_EXECUTE` | `NZ_DISABLE_COMMAND_EXECUTE` | ✅   | 禁用命令执行                                 |
| `NZ_SKIP_CONNECTION_COUNT` | `NZ_SKIP_CONN`               | ✅   | 跳过连接计数（参数名略有不同，功能相同）     |

### Docker 镜像额外支持的参数

以下参数是 nezha-agent 二进制程序支持但官方安装脚本未明确列出的参数，我们也提供了支持：

| 参数名                    | 说明                     |
| ------------------------- | ------------------------ |
| `NZ_REPORT_DELAY`         | 上报延迟                 |
| `NZ_SKIP_PROCS`           | 跳过进程检查             |
| `NZ_DISABLE_NAT`          | 禁用 NAT 穿透            |
| `NZ_USE_IPV6`             | 使用 IPv6                |
| `NZ_GPU`                  | 启用 GPU 监控            |
| `NZ_TEMPERATURE`          | 启用温度监控             |
| `NZ_IP_REPORT_PERIOD`     | IP 上报周期              |
| `NZ_DEBUG`                | 调试模式                 |

## 使用方式对比

### 官方安装脚本使用方式

```bash
curl -L https://raw.githubusercontent.com/nezhahq/scripts/main/agent/install.sh -o agent.sh && \
chmod +x agent.sh && \
env NZ_SERVER=your-server-address:port \
    NZ_TLS=true \
    NZ_CLIENT_SECRET=your-secret \
    ./agent.sh
```

### Docker 镜像等价配置

```yaml
# docker-compose.yml
services:
  nezha-agent:
    image: whoerau/nezha-agent-v2:latest
    environment:
      - NZ_SERVER=your-server-address:port
      - NZ_TLS=true
      - NZ_CLIENT_SECRET=your-secret
      - NZ_DISABLE_AUTO_UPDATE=false     # 允许自动更新
      - NZ_DISABLE_FORCE_UPDATE=false    # 允许强制更新
      - NZ_DISABLE_COMMAND_EXECUTE=true  # 禁用命令执行（安全）
```

## 关键差异说明

### 1. 自动更新

**官方脚本**：默认启用自动更新
- Agent 可以自动升级到最新版本

**Docker 镜像**：默认启用自动更新
- Agent 可以自动保持最新版本
- 如需通过镜像控制版本，可设置 `NZ_DISABLE_AUTO_UPDATE=true`

### 2. 命令执行

**官方脚本**：默认启用命令执行
- 可以通过 Dashboard 远程执行命令

**Docker 镜像**：默认禁用命令执行
- 理由：Docker 容器通常不需要直接命令执行
- 优势：提高安全性，减少攻击面
- 如需启用：设置 `NZ_DISABLE_COMMAND_EXECUTE=false`

### 3. 参数名称差异

| 官方脚本                | Docker 镜像       | 说明                     |
| ----------------------- | ----------------- | ------------------------ |
| `NZ_SKIP_CONNECTION_COUNT` | `NZ_SKIP_CONN` | 功能相同，名称简化       |

## 完整兼容性测试

### 基础功能测试

| 功能项           | 官方脚本 | Docker 镜像 | 兼容性 |
| ---------------- | -------- | ----------- | ------ |
| 服务器连接       | ✅       | ✅          | ✅     |
| TLS 加密         | ✅       | ✅          | ✅     |
| 系统信息上报     | ✅       | ✅          | ✅     |
| CPU 监控         | ✅       | ✅          | ✅     |
| 内存监控         | ✅       | ✅          | ✅     |
| 磁盘监控         | ✅       | ✅          | ✅     |
| 网络监控         | ✅       | ✅          | ✅     |
| 进程监控         | ✅       | ✅          | ✅     |
| 连接数统计       | ✅       | ✅          | ✅     |

### 高级功能测试

| 功能项           | 官方脚本 | Docker 镜像 | 兼容性 | 备注                       |
| ---------------- | -------- | ----------- | ------ | -------------------------- |
| 自动更新         | ✅       | ⚠️          | ⚠️     | Docker 环境不建议启用      |
| 命令执行         | ✅       | ✅          | ✅     | Docker 默认禁用，可启用    |
| NAT 穿透         | ✅       | ✅          | ✅     |                            |
| GPU 监控         | ✅       | ✅          | ✅     | 需要额外配置               |
| 温度监控         | ✅       | ✅          | ✅     | 需要设备权限               |
| IPv6 支持        | ✅       | ✅          | ✅     |                            |
| 自定义 UUID      | ✅       | ✅          | ✅     |                            |

## 迁移指南

### 从官方安装迁移到 Docker

1. **记录当前配置**
   
   查看现有配置文件：
   ```bash
   cat /opt/nezha/agent/config.yml
   ```

2. **准备环境变量**
   
   根据配置文件内容，设置对应的环境变量。

3. **停止原有服务**
   
   ```bash
   sudo systemctl stop nezha-agent
   sudo systemctl disable nezha-agent
   ```

4. **启动 Docker 容器**
   
   ```bash
   docker-compose up -d
   ```

5. **验证运行状态**
   
   ```bash
   docker-compose logs -f nezha-agent
   ```

### 配置示例对照

**官方脚本安装命令：**
```bash
env NZ_SERVER=example.com:5555 \
    NZ_TLS=true \
    NZ_CLIENT_SECRET=your-secret \
    NZ_UUID=custom-uuid \
    ./agent.sh
```

**等价的 Docker Compose 配置：**
```yaml
services:
  nezha-agent:
    image: whoerau/nezha-agent-v2:latest
    environment:
      - NZ_SERVER=example.com:5555
      - NZ_TLS=true
      - NZ_CLIENT_SECRET=your-secret
      - NZ_UUID=custom-uuid
      - NZ_DISABLE_AUTO_UPDATE=false  # 允许自动更新
      - NZ_DISABLE_FORCE_UPDATE=false # 允许强制更新
      - NZ_DISABLE_COMMAND_EXECUTE=true # 禁用命令执行
```

## Docker 环境特殊注意事项

### 1. 主机信息访问

Docker 容器默认无法访问主机的完整信息，需要挂载必要的目录：

```yaml
volumes:
  - /proc:/host/proc:ro
  - /sys:/host/sys:ro
  - /etc/os-release:/host/etc/os-release:ro
```

### 2. 网络模式

使用桥接模式可能无法获取准确的网络统计，建议使用 host 模式：

```yaml
network_mode: host
```

### 3. 权限要求

某些功能需要额外的权限：

```yaml
cap_add:
  - SYS_ADMIN
  - NET_ADMIN
  - NET_RAW
```

或使用特权模式：

```yaml
privileged: true
```

## 功能限制说明

### Docker 环境中的限制

1. **WebShell 功能**
   - 在容器中运行的 Agent 无法直接访问宿主机 Shell
   - 如需使用 WebShell，建议直接在宿主机安装 Agent

2. **主机管理功能**
   - 容器内的 Agent 无法直接管理宿主机服务
   - 某些系统级操作可能受限

3. **文件系统访问**
   - 默认只能访问容器内文件系统
   - 需要监控宿主机文件系统需额外挂载

### 建议的使用场景

**适合使用 Docker 的场景：**
- ✅ 纯监控需求（CPU、内存、网络等）
- ✅ 需要快速部署和管理多个 Agent
- ✅ 需要环境隔离
- ✅ 需要版本控制和回滚能力

**建议使用官方脚本的场景：**
- ✅ 需要使用 WebShell 功能
- ✅ 需要执行系统级管理操作
- ✅ 需要深度集成宿主机系统

## 总结

✅ **完全兼容**：Docker 镜像支持官方安装脚本的所有核心参数

✅ **功能增强**：提供了更多额外的配置选项

⚠️ **默认差异**：为适应容器环境，部分默认值有所调整（更安全、更适合容器）

✅ **易于迁移**：配置方式简单直观，迁移成本低

## 参考链接

- [DockerHub 镜像](https://hub.docker.com/r/whoerau/nezha-agent-v2)
- [Nezha 官方文档](https://nezha.wiki/)
- [官方安装脚本](https://github.com/nezhahq/scripts)
- [Agent 源代码](https://github.com/nezhahq/agent)
- [完整参数说明](PARAMETERS.md)

