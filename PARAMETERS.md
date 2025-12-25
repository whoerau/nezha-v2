# Nezha Agent 完整参数说明

本文档列出了 Nezha Agent 支持的所有命令行参数及其对应的环境变量。

## 参数对照表

| 命令行参数                  | 环境变量                     | 类型   | 默认值 | 说明                           |
| --------------------------- | ---------------------------- | ------ | ------ | ------------------------------ |
| `-s, --server`              | `NZ_SERVER`                  | string | -      | ✅ **必填** - Nezha 服务器地址 |
| `-p, --password`            | `NZ_CLIENT_SECRET`           | string | -      | ✅ **必填** - 客户端连接密钥   |
| `--uuid`                    | `NZ_UUID`                    | string | -      | 客户端唯一标识（可选）         |
| `--tls`                     | `NZ_TLS`                     | bool   | false  | 是否启用 TLS 加密连接          |
| `-d, --report-delay`        | `NZ_REPORT_DELAY`            | int    | 1      | 系统信息上报间隔（秒）         |
| `--skip-conn`               | `NZ_SKIP_CONN`               | bool   | false  | 跳过网络连接数检查             |
| `--skip-procs`              | `NZ_SKIP_PROCS`              | bool   | false  | 跳过进程数量检查               |
| `--disable-auto-update`     | `NZ_DISABLE_AUTO_UPDATE`     | bool   | false  | 禁用自动更新（false=允许更新） |
| `--disable-force-update`    | `NZ_DISABLE_FORCE_UPDATE`    | bool   | false  | 禁用强制更新（false=允许更新） |
| `--disable-command-execute` | `NZ_DISABLE_COMMAND_EXECUTE` | bool   | true\* | 禁用命令执行功能（安全选项）   |
| `--disable-nat`             | `NZ_DISABLE_NAT`             | bool   | false  | 禁用 NAT 穿透功能              |
| `--use-ipv6`                | `NZ_USE_IPV6`                | bool   | false  | 使用 IPv6 连接服务器           |
| `--gpu`                     | `NZ_GPU`                     | bool   | false  | 启用 GPU 信息监控              |
| `--temperature`             | `NZ_TEMPERATURE`             | bool   | false  | 启用温度信息监控               |
| `--ip-report-period`        | `NZ_IP_REPORT_PERIOD`        | int    | 1800   | IP 地址上报周期（秒）          |
| `--debug`                   | `NZ_DEBUG`                   | bool   | false  | 启用调试模式（详细日志输出）   |

> \*注：默认启用自动更新以保持 Agent 版本最新。如果希望通过 Docker 镜像控制版本，可设置为 `true` 禁用自动更新。

## 参数详细说明

### 基础连接参数

#### NZ_SERVER（必填）

- **格式**：`域名:端口` 或 `IP:端口`
- **示例**：`dashboard.example.com:5555`、`192.168.1.100:5555`
- **说明**：Nezha Dashboard 服务器地址

#### NZ_CLIENT_SECRET（必填）

- **类型**：字符串
- **获取方式**：在 Nezha Dashboard 中添加主机时生成
- **说明**：用于 Agent 和 Dashboard 之间的身份验证

#### NZ_UUID（可选）

- **类型**：字符串
- **说明**：客户端的唯一标识符，用于在 Dashboard 中区分不同的 Agent
- **使用场景**：
  - 当同一台主机运行多个 Agent 实例时
  - 需要保持 Agent 标识稳定，即使重新部署容器
  - 如果不设置，Agent 会自动生成一个 UUID
- **建议**：一般情况下可以不设置，让 Agent 自动生成

#### NZ_TLS

- **值**：`true` 或 `false`
- **说明**：是否使用 TLS 加密连接，建议在生产环境中启用

### 性能调优参数

#### NZ_REPORT_DELAY

- **单位**：秒
- **范围**：1-60
- **说明**：系统信息（CPU、内存、网络等）的上报频率
- **建议**：
  - 1 秒：实时性要求高
  - 3-5 秒：平衡性能和实时性
  - 10+ 秒：降低资源占用

#### NZ_IP_REPORT_PERIOD

- **单位**：秒
- **默认**：1800（30 分钟）
- **说明**：IP 地址变化检测和上报的周期
- **建议**：IP 地址不常变化的服务器可以设置更长的周期

#### NZ_SKIP_CONN

- **值**：`true` 或 `false`
- **说明**：跳过网络连接数统计，可以减少系统调用
- **适用场景**：不关心连接数的场景，或连接数统计导致性能问题时

#### NZ_SKIP_PROCS

- **值**：`true` 或 `false`
- **说明**：跳过进程数量统计
- **适用场景**：不关心进程数的场景

### 安全相关参数

#### NZ_DISABLE_COMMAND_EXECUTE

- **值**：`true` 或 `false`
- **Docker 默认**：`true`
- **说明**：禁用通过 Dashboard 执行命令的功能
- **安全建议**：
  - ✅ 生产环境建议保持启用（true）
  - ✅ 仅监控用途的主机应保持启用（true）
  - ⚠️ 需要远程管理的主机可以设置为 `false`，但要注意安全风险

#### NZ_DISABLE_NAT

- **值**：`true` 或 `false`
- **说明**：禁用 NAT 穿透功能
- **适用场景**：不需要 NAT 穿透的网络环境

### 更新相关参数

#### NZ_DISABLE_AUTO_UPDATE

- **值**：`true` 或 `false`
- **默认**：`false`（允许自动更新）
- **说明**：控制 Agent 是否自动更新到最新版本
- **建议**：
  - ✅ 默认 `false`（允许更新）- Agent 自动保持最新
  - ⚠️ 设为 `true` - 如果想通过 Docker 镜像控制版本

#### NZ_DISABLE_FORCE_UPDATE

