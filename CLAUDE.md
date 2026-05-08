# LLM Wiki Schema

本项目实现 Karpathy 的 LLM Wiki 模式——用 LLM 增量构建和维护个人知识库。

## 三层架构

| 层级 | 目录 | 职责 | 读写权限 |
|------|------|------|---------|
| 原始资料 | `raw/` | 不可变的源文档（文章、论文、笔记、图片） | LLM 只读，用户管理 |
| Wiki | `wiki/` | LLM 生成和维护的结构化 Markdown 页面 | LLM 读写，用户只读浏览 |
| Schema | `CLAUDE.md`（本文件） | 告诉 LLM 如何维护 Wiki 的规则 | 用户和 LLM 共同维护 |

## 目录结构

```
raw/
├── articles/    # Web 文章（用 Obsidian Web Clipper 转为 Markdown）
├── papers/      # 学术论文 PDF
├── notes/       # 个人笔记
└── assets/      # 图片和附件

wiki/
├── index.md     # 内容目录（分类索引，每次 ingest 后更新）
├── log.md       # 时间线日志（append-only，记录所有操作）
├── entities/    # 实体页面（人物、组织、项目等）
├── concepts/    # 概念页面（技术概念、主题、理论等）
├── sources/     # 来源摘要页面（每条资料一个摘要页）
└── synthesis/   # 综合页面（对比分析、综述、发现等）
```

## 核心操作

### Ingest（摄入）

当用户提供新资料时的完整流程：

1. **保存原始文件**：将资料放入 `raw/` 对应子目录（文章→`articles/`，论文→`papers/`，笔记→`notes/`，图片→`assets/`）
2. **阅读并讨论**：阅读资料，与用户讨论关键要点
3. **创建来源摘要**：在 `wiki/sources/` 创建摘要页面，包含标题、日期、来源、关键要点、引用的实体和概念
4. **更新实体页面**：在 `wiki/entities/` 创建或更新相关实体页面
5. **更新概念页面**：在 `wiki/concepts/` 创建或更新相关概念页面
6. **更新索引**：在 `wiki/index.md` 添加新条目
7. **追加日志**：在 `wiki/log.md` 追加操作记录

### Query（查询）

用户提问时的流程：

1. **读取索引**：先读取 `wiki/index.md` 定位相关页面
2. **深入阅读**：读取相关 Wiki 页面获取已整合的信息
3. **综合回答**：基于 Wiki 内容（而非原始资料）回答，附 Wiki 页面引用
4. **回填有价值的结果**：如果回答产生了新的洞察（对比分析、新发现），将其作为新页面存入 `wiki/synthesis/`

### Lint（检查）

定期检查 Wiki 健康状况：

- 页面间的矛盾或过时信息
- 没有入链的孤立页面
- 被提及但缺少独立页面的重要概念
- 缺失的交叉引用
- 可以通过网络搜索填补的知识空缺

## 页面格式约定

### 摘要段落（所有页面必须）

每个 Wiki 页面在 frontmatter（`---`）之后、第一个 `##` 标题之前，必须包含一段 **50-100 字的摘要段落**。摘要应独立可读，概括页面的核心内容。

**作用**：Query 时 LLM 只读取摘要段落即可判断相关性，避免读取全文消耗 Token。

**示例**：

````markdown
---
title: 示例页面
---

这是摘要段落，50-100 字，概括页面核心内容。Query 时 LLM 只需读取此段即可判断是否需要深入阅读全文。

## 正文标题
...
````

### 来源摘要页（`wiki/sources/`）

```markdown
---
title: 文章标题
date: 2026-04-30
type: article | paper | note
source_url: https://...
tags: [标签1, 标签2]
related_entities: [[实体1]], [[实体2]]
related_concepts: [[概念1]], [[概念2]]
---

一句话概括本文的核心内容、关键发现或价值所在。

## 核心要点
- 要点1
- 要点2

## 详细摘要
...

## 与现有知识的关联
- 与 [[概念X]] 的关系：...
```

