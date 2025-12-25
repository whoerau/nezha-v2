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

# 生成配置文件
cat > /app/config.yml <<EOF
client_secret: ${NZ_CLIENT_SECRET}
debug: ${NZ_DEBUG:-false}
disable_auto_update: ${NZ_DISABLE_AUTO_UPDATE:-true}
disable_command_execute: ${NZ_DISABLE_COMMAND_EXECUTE:-true}
disable_force_update: ${NZ_DISABLE_FORCE_UPDATE:-true}
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

# 如果设置了 UUID，添加到配置文件
if [ -n "$NZ_UUID" ]; then
  echo "uuid: ${NZ_UUID}" >> /app/config.yml
fi

echo "配置文件已生成:"
cat /app/config.yml

# 启动 nezha-agent
exec /opt/nezha/agent/nezha-agent -c /app/config.yml

