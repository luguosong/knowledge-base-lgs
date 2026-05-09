---
name: wiki-ingest
description: 摄入新资料到 LLM Wiki 知识库。当用户提供新的文章、论文、笔记、截图等资料要求添加到知识库时使用。触发词包括：摄入、ingest、添加资料、新资料、导入、导入资料、摄入资料、添加到 wiki、加入知识库。即使用户只说"帮我整理这篇资料"或"把这个加入知识库"也应该触发。不用于查询知识库内容或检查 Wiki 健康。无参数调用时自动扫描 raw/ 目录处理未摄入的文件。
---

# Wiki Ingest（资料摄入）

将新资料摄入知识库：提取关键信息，创建/更新 Wiki 页面，维护索引和元数据。

## 边界

做且只做摄入新资料。不处理查询（那是 `/query`）和健康检查（那是 `/lint`）。

如果用户的问题看起来像是在问知识库内容（"XX是什么"），引导他们使用 `/query`。

## 前置检查

开始处理前，检查工具链可用性并自动修复问题：

```bash
# 1. 检查 qmd 搜索引擎
qmd-node search "test" --files -n 1

# 2. 检查 qmd 索引目录是否指向本项目 wiki/
qmd-node collection show wiki
```

**qmd 索引路径不正确时，自动修复**：
```bash
# 移除旧集合，添加指向本项目 wiki/ 的新集合
qmd-node collection remove wiki
qmd-node collection add wiki "<项目根目录>/wiki"
```
修复后输出一条提示说明已自动修正。路径从 `collection show wiki` 输出中提取，与本项目的 `wiki/` 目录绝对路径对比。

**qmd 完全不可用时**（命令执行失败）：
1. 输出问题报告，说明 qmd 状态和影响
2. 去重检查（步骤 2）改用 Grep 搜索 wiki/ 目录：`grep -rl "关键词" wiki/`
3. 搜索索引更新（步骤 7）跳过，在汇总报告中提醒用户安装 qmd

## 启动流程

### 前置：恢复中断的摄入

扫描 `wiki/.status.json` 中是否有 `status: "pending"` 的条目：

```python
# 伪代码：扫描 pending 条目
for path, entry in status.json["processed"].items():
    if entry.get("status") == "pending":
        print(f"中断: {path} (started at {entry['started_at']})")
```

如果有 pending 条目，输出报告并让用户选择：
- **重试**：删除该条目已创建的不完整 wiki 页面（从 `created_pages` 列表），然后重新处理
- **跳过**：将 status 改为已完成（不补全 wiki 页面），避免重复处理
- **查看**：读取该 raw 文件和已创建的页面，让用户判断

### 处理模式

根据用户输入决定处理模式：

| 用户输入 | 行为 |
|----------|------|
| `/ingest`（无参数） | 自动扫描 raw/，找到所有未处理文件，按修改时间从新到旧依次处理 |
| `/ingest raw/路径/文件.md` | 直接处理指定文件 |
| `/ingest URL` | 抓取 URL 内容，保存到 raw/ 再处理 |
| 用户粘贴内容 | 保存到 raw/ 再处理 |

### 自动扫描逻辑

1. 读取 `wiki/.status.json` 获取已处理文件列表及其 hash
2. 遍历 raw/ 下所有 `.md` 文件
3. 对每个文件计算 `sha256sum`，与 status.json 中的 hash 对比
4. hash 不存在（新文件）或 hash 不同（已修改）→ 加入待处理队列
5. 显示待处理文件列表和数量，然后直接开始处理

**不需要向用户确认**。发现未处理文件后直接进入提取流程。

### 追踪状态丢失恢复

当 status.json 的 `processed` 为空但 wiki/ 已有页面时（说明之前的摄入未记录追踪信息），使用文件时间比较来识别真正新增的文件：

```bash
# 找到 wiki 最近更新的时间戳
# 然后只处理比该时间更新的 raw 文件
find raw/ -name "*.md" -newer wiki/index.md -type f
```

这种情况下输出提示：`检测到 status.json 追踪为空但 wiki 已有内容，使用文件时间比较识别新增文件。如需补全全部追踪记录，请先运行 /lint。`

## 处理流程

对每个待处理文件，按以下步骤执行：

**开始处理前**：在 `.status.json` 中写入 pending 状态：
```json
{
  "raw/路径/文件.md": {
    "status": "pending",
    "started_at": "2026-05-09T10:30:00",
    "raw_hash": "sha256-hash"
  }
}
```

### 步骤 1：读取资料

阅读原始文件完整内容。如果文件超过 2000 行，分段读取。

### 步骤 2：检查已有内容（去重）

创建新页面前，先搜索知识库中是否已有相似内容。

**qmd 可用时**：
```bash
qmd-node search "概念名或实体名" --files
qmd-node query "相关描述" --files -n 5
```

**qmd 不可用时，用 Grep 替代**：
```bash
# 搜索已有页面内容中的关键词
grep -rl "关键词" wiki/

# 检查 index.md 中是否已有相关条目
grep "关键词" wiki/index.md
```

对于每个准备创建的实体/概念：
- 名称精确匹配 → 不创建新页面，改为更新已有页面
- 语义相似但名称不同 → 合并到已有页面，在页面中添加别名
- 完全没有 → 创建新页面

### 步骤 3：分析（Phase A）

这一步只做分析，不写任何文件。专注理解资料内容与现有知识库的关系。

分析资料内容，输出以下结构化分析清单：

**来源信息**：
- 标题、日期、类型（article/paper/note）
- 关键要点列表（3-8 个）
- 引用的实体和概念名称

**新建实体**（资料中提到有知识价值的人物、组织、项目、工具）：
- 名称 + 类型（person/organization/project/tool）+ 一句话描述

