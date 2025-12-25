# Nezha Agent Docker

🐳 哪吒监控 Agent 的 Docker 镜像版本，支持多架构部署。

## 特性

- ✅ 基于 Alpine Linux，镜像体积小
- ✅ 支持多架构：`amd64`、`arm64`、`armv7`
- ✅ 每月自动构建最新版本
- ✅ 通过环境变量灵活配置
- ✅ 支持 Docker Compose 一键部署
- ✅ 包含健康检查

## 快速开始

### 使用 Docker Compose（推荐）

1. 克隆仓库或下载 `docker-compose.yml` 文件

2. 修改 `docker-compose.yml` 中的环境变量：

   ```yaml
   environment:
     - NZ_SERVER=your-server-address:port # 你的 Nezha 服务器地址
     - NZ_TLS=true # 是否启用 TLS
     - NZ_CLIENT_SECRET=your-secret # 你的客户端密钥
     - NZ_UUID=your-fixed-uuid-here # 生成一个唯一的UUID
   ```

3. 启动容器：

   ```bash
   docker-compose up -d
   ```

4. 查看日志：
   ```bash
   docker-compose logs -f nezha-agent
   ```

### 使用 Docker 命令

```bash
docker run -d \
  --name nezha-agent \
  --restart unless-stopped \
  -e NZ_SERVER=your-server-address:port \
  -e NZ_TLS=true \
  -e NZ_CLIENT_SECRET=your-secret \
  -e NZ_UUID=your-fixed-uuid-here \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /etc/os-release:/host/etc/os-release:ro \
  whoerau/nezha-agent-v2:latest
```

## 环境变量

> 💡 **查看完整参数说明**：[PARAMETERS.md](PARAMETERS.md) 包含所有参数的详细说明、使用场景和最佳实践。

| 变量名                       | 必填 | 默认值          | 说明                                                     |
| ---------------------------- | ---- | --------------- | -------------------------------------------------------- |
| `NZ_SERVER`                  | ✅   | -               | Nezha 服务器地址，格式：`域名:端口`                      |
| `NZ_CLIENT_SECRET`           | ✅   | -               | 客户端密钥                                               |
| `NZ_UUID`                    | ✅   | -               | 客户端唯一标识（用于区分不同 Agent, 不填写每次重启会变） |
| `NZ_TLS`                     | ❌   | `false`         | 是否启用 TLS 连接                                        |
| `NZ_REPORT_DELAY`            | ❌   | `1`             | 上报延迟（秒）                                           |
| `NZ_SKIP_CONN`               | ❌   | `false`         | 跳过连接检查                                             |
| `NZ_SKIP_PROCS`              | ❌   | `false`         | 跳过进程检查                                             |
| `NZ_DISABLE_AUTO_UPDATE`     | ❌   | `false`         | 禁用自动更新（false=允许更新）                           |
| `NZ_DISABLE_FORCE_UPDATE`    | ❌   | `false`         | 禁用强制更新（false=允许更新）                           |
| `NZ_DISABLE_COMMAND_EXECUTE` | ❌   | `true`          | 禁用命令执行（安全选项，禁用后无法通过面板执行命令）     |
| `NZ_DISABLE_NAT`             | ❌   | `false`         | 禁用 NAT 穿透                                            |
| `NZ_USE_IPV6`                | ❌   | `false`         | 使用 IPv6 进行连接                                       |
| `NZ_GPU`                     | ❌   | `false`         | 启用 GPU 监控                                            |
| `NZ_TEMPERATURE`             | ❌   | `false`         | 启用温度监控                                             |
| `NZ_IP_REPORT_PERIOD`        | ❌   | `1800`          | IP 上报周期（秒）                                        |
| `NZ_DEBUG`                   | ❌   | `false`         | 调试模式（输出详细日志）                                 |
| `TZ`                         | ❌   | `Asia/Shanghai` | 时区设置                                                 |

## 配置说明

### 安全建议

**命令执行功能**：为了安全起见，本 Docker 镜像默认禁用了命令执行功能（`NZ_DISABLE_COMMAND_EXECUTE=true`）。如果你需要通过面板执行命令，可以将其设置为 `false`，但请注意安全风险。

**调试模式**：生产环境中不建议开启 `NZ_DEBUG`，因为会输出大量日志信息，可能影响性能。

### 权限配置

容器需要一些特殊权限来获取完整的系统信息：

