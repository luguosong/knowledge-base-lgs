#!/usr/bin/env bash
# 检查 wikilink 引用关系
# 用法: bash check-wikilinks.sh <wiki_dir>
# 输出: 结构化报告，包含 broken-link、orphan、missing-page
#
# 检查项：
#   broken-link: [[xxx]] 引用的文件不存在
#   orphan: 存在但没有被任何 [[wikilink]] 引用的页面
#   missing-page: 被 3+ 个 [[wikilink]] 引用但没有对应文件

set -euo pipefail

WIKI_DIR="${1:?用法: $0 <wiki_dir>}"

# 临时文件
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# 1. 提取所有 wikilink 引用（去重后统计频率）
# 同时收集带路径和不带路径的引用
grep -ro '\[\[[^]]*\]\]' "$WIKI_DIR/" --include="*.md" 2>/dev/null | \
  sed 's/.*\[\[//' | sed 's/\]\]//' | sed 's/|.*//' | \
  sort | uniq -c | sort -rn > "$TMPDIR/all_links.txt"

# 2. 获取所有现有页面（不含 index.md/log.md/.*.md）
find "$WIKI_DIR" -name "*.md" -not -name "index.md" -not -name "log.md" -not -name ".*" -type f | \
  while read -r f; do
    # 输出相对路径（去掉 wiki/ 前缀和 .md 后缀）
    rel="${f#$WIKI_DIR/}"
    rel="${rel%.md}"
    echo "$rel"
  done | sort > "$TMPDIR/existing_pages.txt"

# 3. 构建引用集合（将短名称解析到实际路径）
# 对于不带路径的引用，尝试在 concepts/entities/sources/synthesis 中匹配
cat "$TMPDIR/all_links.txt" | while read -r count link; do
  [ -z "$link" ] && continue
  # 如果引用已包含路径（如 sources/xxx），直接用
  if echo "$link" | grep -q '/'; then
    echo "$link"
  else
    # 不带路径的引用，尝试解析
    for dir in concepts entities sources synthesis; do
      if [ -f "$WIKI_DIR/$dir/$link.md" ]; then
        echo "$dir/$link"
        break
      fi
    done
  fi
done | sort | uniq -c | sort -rn > "$TMPDIR/resolved_refs.txt"

# 4. Broken-link 检查：引用的页面不存在
echo "=== BROKEN-LINK ==="
broken=0
while read -r count link; do
  [ -z "$link" ] && continue
  # 跳过带路径的引用检查
  if echo "$link" | grep -q '/'; then
    [ -f "$WIKI_DIR/$link.md" ] || { echo "  $link (引用 $count 次)"; ((broken++)) || true; }
  fi
done < "$TMPDIR/all_links.txt"
[ "$broken" -eq 0 ] && echo "  (none)"

# 5. Orphan 检查：存在但从未被引用
echo "=== ORPHAN ==="
orphan=0
while read -r page; do
  [ -z "$page" ] && continue
  basename_page="$(basename "$page")"
  # 检查是否被引用（完整路径或短名称）
  if ! grep -q "$page\|$basename_page" "$TMPDIR/all_links.txt" 2>/dev/null; then
    echo "  $page"
    ((orphan++)) || true
  fi
done < "$TMPDIR/existing_pages.txt"
[ "$orphan" -eq 0 ] && echo "  (none)"

# 6. Missing-page 检查：3+ 次引用但没有对应文件
echo "=== MISSING-PAGE ==="
missing=0
while read -r count link; do
  [ -z "$link" ] && continue
  [ "$count" -lt 3 ] && continue
  # 检查是否存在对应文件
  found=0
  if echo "$link" | grep -q '/'; then
    [ -f "$WIKI_DIR/$link.md" ] && found=1
  else
    for dir in concepts entities sources synthesis; do
      [ -f "$WIKI_DIR/$dir/$link.md" ] && { found=1; break; }
    done
  fi
  [ "$found" -eq 0 ] && { echo "  $link (引用 $count 次，无对应页面)"; ((missing++)) || true; }
done < "$TMPDIR/all_links.txt"
[ "$missing" -eq 0 ] && echo "  (none)"
