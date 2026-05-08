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
├── index.md          # 内容目录（分类索引，每次 ingest 后更新）
├── log.md            # 时间线日志（append-only，记录所有操作）
├── .status.json      # 处理状态追踪（hash、已处理文件、页面映射）
├── .lint-results.md  # 最近一次 Lint 结果（结构化格式）
├── entities/         # 实体页面（人物、组织、项目等）
├── concepts/         # 概念页面（技术概念、主题、理论等）
├── sources/          # 来源摘要页面（每条资料一个摘要页）
└── synthesis/        # 综合页面（对比分析、综述、发现等）
```

## 核心操作

### Ingest（摄入）

当用户提供新资料时，分为两个阶段执行：

#### 阶段一：提取（Extract）

1. **检查处理状态**：计算 raw 文件的 SHA-256 hash，查询 `wiki/.status.json` 判断是否已处理。若 hash 一致则提示"该资料已摄入且未修改"并询问用户是否重新处理
2. **保存原始文件**：将资料放入 `raw/` 对应子目录（文章→`articles/`，论文→`papers/`，笔记→`notes/`，图片→`assets/`）
3. **阅读并讨论**：阅读资料，与用户讨论关键要点
4. **提取结构化数据**（不写文件，在对话中确认以下内容）：
   - 来源摘要：标题、日期、关键要点列表、引用的实体和概念名称
   - 新建实体列表：每个实体提供名称 + 类型（person/organization/project/tool）+ 一句话描述
   - 新建概念列表：每个概念提供名称 + 一句话定义
   - 待更新页面列表：页面路径 + 要添加/修改的具体内容片段

#### 阶段二：整合（Integrate）

5. **批量写入文件**（基于阶段一的确认结果，逐一执行）：
   - 创建来源摘要页（必须包含摘要段落）
   - 创建/更新实体页面（必须包含摘要段落）
   - 创建/更新概念页面（必须包含摘要段落）
6. **更新索引和日志**：
   - 更新 `wiki/index.md`
   - 追加 `wiki/log.md`
7. **更新元数据**：
   - 计算 raw 文件和新建页面的 SHA-256 hash
   - 更新 `wiki/.status.json`
8. **更新搜索索引**：运行 `qmd-node update && qmd-node embed`

### Query（查询）

用户提问时的流程：

1. **qmd 搜索**：使用 qmd 混合搜索（优先 MCP 工具，回退 CLI），获取匹配页面和段落
2. **读取摘要**：读取每个匹配页面的摘要段落（frontmatter 后到第一个 `##` 之间的内容）
3. **聚合排序**：按以下规则对匹配页面排序：
   - 同一页面命中多个段落 → 排名提升
   - 概念页面 > 来源摘要页面（概念页更精炼）
   - 被更多页面引用的页面 → 微调提升
4. **深入阅读**：仅对 top 3 页面读取全文
5. **综合回答**：基于 Wiki 内容（而非原始资料）回答，附 `[[wikilink]]` 页面引用
6. **回填洞察**：如果回答产生了新的洞察（对比分析、新发现），将其作为新页面存入 `wiki/synthesis/`

#### 搜索回退策略

1. 先尝试 qmd 混合搜索（默认）
2. 结果不足 3 个页面时，回退到读取 `wiki/index.md` 手动定位
3. 仍然不足时，提示用户可能需要 Lint 或补充相关资料

### Lint（检查）

定期检查 Wiki 健康状况。输出使用结构化格式，结果写入 `wiki/.lint-results.md`。

#### Lint 输出格式

每个问题必须使用以下格式：

````
---LINT: 类型 | 严重度 | 简短标题---
问题描述。
PAGES: page1.md, page2.md
---END LINT---
````

#### 检查项

| 类型 | 严重度 | 说明 |
|------|--------|------|
| contradiction | warning | 两个或多个页面存在矛盾 |
| stale | warning | 信息过时或被新资料取代 |
| orphan | info | 没有入链的孤立页面 |
| broken-link | warning | 指向不存在的页面的 wikilink |
| missing-page | info | 被频繁引用但缺少独立页面的概念 |
| missing-summary | warning | 页面缺少摘要段落（frontmatter 后到第一个 `##` 之间无正文） |
| suggestion | info | 建议补充的来源或方向 |

#### Lint 执行流程

1. 读取 `wiki/.status.json` 中的 `page_hashes`，对比当前文件 hash 确定变化页面
2. 优先检查有变化的页面
3. 扫描所有页面执行结构化检查
4. 将所有 `---LINT---` 结果写入 `wiki/.lint-results.md`
5. 追加 `wiki/log.md` 记录本次 Lint
6. 更新 `wiki/.status.json` 中的 `last_lint_at`

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

## 处理状态（`wiki/.status.json`）

记录每条 raw/ 资料的处理状态，用于增量处理和 hash 追踪。

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

**Hash 计算**：使用 `sha256sum`（Git Bash 自带），在 Ingest 完成和 Lint 完成时更新。

**用途**：
- Ingest 前：对比 raw_hash 判断资料是否需要重新处理
- Lint 前：对比 page_hashes 判断哪些页面被外部修改，优先检查

## 搜索工具：qmd

Wiki 集成了 qmd（本地 Markdown 混合搜索引擎），用于精准检索 Wiki 内容。

- **CLI 命令**：`qmd-node`（Windows 兼容）
- **MCP 服务器**：已配置在 `.claude/settings.json`，可通过 MCP 工具调用

### 使用优先级

- Wiki 页面超过 20 个时，**所有 Query 操作必须优先使用 qmd 搜索**
- 低于 20 个页面时，可直接读取 `index.md` 定位

### 搜索工作流

1. 优先使用 MCP 工具 `query` 进行混合搜索
2. 如果 MCP 不可用，使用 CLI：`qmd-node query "查询内容"`
3. 搜索结果按聚合排序规则处理（见 Query 流程）

### Ingest 后更新索引

每次 ingest 完成后**必须**运行：

```bash
qmd-node update && qmd-node embed
```

## 重要规则

- **raw/ 不可修改**：LLM 只能读取原始资料，永远不能修改或删除
- **wiki/ 由 LLM 维护**：LLM 负责创建、更新、保持一致性，用户通过 Obsidian 浏览
- **交叉引用使用 `[[wikilink]]`**：所有页面间引用使用 Obsidian 兼容的双链语法
- **每次 ingest 更新 index.md、log.md 和 .status.json**：保持索引、日志和处理状态的最新
- **查询时优先用 qmd 搜索**：不要先读 index.md，先用 qmd 搜索，只读摘要判断相关性
- **有价值的结果要回填**：查询产生的洞察应存入 `wiki/synthesis/`
- **中文内容**：所有 Wiki 页面使用中文撰写，术语保留英文原文
- **页面必须有摘要**：所有新建/更新的 Wiki 页面必须包含 50-100 字的摘要段落
- **hash 追踪**：ingest 和 lint 时通过 SHA-256 hash 检测文件变化，避免重复处理
- **ingest 后更新搜索索引**：每次 ingest 完成后必须运行 `qmd-node update && qmd-node embed`