### 实体页面（`wiki/entities/`）

```markdown
---
title: 实体名称
type: person | organization | project | tool
tags: [标签]
sources: [[sources/来源1]], [[sources/来源2]]
---

一句话描述该实体的身份、核心业务和在当前知识库中的相关性。

## 概述
...

## 关键信息
- ...

## 相关实体与概念
- [[实体Y]]：关系说明
- [[概念Z]]：关系说明
```

### 概念页面（`wiki/concepts/`）

```markdown
---
title: 概念名称
tags: [标签]
sources: [[sources/来源1]], [[sources/来源2]]
---

一句话定义该概念及其在知识体系中的位置。

## 定义
...

## 关键要点
- ...

## 与其他概念的关系
- [[概念A]]：关系说明
```

### 综合页面（`wiki/synthesis/`）

```markdown
---
title: 综合标题
type: comparison | review | analysis | discovery
date: 2026-04-30
sources: [[sources/来源1]], [[sources/来源2]]
tags: [标签]
---

一句话说明该综合分析的核心结论或发现。

## 问题/主题
...

## 分析
...

## 结论
...
```

## 索引格式（`wiki/index.md`）

按类别组织，每个条目包含链接和一行摘要：

```markdown
## 来源摘要
- [[sources/文章A]] - 一句话摘要
- [[sources/论文B]] - 一句话摘要

## 实体
- [[entities/人物X]] - 一句话描述

## 概念
- [[concepts/概念Y]] - 一句话定义

## 综合
- [[synthesis/对比Z]] - 一句话说明
```

## 日志格式（`wiki/log.md`）

append-only，每条以固定前缀开头：

```markdown
## [2026-04-30] ingest | 文章标题
- 创建了 [[sources/文章标题]]
- 更新了 [[entities/实体X]]
- 新增 [[concepts/概念Y]]

## [2026-04-30] query | 关于XX的问题
- 生成了综合页面 [[synthesis/对比分析]]

## [2026-04-30] lint | Wiki 健康检查
- 发现 2 个孤立页面
- 修复了 3 处过时引用
```

## 搜索工具：qmd

Wiki 集成了 qmd（本地 Markdown 混合搜索引擎），当 index.md 不够用时用于精确搜索。

- **CLI 命令**：`qmd-node`（Windows 兼容）
- **MCP 服务器**：已配置在 `.claude/settings.json`，可通过 MCP 工具调用

### 何时使用 qmd

- Wiki 页面超过 50 个时，Query 操作优先用 qmd 搜索
- 需要精确关键词匹配或语义搜索时
- Lint 时用 qmd 发现孤立页面和缺失引用

### 搜索工作流

1. 优先使用 MCP 工具 `query` 进行混合搜索
2. 如果 MCP 不可用，使用 CLI：`qmd-node query "查询内容"`
3. 搜索结果结合 index.md 交叉验证

### Ingest 后更新索引

每次 ingest 后运行 `qmd-node update && qmd-node embed` 更新搜索索引。

## 重要规则

- **raw/ 不可修改**：LLM 只能读取原始资料，永远不能修改或删除
- **wiki/ 由 LLM 维护**：LLM 负责创建、更新、保持一致性，用户通过 Obsidian 浏览
- **交叉引用使用 `[[wikilink]]`**：所有页面间引用使用 Obsidian 兼容的双链语法
- **每次 ingest 更新 index.md 和 log.md**：保持索引和日志的最新状态
- **查询时优先读 Wiki**：不要从原始资料重新推导，直接使用 Wiki 中已整合的信息
- **有价值的结果要回填**：查询产生的洞察应存入 `wiki/synthesis/`
- **中文内容**：所有 Wiki 页面使用中文撰写，术语保留英文原文
- **搜索工具**：Wiki 较大时用 qmd 搜索，ingest 后更新 qmd 索引