**新建概念**（资料涉及尚未收录的技术概念）：
- 名称 + 一句话定义

**与已有知识的关联**（基于步骤 2 的搜索结果）：
- 哪些已有页面需要更新，更新什么内容
- 新内容与已有页面的互补/矛盾关系

**矛盾与歧义**（如果发现）：
- 具体描述矛盾点
- 标记为 review 条目（步骤 4.5 处理）

### 步骤 4：生成（Phase B）

基于步骤 3 的分析清单，按 CLAUDE.md 中的页面格式约定，创建/更新以下页面：

1. **来源摘要页**（`wiki/sources/`）
2. **实体页面**（`wiki/entities/`）
3. **概念页面**（`wiki/concepts/`）

使用 Write/Edit 工具直接操作文件。每个页面都必须有 **50-100 字的摘要段落**（frontmatter 后到第一个 `##` 之间）。页面间引用使用 `[[wikilink]]` 语法。

**来源可追溯性检查**：写入每个 wiki 页面后，验证 frontmatter 中 `sources:` 字段非空。如果缺失，自动填充当前摄入对应的 source 摘要页 wikilink（如 `[[sources/对应摘要页]]`）。

### 步骤 4.5：生成 Review 条目

如果步骤 3 的分析中发现了矛盾或歧义，追加到 `wiki/.review-queue.md`：

```markdown
### R{N}: {简短标题}
- **类型**：contradiction | ambiguity | categorization
- **来源**：[[sources/对应来源页]]
- **内容**：具体描述发现的问题
- **建议操作**：创建新页面 / 合并到已有页面 / 跳过 + 具体说明
- **预生成搜索**：`qmd-node search "..."`（方便用户一键搜索验证）
- **状态**：pending
```

没有矛盾/歧义时跳过此步骤。

### 步骤 5：更新索引和日志

**更新 `wiki/index.md`**：在对应类别下添加新条目（链接 + 一句话摘要）。

**追加 `wiki/log.md`**：
```markdown
## [YYYY-MM-DD] ingest | 资料标题
- 创建了 [[sources/资料标题]]
- 更新了 [[entities/实体X]]
- 新增 [[concepts/概念Y]]
```

### 步骤 5.5：更新概览页

读取 `wiki/index.md` 和 `wiki/log.md` 末尾 20 行，生成/更新 `wiki/overview.md`。

**内容结构**：
```markdown
---
title: 知识库概览
last_updated: YYYY-MM-DD
page_count: N
source_count: N
---

150-200 字摘要段落，描述知识库整体覆盖范围、核心知识领域、最近摄入方向。

## 知识领域分布
| 领域 | 页面数 | 核心主题 |
|------|--------|----------|

## 最近变更
- [日期] 变更描述
```

不需要读取全部 wiki 页面，index.md + log.md 即可生成。每次 ingest 覆盖更新。

### 步骤 6：更新元数据

计算 raw 文件和所有新建/更新页面的 SHA-256 hash：
```bash
sha256sum "raw/路径/文件名" "wiki/sources/页面.md" "wiki/concepts/概念.md" ...
```

更新 `wiki/.status.json`，添加或更新对应条目：
```json
{
  "processed": {
    "raw/路径/文件名.md": {
      "ingested_at": "YYYY-MM-DD",
      "raw_hash": "sha256-hash",
      "source_page": "wiki/sources/对应摘要页.md",
      "created_pages": ["wiki/concepts/概念1.md", "wiki/entities/实体1.md"],
      "page_hashes": {
        "wiki/concepts/概念1.md": "sha256-hash",
        "wiki/entities/实体1.md": "sha256-hash"
      },
      "last_lint_at": null
    }
  }
}
```

### 步骤 7：更新搜索索引

每个文件处理完后：
```bash
qmd-node update && qmd-node embed
```

如果是批量处理多个文件，可以等全部处理完后再执行一次。

**qmd 不可用时跳过此步骤**，在汇总报告中提醒用户。

## 批量处理

当发现多个待处理文件时：

1. 按修改时间从新到旧排序，优先处理最近的资料
2. 同一主题目录下的多个文件可以合并为一条来源摘要（如 58 个 Linux 文件 → 1 个 Linux 来源摘要页）
3. 每处理完一组文件，简要报告进度
4. 全部处理完后给一个汇总报告

## 处理新资料（非 raw/ 文件）

当用户提供 URL、粘贴内容、截图等非 raw/ 文件时：

1. **URL**：抓取内容，保存到 raw/ 对应子目录
2. **粘贴内容**：保存为 .md 文件到 raw/ 对应子目录
3. **截图**：保存到 raw/attachments/，用视觉模型识别内容

归类参考：

| 资料类型 | 目标目录 |
|----------|----------|
| 编程技术资料 | `raw/编程学习/` |
| AI 相关 | `raw/编程学习/专项研究/Ai/` |
| 数学资料 | `raw/数学/` |
| 英语资料 | `raw/英语/` |
| 翻译文档 | `raw/文档书籍翻译/` |
| 项目相关 | `raw/UOCS开发/` |

保存到 raw/ 后，按上述步骤 1-6 处理。

## 质量检查清单

每个文件处理完后自检：

- [ ] raw/ 文件已保存且未被修改
- [ ] 来源摘要页有摘要段落
- [ ] 所有新建实体/概念页面有摘要段落
- [ ] 所有新建页面 frontmatter 中 `sources:` 字段非空
- [ ] 页面间引用使用了 `[[wikilink]]`
- [ ] `index.md` 已更新
- [ ] `log.md` 已追加记录
- [ ] `overview.md` 已更新
- [ ] `.status.json` 已更新且 hash 正确
- [ ] 搜索索引已更新（qmd 可用时）
