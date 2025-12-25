# UUID 持久化说明

本文档说明如何保持 Nezha Agent 的 UUID 在容器重启后不变。

## 🔑 为什么需要 UUID 持久化

### 问题描述

Nezha Agent 使用 UUID 来唯一标识一台主机。如果 UUID 每次重启都变化：

- ❌ Dashboard 会显示多个重复的主机记录
- ❌ 历史数据无法关联到同一台主机
- ❌ 需要重新配置告警规则

### 解决方案

通过持久化配置文件来保存 UUID。

## 📂 持久化方案

### 方案 1：挂载数据目录（推荐）

在 `docker-compose.yml` 中已经配置了数据目录挂载：

```yaml
volumes:
  - ./data:/data  # 持久化配置文件
```

**工作原理：**

1. 首次启动时，Agent 生成 UUID 并保存到 `/data/config.yml`
2. 容器重启时，脚本会读取现有的 UUID
3. UUID 保持不变，Dashboard 中显示为同一台主机

### 方案 2：手动指定 UUID

在环境变量中指定固定的 UUID：

```yaml
environment:
  - NZ_UUID=your-custom-uuid-here
```

**获取现有 UUID：**

```bash
# 查看当前 UUID
docker-compose exec nezha-agent cat /data/config.yml | grep uuid

# 或查看 Dashboard 显示的 UUID
```

## 🚀 使用方法

### 首次部署

```bash
# 1. 启动容器
docker-compose up -d

# 2. 查看生成的 UUID
docker-compose exec nezha-agent cat /data/config.yml | grep uuid

# 3. 在 Dashboard 中记录这个 UUID
```

### 重启容器

```bash
# 正常重启，UUID 会保持不变
docker-compose restart

# 或停止后重新启动
docker-compose down
docker-compose up -d

# 验证 UUID 是否保持
docker-compose exec nezha-agent cat /data/config.yml | grep uuid
```

### 迁移到新主机

如果要在新主机上使用相同的 UUID：

**方法 1：复制数据目录**

```bash
# 在旧主机上
tar -czf nezha-data.tar.gz data/

# 传输到新主机
scp nezha-data.tar.gz new-host:/path/to/nezha-v2/

# 在新主机上
tar -xzf nezha-data.tar.gz
docker-compose up -d
```

**方法 2：手动设置 UUID**

```yaml
# 在 docker-compose.yml 中添加
environment:
  - NZ_UUID=从旧主机复制的UUID
```

## 📋 UUID 优先级

启动脚本会按以下优先级使用 UUID：

1. **环境变量 `NZ_UUID`** - 最高优先级
2. **持久化文件中的 UUID** - 如果文件存在
3. **自动生成** - 如果都没有，Agent 会自动生成

```bash
# 优先级示例
if [ -n "$NZ_UUID" ]; then
  使用环境变量的 UUID
elif [ -f /data/config.yml ] && [ UUID存在 ]; then
  使用持久化的 UUID
else
  Agent 自动生成新 UUID
fi
```

## 🔍 验证持久化

### 检查数据目录

```bash
# 查看数据目录
ls -la ./data/

# 应该看到
# drwxr-xr-x  data/
# -rw-r--r--  data/config.yml
```

### 查看配置文件

```bash
# 查看完整配置
docker-compose exec nezha-agent cat /data/config.yml

# 只看 UUID
docker-compose exec nezha-agent cat /data/config.yml | grep uuid
```

### 测试重启

```bash
# 1. 记录当前 UUID
UUID_BEFORE=$(docker-compose exec nezha-agent cat /data/config.yml | grep uuid | awk '{print $2}')
echo "重启前 UUID: $UUID_BEFORE"

# 2. 重启容器
docker-compose restart

# 3. 等待几秒
sleep 5

# 4. 检查 UUID
UUID_AFTER=$(docker-compose exec nezha-agent cat /data/config.yml | grep uuid | awk '{print $2}')
echo "重启后 UUID: $UUID_AFTER"

# 5. 比较
if [ "$UUID_BEFORE" = "$UUID_AFTER" ]; then
  echo "✅ UUID 持久化成功！"
else
  echo "❌ UUID 发生变化！"
fi
```

## ⚠️ 注意事项

