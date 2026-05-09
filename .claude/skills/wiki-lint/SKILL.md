---
name: wiki-lint
description: 检查 LLM Wiki 知识库的健康状况。扫描所有 Wiki 页面，发现矛盾、过时信息、孤立页面、失效链接、缺失摘要等问题。触发词包括：lint、检查、wiki 检查、健康检查、检查 wiki、wiki lint、检查知识库。即使用户只说"检查一下知识库"或"wiki 有没有问题"也应该触发。不用于摄入新资料或查询知识库内容。
---

# Wiki Lint（健康检查）

扫描 Wiki 页面，发现并报告结构问题和内容问题。结果写入 `wiki/.lint-results.md`。

## 边界

只做检查和报告。不修改 raw/ 目录，不自动修复发现的问题。发现问题后提示用户确认是否修复。

不处理摄入（那是 `/ingest`）和查询（那是 `/query`）。

## 前置检查

开始前检查工具链可用性并自动修复问题：

```bash
# 1. 检查 qmd
qmd-node search "test" --files -n 1

# 2. 检查 qmd 索引目录是否指向本项目 wiki/
qmd-node collection show wiki

# 3. 检查 scripts 是否存在
ls .claude/skills/wiki-lint/scripts/
```

**qmd 索引路径不正确时，自动修复**：
```bash
# 移除旧集合，添加指向本项目 wiki/ 的新集合
qmd-node collection remove wiki
qmd-node collection add wiki "<项目根目录>/wiki"
```
修复后输出一条提示说明已自动修正。

**qmd 完全不可用时**（命令执行失败），输出提示继续执行（lint 以脚本和 LLM 判断为主，不依赖 qmd）：
```
⚠️ qmd 搜索引擎不可用，跳过搜索相关检查。引用关系和内容检查不受影响。
```

## 执行流程

### 步骤 1：确定变化页面

读取 `wiki/.status.json` 中的 `page_hashes`，用辅助脚本检查变化：

```bash
bash .claude/skills/wiki-lint/scripts/check-changes.sh wiki/
```

如果 status.json 为空或不存在，输出提示并跳过变化检测，直接执行全量检查。

### 步骤 2：引用关系检查（orphan + broken-link + missing-page）

用辅助脚本一次性完成三项检查：

```bash
bash .claude/skills/wiki-lint/scripts/check-wikilinks.sh wiki/
```

输出包含三个区域：
- `=== BROKEN-LINK ===` → 指向不存在页面的 wikilink
- `=== ORPHAN ===` → 存在但没有被引用的页面
- `=== MISSING-PAGE ===` → 3+ 次引用但无对应文件

### 步骤 3：摘要完整性检查（missing-summary）

用辅助脚本检查所有页面：

```bash
bash .claude/skills/wiki-lint/scripts/check-missing-summary.sh wiki/
```

输出每行一个缺失摘要的文件名，最后显示 `TOTAL_MISSING: N`。

### 步骤 4：内容矛盾检查（contradiction）

对同名的概念/实体在不同页面中的描述进行交叉验证。搜索高频概念在不同页面的定义：

```bash
# 提取高频概念名
grep -roh '\[\[[^]]*\]\]' wiki/ --include="*.md" | sed 's/\[\[//;s/\]\]//' | sort | uniq -c | sort -rn | head -10
```

读取排名靠前的概念在多个页面中的描述，检查是否矛盾。由于内容矛盾检查需要理解语义，这项检查由 LLM 人工判断，脚本只提供线索。

### 步骤 5：过时信息检查（stale）

对比来源摘要页的日期和概念页面的内容，看是否有更新的来源覆盖了旧信息。重点关注：
- 技术版本号是否过时
- 链接是否失效
- 日期是否与内容不匹配

### 步骤 6：补充建议（suggestion）

检查哪些高频关联主题缺少综合分析页面：
- 如果多个概念页面都提到某主题但没有 synthesis 页面，标记为建议补充

### 步骤 6.5：处理 Review 队列

读取 `wiki/.review-queue.md`，检查是否有 `状态: pending` 的条目：

- 如果有，在 Lint 报告中列出所有 pending 条目，归类为 `review-pending`
- 将 review 条目作为内容矛盾和过时信息的额外检查线索（补充步骤 4 和 5）
- 不自动修改 review 状态，只报告

### 步骤 7：写入 Lint 结果

将所有发现的问题写入 `wiki/.lint-results.md`，使用以下结构化格式：

````
---LINT: 类型 | 严重度 | 简短标题---
问题描述。
PAGES: page1.md, page2.md
---END LINT---
```

如果没有发现任何问题，写入：
````
---LINT: none | info | Wiki 健康检查通过---
所有页面检查完毕，未发现问题。
PAGES: (none)
---END LINT---
```

### 步骤 8：追加日志

在 `wiki/log.md` 末尾追加：
```markdown
## [YYYY-MM-DD] lint | Wiki 健康检查
- 发现 X 个问题（Y 个 warning，Z 个 info）
- [列出每个问题的简短标题]
```

### 步骤 9：更新元数据

更新 `wiki/.status.json` 中每个记录条目的 `last_lint_at` 为当前日期。

同时更新 `page_hashes` 为当前页面 hash（因为 Lint 检查已经计算过了）。

## 检查项速查

| 检查项 | 严重度 | 工具 | 说明 |
|--------|--------|------|------|
| contradiction | warning | LLM 判断 | 不同页面描述矛盾 |
| stale | warning | LLM 判断 | 信息过时 |
| missing-summary | warning | check-missing-summary.sh | 缺少摘要段落 |
| broken-link | warning | check-wikilinks.sh | 指向不存在页面的链接 |
| orphan | info | check-wikilinks.sh | 没有入链的孤立页面 |
| missing-page | info | check-wikilinks.sh | 高频引用但缺少页面 |
| suggestion | info | LLM 判断 | 建议创建 synthesis 页面 |
| review-pending | info | .review-queue.md | 异步等待人工审核的条目 |

## 结果汇报

检查完成后向用户汇报：
1. 发现的问题总数（按严重度分类）
2. 列出所有 warning 级别问题
3. 询问用户是否需要修复某些问题
4. 修复操作使用编辑工具直接修改页面，不需要调用其他 skill
