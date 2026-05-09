#!/usr/bin/env bash
# 检查 wiki 页面是否缺少摘要段落
# 用法: bash check-missing-summary.sh <wiki_dir>
# 输出: 每行一个文件名（仅缺少摘要的），或 "ALL_OK" 表示全部通过
#
# 摘要定义：frontmatter 关闭（第二个 ---）后，跳过空行，
# 第一个非空行不应以 # 开头（否则视为缺少摘要）

set -uo pipefail

WIKI_DIR="${1:?用法: $0 <wiki_dir>}"
missing=0

check_file() {
  local file="$1"
  # awk: 找到第二个 --- 后，跳过空行，检查第一个非空行是否以 # 开头
  awk '
    BEGIN { s=0; found=0 }
    /^---$/ { s++; next }
    s==2 && !found {
      if (/^[[:space:]]*$/) next
      if (/^#/) { exit 1 }
      else { exit 0 }
    }
  ' "$file"
  return $?
}

for dir in concepts entities sources synthesis; do
  target="$WIKI_DIR/$dir"
  [ -d "$target" ] || continue
  for f in "$target"/*.md; do
    [ -f "$f" ] || continue
    if ! check_file "$f"; then
      echo "MISSING: $(basename "$f")"
      ((missing++))
    fi
  done
done

if [ "$missing" -eq 0 ]; then
  echo "ALL_OK"
else
  echo "---"
  echo "TOTAL_MISSING: $missing"
fi