### 不要删除 data 目录

```bash
# ❌ 错误操作 - 会导致 UUID 丢失
rm -rf ./data/

# ✅ 正确操作 - 如果确实需要重置
docker-compose down
mv ./data/ ./data.backup/  # 备份而不是删除
docker-compose up -d
```

### 备份 UUID

定期备份 data 目录：

```bash
# 定期备份脚本
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
tar -czf "nezha-data-backup-${DATE}.tar.gz" data/
echo "备份完成: nezha-data-backup-${DATE}.tar.gz"
```

### 权限问题

如果遇到权限错误：

```bash
# 检查权限
ls -la ./data/

# 修复权限（如果需要）
sudo chown -R $USER:$USER ./data/
chmod -R 755 ./data/
```

## 🔄 常见场景

### 场景 1：容器正常重启

```yaml
# UUID 自动保持，无需任何操作
docker-compose restart
```

✅ UUID 保持不变

### 场景 2：完全重新部署

```bash
# 保留 data 目录
docker-compose down
docker-compose pull
docker-compose up -d
```

✅ UUID 保持不变（因为 data 目录未删除）

### 场景 3：更换服务器地址

```yaml
# 只修改环境变量
environment:
  - NZ_SERVER=new-server:port  # 新服务器地址
  # UUID 会自动从 data/config.yml 读取
```

✅ UUID 保持不变

### 场景 4：清空所有数据重新开始

```bash
# 完全重置
docker-compose down
rm -rf ./data/
docker-compose up -d
```

❌ UUID 会重新生成（这是预期行为）

## 🛠️ 故障排查

### 问题 1：UUID 仍然变化

**检查：**

```bash
# 1. 确认 volume 挂载
docker-compose config | grep -A 5 volumes

# 2. 检查数据目录
ls -la ./data/

# 3. 检查容器内路径
docker-compose exec nezha-agent ls -la /data/

# 4. 查看启动日志
docker-compose logs nezha-agent | grep UUID
```

### 问题 2：配置文件不存在

```bash
# 检查挂载
docker-compose exec nezha-agent ls -la /data/

# 如果目录为空，检查 volume 配置
docker-compose exec nezha-agent mount | grep /data
```

### 问题 3：权限被拒绝

```bash
# 检查权限
docker-compose exec nezha-agent ls -la /data/

# 修改权限
docker-compose exec nezha-agent chmod 777 /data
```

## 📊 监控 UUID 变化

创建监控脚本：

```bash
#!/bin/bash
# monitor-uuid.sh

UUID_FILE="./data/config.yml"
LAST_UUID_FILE="./last_uuid.txt"

if [ -f "$UUID_FILE" ]; then
  CURRENT_UUID=$(grep "^uuid:" "$UUID_FILE" | awk '{print $2}')
  
  if [ -f "$LAST_UUID_FILE" ]; then
    LAST_UUID=$(cat "$LAST_UUID_FILE")
    
    if [ "$CURRENT_UUID" != "$LAST_UUID" ]; then
      echo "⚠️  UUID 发生变化！"
      echo "旧 UUID: $LAST_UUID"
      echo "新 UUID: $CURRENT_UUID"
      # 可以发送告警通知
    else
      echo "✅ UUID 保持不变: $CURRENT_UUID"
    fi
  fi
  
  echo "$CURRENT_UUID" > "$LAST_UUID_FILE"
else
  echo "⚠️  配置文件不存在"
fi
```

## 🎯 最佳实践

1. **使用数据目录挂载**（默认配置）
   - ✅ 简单可靠
   - ✅ 无需手动管理
   - ✅ 支持自动备份

2. **定期备份 data 目录**
   ```bash
   # 添加到 crontab
   0 2 * * * cd /path/to/nezha-v2 && tar -czf backup/data-$(date +\%Y\%m\%d).tar.gz data/
   ```

3. **监控 UUID 变化**
   - 定期检查 UUID 是否保持
   - 在 Dashboard 中确认主机数量

4. **迁移前备份**
   - 迁移到新主机前，务必备份 data 目录

## 📚 相关文档

- [完整参数说明](PARAMETERS.md)
- [Docker Compose 配置](docker-compose.yml)
- [启动脚本源码](start.sh)

