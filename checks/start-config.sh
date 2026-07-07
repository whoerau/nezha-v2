#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

fake_agent="$tmp_dir/nezha-agent"
cat >"$fake_agent" <<'AGENT'
#!/usr/bin/env bash
: "${NZ_AGENT_ENV_FILE:?}"
env >"$NZ_AGENT_ENV_FILE"
exit 0
AGENT
chmod +x "$fake_agent"

config_file="$tmp_dir/config.yml"
agent_env_file="$tmp_dir/agent.env"

NZ_SERVER="dashboard.example.com:443" \
NZ_TLS="true" \
NZ_CLIENT_SECRET="test-secret" \
NZ_UUID="11111111-1111-1111-1111-111111111111" \
NZ_CONFIG_FILE="$config_file" \
NZ_AGENT_BIN="$fake_agent" \
NZ_AGENT_ENV_FILE="$agent_env_file" \
NZ_HARD_DRIVE_PARTITION_ALLOWLIST="/,/data" \
  bash "$repo_root/start.sh" >/dev/null

grep -Fqx "temperature: true" "$config_file"
grep -Fqx "hard_drive_partition_allowlist:" "$config_file"
grep -Fqx "  - /" "$config_file"
grep -Fqx "  - /data" "$config_file"
if grep -q '^NZ_HARD_DRIVE_PARTITION_ALLOWLIST=' "$agent_env_file"; then
  echo "NZ_HARD_DRIVE_PARTITION_ALLOWLIST leaked into agent environment" >&2
  exit 1
fi
