#!/bin/bash
set -e

# 检查必需的环境变量
if [ -z "$NZ_SERVER" ] || [ -z "$NZ_CLIENT_SECRET" ]; then
  echo "错误: NZ_SERVER 和 NZ_CLIENT_SECRET 环境变量必须设置"
  exit 1
fi

echo "正在启动 Nezha Agent..."
echo "服务器: $NZ_SERVER"
echo "TLS: $NZ_TLS"

# 持久化配置文件路径
CONFIG_FILE="/data/config.yml"

# 如果持久化配置文件存在，读取现有的 UUID
EXISTING_UUID=""
if [ -f "$CONFIG_FILE" ]; then
  echo "发现现有配置文件，读取 UUID..."
  EXISTING_UUID=$(grep "^uuid:" "$CONFIG_FILE" 2>/dev/null | awk '{print $2}' || echo "")
  if [ -n "$EXISTING_UUID" ]; then
    echo "使用现有 UUID: $EXISTING_UUID"
  fi
fi

# 生成配置文件
cat > "$CONFIG_FILE" <<EOF
client_secret: ${NZ_CLIENT_SECRET}
debug: ${NZ_DEBUG:-false}
disable_auto_update: ${NZ_DISABLE_AUTO_UPDATE:-false}
disable_command_execute: ${NZ_DISABLE_COMMAND_EXECUTE:-true}
disable_force_update: ${NZ_DISABLE_FORCE_UPDATE:-false}
disable_nat: ${NZ_DISABLE_NAT:-false}
disable_send_query: ${NZ_SKIP_CONN:-false}
gpu: ${NZ_GPU:-false}
insecure_tls: false
ip_report_period: ${NZ_IP_REPORT_PERIOD:-1800}
report_delay: ${NZ_REPORT_DELAY:-1}
server: ${NZ_SERVER}
skip_connection_count: ${NZ_SKIP_CONN:-false}
skip_procs_count: ${NZ_SKIP_PROCS:-false}
temperature: ${NZ_TEMPERATURE:-false}
tls: ${NZ_TLS:-false}
use_ipv6_country_code: ${NZ_USE_IPV6:-false}
EOF

# UUID 优先级：环境变量 > 现有配置 > 不设置（让 Agent 自动生成）
if [ -n "$NZ_UUID" ]; then
  echo "uuid: ${NZ_UUID}" >> "$CONFIG_FILE"
  echo "使用环境变量指定的 UUID: ${NZ_UUID}"
elif [ -n "$EXISTING_UUID" ]; then
  echo "uuid: ${EXISTING_UUID}" >> "$CONFIG_FILE"
  echo "使用持久化的 UUID: ${EXISTING_UUID}"
else
  echo "未设置 UUID，Agent 将自动生成并保存"
fi

echo "配置文件已生成:"
cat "$CONFIG_FILE"

# 启动 nezha-agent
exec /opt/nezha/agent/nezha-agent -c "$CONFIG_FILE"