- `SYS_ADMIN`：访问系统管理功能
- `NET_ADMIN`：访问网络管理功能
- `NET_RAW`：访问原始网络套接字

如果你需要更多权限，可以在 `docker-compose.yml` 中启用 `privileged: true`。

### GPU 和温度监控

如果需要监控 GPU 或温度信息：

1. 设置 `NZ_GPU=true` 启用 GPU 监控
2. 设置 `NZ_TEMPERATURE=true` 启用温度监控
3. 确保容器有权限访问对应的设备文件（可能需要 `privileged: true` 或挂载特定设备）

### 网络模式

默认使用桥接模式。如果需要获取更准确的网络信息，可以使用 host 模式：

```yaml
network_mode: host
```

### 挂载卷

为了获取准确的系统信息，容器需要挂载以下主机目录：

- `/proc` - 进程信息
- `/sys` - 系统信息
- `/etc/os-release` - 操作系统信息

## 本地构建

如果你想自己构建镜像：

```bash
# 构建镜像
docker build -t nezha-agent:local .

# 或者使用 docker-compose 构建
docker-compose build
```

## GitHub Actions 自动构建

本项目使用 GitHub Actions 自动构建和推送镜像到 DockerHub：

- ✅ 每月 1 号凌晨 2 点自动构建最新版本
- ✅ 推送到 main 分支时自动构建
- ✅ 支持手动触发构建
- ✅ 自动推送到 DockerHub
- ✅ 镜像标签与 Nezha Agent 版本同步（如 v1.14.1）

### 配置 DockerHub Secrets

在使用 GitHub Actions 自动构建前，需要在 GitHub 仓库中配置以下 Secrets：

1. 进入仓库的 Settings → Secrets and variables → Actions
2. 添加以下两个 secrets：
   - `DOCKERHUB_USERNAME`：你的 DockerHub 用户名
   - `DOCKERHUB_TOKEN`：你的 DockerHub Access Token（在 [DockerHub Settings](https://hub.docker.com/settings/security) 中创建）

### 手动触发构建

1. 进入仓库的 Actions 页面
2. 选择 "Build and Push Docker Image" workflow
3. 点击 "Run workflow" 按钮

## 故障排查

### 查看日志

```bash
# Docker Compose
docker-compose logs -f nezha-agent

# Docker
docker logs -f nezha-agent
```

### 常见问题

**Q: 容器启动失败，提示缺少环境变量**

A: 请确保 `NZ_SERVER` 和 `NZ_CLIENT_SECRET` 环境变量已正确设置。

**Q: Agent 无法连接到服务器**

A:

1. 检查服务器地址和端口是否正确
2. 检查 TLS 设置是否正确
3. 检查网络连接是否正常
4. 检查服务器防火墙设置

**Q: 无法获取完整的系统信息**

A:

1. 确保已挂载必要的主机目录（/proc、/sys 等）
2. 检查容器是否有足够的权限
3. 考虑使用 `privileged: true` 或 `network_mode: host`

## 更新

### 更新到最新版本

```bash
# 拉取最新镜像
docker-compose pull

# 重新创建容器
docker-compose up -d
```

## 📚 文档

- [完整参数说明](PARAMETERS.md) - 所有配置参数详解
- [兼容性说明](COMPATIBILITY.md) - 与官方脚本的兼容性
- [版本同步机制](VERSION_SYNC.md) - 镜像版本与 Agent 版本同步说明
- [构建指南](BUILD.md) - 本地构建和调试
- [DockerHub 配置](SETUP.md) - GitHub Actions 和 DockerHub 配置

## ⚠️ UUID 说明

容器重启后 UUID 会重新生成。如需固定 UUID，请在环境变量中设置 `NZ_UUID`：

```yaml
environment:
  - NZ_UUID=your-fixed-uuid-here
```

## 相关链接

- [DockerHub 镜像仓库](https://hub.docker.com/r/whoerau/nezha-agent-v2)
- [哪吒监控官方网站](https://nezha.wiki/)
- [哪吒监控 GitHub](https://github.com/nezhahq/nezha)
- [Agent 安装脚本](https://github.com/nezhahq/scripts)

## 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 贡献

欢迎提交 Issue 和 Pull Request！

## 免责声明

本项目仅为 Nezha Agent 的 Docker 封装，不对 Nezha Agent 本身的功能和安全性负责。
