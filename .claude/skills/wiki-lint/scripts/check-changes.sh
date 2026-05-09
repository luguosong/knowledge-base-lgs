#!/usr/bin/env bash
# 检查 status.json 追踪的页面 hash 变化
# 用法: bash check-changes.sh <wiki_dir>
# 输出: 变化页面列表，或 "NO_CHANGES" 表示无变化

set -euo pipefail

WIKI_DIR="${1:?用法: $0 <wiki_dir>}"
STATUS_FILE="$WIKI_DIR/.status.json"

if [ ! -f "$STATUS_FILE" ]; then
  echo "ERROR: $STATUS_FILE not found"
  exit 1
fi

changed=0

# 提取所有 page_hashes 中的路径和 hash
# 使用 python 来解析 JSON（比 jq 更通用）
python3 -c "
import json, sys
with open('$STATUS_FILE', 'r', encoding='utf-8') as f:
    data = json.load(f)
for raw_file, info in data.get('processed', {}).items():
    for page_path, expected_hash in info.get('page_hashes', {}).items():
        print(f'{page_path}\t{expected_hash}')
" 2>/dev/null | while IFS=$'\t' read -r page_path expected_hash; do
  [ -z "$page_path" ] && continue
  full_path="$WIKI_DIR/../$page_path"
  if [ ! -f "$full_path" ]; then
    echo "DELETED: $page_path"
    ((changed++)) || true
    continue
  fi
  actual_hash=$(sha256sum "$full_path" | awk '{print $1}')
  if [ "$actual_hash" != "$expected_hash" ]; then
    echo "CHANGED: $page_path"
    ((changed++)) || true
  fi
done

# 如果没有变化
if [ "$changed" -eq 0 ]; then
  echo "NO_CHANGES"
fi
