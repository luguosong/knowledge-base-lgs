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
├── attachments/          # 附件（图片、文件等）
├── UOCS开发/             # UOCS 项目相关资料
├── 数学/                 # 数学学习资料
├── 文档书籍翻译/         # 文档和书籍翻译
├── 编程学习/             # 编程学习资料（按主题组织）
│   ├── java/             #   Java 技术栈（JavaSE、Spring、数据库等）
│   ├── 专项研究/         #   深度专题（Ai、Docker、Git、Linux、密码学、设计模式等）
│   ├── 前端/             #   前端技术（HTML、CSS、JS、React、Vue）
│   ├── 基础知识/         #   计算机基础（操作系统、网络、数据结构等）
│   └── 学习路线/         #   学习路径规划
└── 英语/                 # 英语学习资料

wiki/
├── index.md          # 内容目录（分类索引，每次 ingest 后更新）
├── overview.md       # 知识库全局概览（每次 ingest 后自动生成）
├── log.md            # 时间线日志（append-only，记录所有操作）
├── .status.json      # 处理状态追踪（hash、已处理文件、页面映射、pending 状态）
├── .lint-results.md  # 最近一次 Lint 结果（结构化格式）
├── .review-queue.md  # 异步审核队列（ingest 时发现的矛盾/歧义）
├── entities/         # 实体页面（人物、组织、项目等）
├── concepts/         # 概念页面（技术概念、主题、理论等）
├── sources/          # 来源摘要页面（每条资料一个摘要页）
├── synthesis/        # 综合页面（对比分析、综述、发现等）
└── queries/          # 查询归档（有价值的 query 回答存档）
```

## 核心操作

五个核心操作已封装为独立 skill，通过斜杠命令触发：

| 操作 | Skill | 触发方式 | 说明 |
|------|-------|----------|------|
| 摄入 | wiki-ingest | `/ingest` | 两步摄入（分析→生成），增量处理 raw/ 资料 |
| 查询 | wiki-query | `/query` | 图扩展 + 预算控制的智能查询 |
| 检查 | wiki-lint | `/lint` | 健康检查 + review 队列处理 |
| 删除 | wiki-delete | `/delete` | 级联删除，自动清理关联页面和引用 |
| 研究 | wiki-research | `/research` | 网络搜索 + 自动摄入填补知识缺口 |

详细的执行流程见各 skill 的 SKILL.md。本文件只定义页面格式、索引格式、元数据格式等共享规范。

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

## 概览页格式（`wiki/overview.md`）

每次 ingest 后自动生成/更新，提供知识库全局视野。query 时优先读取此页面。

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
| ... | ... | ... |

## 最近变更
- [日期] 变更描述
```

## 审核队列格式（`wiki/.review-queue.md`）

ingest 时发现的矛盾/歧义写入此文件，lint 时处理。

```markdown
### R{N}: {简短标题}
- **类型**：contradiction | ambiguity | categorization
- **来源**：[[sources/对应来源页]]
- **内容**：具体描述
- **建议操作**：创建/合并/跳过 + 具体说明
- **预生成搜索**：`qmd-node search "..."`
- **状态**：pending → resolved | dismissed
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
- 处理了 1 个 review 条目

## [2026-04-30] delete | 资料标题
- 删除了 [[sources/资料标题]]
- 删除了 [[entities/实体X]]（无其他来源）
- 更新了 [[entities/实体Z]]（移除来源引用）

## [2026-04-30] research | 研究主题
- 搜索查询：query1, query2
- 抓取了 N 个网页
- 自动摄入了搜索结果
```

## 处理状态（`wiki/.status.json`）

记录每条 raw/ 资料的处理状态，用于增量处理和 hash 追踪。

