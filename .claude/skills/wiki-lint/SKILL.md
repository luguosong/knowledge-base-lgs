---
name: wiki-lint
description: 检查 LLM Wiki 知识库的健康状况。扫描所有 Wiki 页面，发现矛盾、过时信息、孤立页面、失效链接、缺失摘要等问题。触发词包括：lint、检查、wiki 检查、健康检查、检查 wiki、wiki lint、检查知识库。即使用户只说"检查一下知识库"或"wiki 有没有问题"也应该触发。不用于摄入新资料或查询知识库内容。
---

# Wiki Lint（健康检查）

扫描 Wiki 页面，发现并报告结构问题和内容问题。结果写入 `wiki/.lint-results.md`。

## 边界

只做检查和报告。不修改 raw/ 目录，不自动修复发现的问题。发现问题后提示用户确认是否修复。

不处理摄入（那是 `/ingest`）和查询（那是 `/query`）。

## 执行流程

**优先使用 Obsidian CLI**（`/obsidian-cli` skill）读取和搜索 Wiki 页面。Obsidian CLI 能直接与 Obsidian vault 交互，确保读取到最新内容。

### 步骤 1：确定变化页面

读取 `wiki/.status.json` 中的 `page_hashes`，对每个记录的页面计算当前 hash：
```bash
sha256sum wiki/concepts/*.md wiki/entities/*.md wiki/sources/*.md wiki/synthesis/*.md
```

对比记录的 hash，标记有变化的页面。这些页面优先检查。

### 步骤 2：优先检查变化页面

对步骤 1 中发现的有变化的页面，逐页检查 7 项检查规则（见下方）。这些页面最可能有新引入的问题。

### 步骤 3：全量扫描

扫描 `wiki/` 下所有页面（包括没有变化的页面），逐页执行 7 项检查。

扫描范围：
- `wiki/concepts/`
- `wiki/entities/`
- `wiki/sources/`
- `wiki/synthesis/`

不扫描 `wiki/index.md`、`wiki/log.md`、`wiki/.status.json`。

### 步骤 4：写入 Lint 结果

**优先使用 Obsidian CLI** 写入结果文件。将所有发现的问题写入 `wiki/.lint-results.md`，使用以下结构化格式：

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

### 步骤 5：追加日志

**优先使用 Obsidian CLI** 更新日志。在 `wiki/log.md` 末尾追加：
```markdown
## [YYYY-MM-DD] lint | Wiki 健康检查
- 发现 X 个问题（Y 个 warning，Z 个 info）
- [列出每个问题的简短标题]
```

### 步骤 6：更新元数据

更新 `wiki/.status.json` 中每个记录条目的 `last_lint_at` 为当前日期。

同时更新 `page_hashes` 为当前页面 hash（因为 Lint 检查已经计算过了）。

## 检查项

按以下 7 项逐一检查每个页面：

### contradiction（warning）
两个或多个页面存在矛盾信息。例如概念 A 的定义在两个来源摘要中不一致。

检查方法：关注同一概念/实体在不同页面中的描述是否矛盾。

### stale（warning）
信息过时或被新资料取代。例如某技术版本已更新但 Wiki 中仍记录旧版本。

检查方法：对比来源摘要页的日期和概念页面的内容，看是否有更新的来源覆盖了旧信息。

### orphan（info）
没有入链的孤立页面——没有其他页面通过 `[[wikilink]]` 引用它。

检查方法：在所有页面中搜索该页面的 wikilink，如果没有被引用则标记为 orphan。

### broken-link（warning）
指向不存在的页面的 wikilink。即 `[[xxx]]` 中的 xxx 对应的文件不存在。

检查方法：提取所有 `[[wikilink]]` 引用，检查对应文件是否存在。

### missing-page（info）
被多个页面频繁引用但缺少独立页面。例如 3+ 个页面都引用了 `[[概念Z]]` 但 `wiki/concepts/概念Z.md` 不存在。

检查方法：统计 wikilink 引用频率，高频引用但没有对应页面的标记出来。

### missing-summary（warning）
页面缺少摘要段落。frontmatter（`---`）之后到第一个 `##` 标题之间没有正文内容。

检查方法：解析每个页面的 frontmatter 结束位置和第一个 `##` 出现位置，检查中间是否有正文。

### suggestion（info）
基于已有内容建议补充的方向。例如多个概念页面都提到了某个主题但没有综合分析。

检查方法：发现主题关联但没有 synthesis 页面的情况。

## 结果汇报

检查完成后向用户汇报：
1. 发现的问题总数（按严重度分类）
2. 列出所有 warning 级别问题
3. 询问用户是否需要修复某些问题
4. 修复操作使用编辑工具直接修改页面，不需要调用其他 skill