- **值**：`true` 或 `false`
- **默认**：`false`（允许强制更新）
- **说明**：控制是否允许服务器强制更新 Agent
- **建议**：与 `NZ_DISABLE_AUTO_UPDATE` 保持一致

### 高级监控参数

#### NZ_GPU

- **值**：`true` 或 `false`
- **说明**：启用 GPU 使用率和信息监控
- **要求**：
  - 需要系统安装 NVIDIA 驱动
  - Docker 环境需要 NVIDIA Container Runtime
  - 可能需要 `privileged: true` 或设备挂载

#### NZ_TEMPERATURE

- **值**：`true` 或 `false`
- **说明**：启用 CPU/GPU 温度监控
- **要求**：
  - 需要访问温度传感器设备
  - 可能需要 `privileged: true`
  - Docker 环境可能需要挂载 `/sys/class/thermal` 等目录

### 网络参数

#### NZ_USE_IPV6

- **值**：`true` 或 `false`
- **说明**：使用 IPv6 连接 Dashboard
- **要求**：
  - 服务器和 Dashboard 都支持 IPv6
  - Docker 需要启用 IPv6 网络

### 调试参数

#### NZ_DEBUG

- **值**：`true` 或 `false`
- **说明**：启用详细日志输出，包括所有系统调用和数据上报信息
- **注意事项**：
  - ⚠️ 会产生大量日志
  - ⚠️ 可能影响性能
  - ⚠️ 日志可能包含敏感信息
  - ✅ 仅在排查问题时临时启用

## Docker 环境最佳实践

### 基础配置（仅监控）

```yaml
environment:
  - NZ_SERVER=your-server:port
  - NZ_TLS=true
  - NZ_CLIENT_SECRET=your-secret
  - NZ_DISABLE_AUTO_UPDATE=false # 允许自动更新
  - NZ_DISABLE_FORCE_UPDATE=false # 允许强制更新
  - NZ_DISABLE_COMMAND_EXECUTE=true # 禁用命令执行
```

### 完整监控配置

```yaml
environment:
  - NZ_SERVER=your-server:port
  - NZ_TLS=true
  - NZ_CLIENT_SECRET=your-secret
  - NZ_REPORT_DELAY=1
  - NZ_DISABLE_AUTO_UPDATE=false # 允许自动更新
  - NZ_DISABLE_FORCE_UPDATE=false # 允许强制更新
  - NZ_DISABLE_COMMAND_EXECUTE=true # 禁用命令执行
  - NZ_GPU=true # 启用 GPU 监控
  - NZ_TEMPERATURE=true # 启用温度监控
```

### 低资源占用配置

```yaml
environment:
  - NZ_SERVER=your-server:port
  - NZ_TLS=true
  - NZ_CLIENT_SECRET=your-secret
  - NZ_REPORT_DELAY=10 # 降低上报频率
  - NZ_IP_REPORT_PERIOD=3600 # 1小时上报一次 IP
  - NZ_SKIP_CONN=true # 跳过连接数统计
  - NZ_SKIP_PROCS=true # 跳过进程数统计
  - NZ_DISABLE_AUTO_UPDATE=false # 允许自动更新
  - NZ_DISABLE_FORCE_UPDATE=false # 允许强制更新
```

### IPv6 环境配置

```yaml
environment:
  - NZ_SERVER=[2001:db8::1]:5555 # IPv6 地址需要用方括号
  - NZ_TLS=true
  - NZ_CLIENT_SECRET=your-secret
  - NZ_USE_IPV6=true
  - NZ_DISABLE_AUTO_UPDATE=false # 允许自动更新
  - NZ_DISABLE_FORCE_UPDATE=false # 允许强制更新
  - NZ_DISABLE_COMMAND_EXECUTE=true # 禁用命令执行
```

## 从安装脚本迁移

如果你之前使用官方安装脚本安装，命令格式如下：

```bash
env NZ_SERVER=server:port NZ_TLS=true NZ_CLIENT_SECRET=secret ./install.sh
```

在 Docker 中等价的配置（增强安全性）：

```yaml
environment:
  - NZ_SERVER=server:port
  - NZ_TLS=true
  - NZ_CLIENT_SECRET=secret
  - NZ_DISABLE_AUTO_UPDATE=true
  - NZ_DISABLE_FORCE_UPDATE=true
  - NZ_DISABLE_COMMAND_EXECUTE=true # Docker 环境默认禁用命令执行
```

## 启用命令执行功能

如果你需要通过 Nezha Dashboard 远程执行命令，需要将命令执行功能启用：

```yaml
environment:
  - NZ_DISABLE_COMMAND_EXECUTE=false # 启用命令执行
```

**⚠️ 安全警告**：

- 启用命令执行功能意味着任何有权访问你的 Nezha Dashboard 的人都可以在此主机上执行命令
- 建议仅在受信任的网络环境中启用
- 建议配合强密码和访问控制使用
- 生产环境中建议保持禁用状态

## 故障排查

### 启用调试日志

```bash
# 临时启用调试模式
docker-compose exec nezha-agent sh -c 'export NZ_DEBUG=true && /opt/nezha/agent/nezha-agent -s $NZ_SERVER -p $NZ_CLIENT_SECRET --debug --tls'

# 或修改 docker-compose.yml
environment:
  - NZ_DEBUG=true
```

### 查看实际启动命令

```bash
docker-compose exec nezha-agent ps aux | grep nezha-agent
```

## 参考链接

- [DockerHub 镜像](https://hub.docker.com/r/whoerau/nezha-agent-v2)
- [Nezha 官方文档](https://nezha.wiki/)
- [Nezha Dashboard](https://github.com/nezhahq/nezha)
- [Nezha Agent 源代码](https://github.com/nezhahq/agent)