**已完成的条目**：
```json
{
  "version": 1,
  "processed": {
    "raw/路径/文件名.md": {
      "ingested_at": "2026-04-30",
      "raw_hash": "sha256-hash",
      "source_page": "wiki/sources/对应摘要页.md",
      "created_pages": [
        "wiki/concepts/概念1.md",
        "wiki/entities/实体1.md"
      ],
      "page_hashes": {
        "wiki/concepts/概念1.md": "sha256-hash",
        "wiki/entities/实体1.md": "sha256-hash"
      },
      "last_lint_at": null
    }
  }
}
```

**处理中的条目**（pending，用于崩溃恢复）：
```json
{
  "raw/路径/文件名.md": {
    "status": "pending",
    "started_at": "2026-05-09T10:30:00",
    "raw_hash": "sha256-hash"
  }
}
```

Ingest 开始处理前写入 pending 状态，完成后替换为完整记录。下次启动时扫描 pending 条目恢复中断的摄入。

**Hash 计算**：使用 `sha256sum`（Git Bash 自带），在 Ingest 完成和 Lint 完成时更新。

## 搜索工具：qmd

Wiki 集成了 qmd（本地 Markdown 混合搜索引擎），用于精准检索 Wiki 内容。

- **CLI 命令**：`qmd-node`（Windows 兼容）
- **MCP 服务器**：已配置在 `.claude/settings.json`，可通过 MCP 工具调用

### Ingest 后更新索引

每次 ingest 完成后**必须**运行：

```bash
qmd-node update && qmd-node embed
```

## 重要规则

- **优先使用 Obsidian CLI**：所有对 wiki/ 的操作（创建、读取、搜索、更新页面）优先使用 `/obsidian-cli` skill 提供的 CLI 命令，比直接文件操作更可靠，且能触发 Obsidian 的实时刷新和插件处理
- **raw/ 不可修改**：LLM 只能读取原始资料，永远不能修改或删除
- **wiki/ 由 LLM 维护**：LLM 负责创建、更新、保持一致性，用户通过 Obsidian 浏览
- **交叉引用使用 `[[wikilink]]`**：所有页面间引用使用 Obsidian 兼容的双链语法
- **每次 ingest 更新 index.md、log.md、overview.md 和 .status.json**：保持索引、概览、日志和处理状态的最新
- **有价值的结果要回填**：查询产生的洞察应存入 `wiki/synthesis/`
- **中文内容**：所有 Wiki 页面使用中文撰写，术语保留英文原文
- **页面必须有摘要**：所有新建/更新的 Wiki 页面必须包含 50-100 字的摘要段落
- **页面必须有来源追溯**：所有 wiki 页面的 frontmatter 中 `sources:` 字段必须非空，指向对应的 source 摘要页
- **hash 追踪**：ingest 和 lint 时通过 SHA-256 hash 检测文件变化，避免重复处理
- **ingest 后更新搜索索引**：每次 ingest 完成后必须运行 `qmd-node update && qmd-node embed`
- **ingest 使用 pending 状态**：处理前写入 pending 状态，完成后替换为完整记录，支持崩溃恢复
- **矛盾写入 review 队列**：ingest 发现矛盾/歧义时写入 `.review-queue.md`，不阻断流程
- **删除需要用户确认**：wiki-delete 执行前必须展示删除范围并等待用户确认

## Skill routing

When the user's request matches an available skill, invoke it via the Skill tool. When in doubt, invoke the skill.

Key routing rules:
- Product ideas/brainstorming → invoke /office-hours
- Strategy/scope → invoke /plan-ceo-review
- Architecture → invoke /plan-eng-review
- Design system/plan review → invoke /design-consultation or /plan-design-review
- Full review pipeline → invoke /autoplan
- Bugs/errors → invoke /investigate
- QA/testing site behavior → invoke /qa or /qa-only
- Code review/diff check → invoke /review
- Visual polish → invoke /design-review
- Ship/deploy/PR → invoke /ship or /land-and-deploy
- Save progress → invoke /context-save
- Resume context → invoke /context-restore
