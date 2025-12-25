# DockerHub 配置指南

## 🚀 快速配置步骤

### 1. 创建 DockerHub Access Token

1. 访问 [DockerHub Security Settings](https://hub.docker.com/settings/security)
2. 点击 "New Access Token"
3. 填写 Token 描述（例如：GitHub Actions）
4. 选择权限：Read, Write, Delete（推荐）或 Read & Write
5. 点击 "Generate" 生成 Token
6. **立即复制 Token**（只会显示一次！）

### 2. 在 GitHub 仓库中配置 Secrets

1. 进入你的 GitHub 仓库
2. 点击 Settings → Secrets and variables → Actions
3. 点击 "New repository secret" 添加以下两个 secrets：

#### Secret 1: DOCKERHUB_USERNAME

- Name: `DOCKERHUB_USERNAME`
- Value: 你的 DockerHub 用户名（例如：`whoerau`）

#### Secret 2: DOCKERHUB_TOKEN

- Name: `DOCKERHUB_TOKEN`
- Value: 刚才复制的 Access Token

### 3. 推送代码到 GitHub

```bash
git add .
git commit -m "feat: 配置 DockerHub 自动构建"
git push origin main
```

### 4. 验证自动构建

1. 推送代码后，GitHub Actions 会自动触发构建
2. 访问仓库的 Actions 页面查看构建进度
3. 构建成功后，镜像会自动推送到 DockerHub
4. 访问 `https://hub.docker.com/r/你的用户名/nezha-agent` 查看镜像

## 📋 镜像标签说明

GitHub Actions 会自动生成以下标签：

- `latest` - 最新版本（始终指向最新构建）
- `v1.14.1` - Nezha Agent 版本号（与官方版本同步）
- `20250125` - 构建日期标签（备份使用）

**示例：**

```bash
# 使用最新版本
docker pull whoerau/nezha-agent-v2:latest

# 使用特定版本
docker pull whoerau/nezha-agent-v2:v1.14.1

# 使用日期版本
docker pull whoerau/nezha-agent-v2:20250125
```

## 🔄 手动触发构建

如果需要立即构建镜像：

1. 进入仓库的 Actions 页面
2. 选择 "Build and Push Docker Image" workflow
3. 点击 "Run workflow" 按钮
4. 选择分支（通常是 main）
5. 点击 "Run workflow" 确认

## 📅 自动构建计划

- **每月自动构建**：每月 1 号凌晨 2:00（UTC）- 确保使用最新 Nezha Agent 版本
- **代码推送触发**：修改 Dockerfile 或 workflow 文件时
- **手动触发**：随时可以手动触发构建
- **版本同步**：自动获取并使用 Nezha Agent 的最新版本号作为镜像标签

## 🔍 故障排查

### 构建失败：认证错误

如果出现认证失败，检查：

1. DOCKERHUB_USERNAME 和 DOCKERHUB_TOKEN 是否正确设置
2. Access Token 是否有足够的权限
3. Token 是否已过期（需要重新生成）

### 推送失败：仓库不存在

确保 DockerHub 上已经存在对应的仓库：

1. 登录 DockerHub
2. 首次推送前，仓库会自动创建
3. 或者手动创建仓库：https://hub.docker.com/repository/create

### 镜像名称配置

当前镜像名称为 `whoerau/nezha-agent-v2`。如果你的 DockerHub 用户名不是 `whoerau`，需要修改：

1. `.github/workflows/docker-build.yml` 中的 `IMAGE_NAME` 环境变量
2. `docker-compose.yml` 中的 `image` 字段
3. `README.md` 中的相关说明

## 🎉 完成！

配置完成后，你的 Nezha Agent 镜像将会：

- ✅ 每月自动更新
- ✅ 支持多架构（amd64、arm64、armv7）
- ✅ 自动推送到 DockerHub
- ✅ 可以通过 `docker pull whoerau/nezha-agent-v2:latest` 获取

## 📦 使用镜像

```bash
# 拉取镜像
docker pull whoerau/nezha-agent-v2:latest

# 或使用 docker-compose
docker-compose pull
docker-compose up -d
```
