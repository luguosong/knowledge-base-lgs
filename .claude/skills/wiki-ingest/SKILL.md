---
name: wiki-ingest
description: 摄入新资料到 LLM Wiki 知识库。当用户提供新的文章、论文、笔记、截图等资料要求添加到知识库时使用。触发词包括：摄入、ingest、添加资料、新资料、导入、导入资料、摄入资料、添加到 wiki、加入知识库。即使用户只说"帮我整理这篇资料"或"把这个加入知识库"也应该触发。不用于查询知识库内容或检查 Wiki 健康。
---

# Wiki Ingest（资料摄入）

将新资料摄入知识库：提取关键信息，创建/更新 Wiki 页面，维护索引和元数据。

## 边界

做且只做摄入新资料。不处理查询（那是 `/query`）和健康检查（那是 `/lint`）。

如果用户的问题看起来像是在问知识库内容（"XX是什么"），引导他们使用 `/query`。

## 前置确认

1. 确认用户提供的是什么资料（文件路径、URL、粘贴的内容、截图等）
2. 如果没有明确的资料来源，用 `AskUserQuestion` 询问

## 阶段一：提取（Extract）

### 步骤 1：检查处理状态

```bash
sha256sum "raw/对应路径/文件名"
```

读取 `wiki/.status.json`，对比该文件的 hash：
- hash 一致 → 告知用户"该资料已摄入且未修改"，询问是否重新处理
- hash 不同或不存在 → 继续下一步

### 步骤 2：保存原始文件

将资料放入 `raw/` 对应子目录。归类参考：

| 资料类型 | 目标目录 |
|----------|----------|
| 编程技术资料 | `raw/编程学习/` |
| AI 相关 | `raw/编程学习/专项研究/Ai/` |
| 数学资料 | `raw/数学/` |
| 英语资料 | `raw/英语/` |
| 翻译文档 | `raw/文档书籍翻译/` |
| 项目相关 | `raw/UOCS开发/` |

不确定时放入最匹配的目录或询问用户。**raw/ 中的文件不可修改**，只做保存。

### 步骤 3：阅读并讨论

阅读资料的完整内容，与用户讨论：
- 这份资料的核心要点是什么？
- 与知识库中已有的哪些内容相关？
- 需要创建哪些新的实体和概念页面？

这一步的目的是在写文件之前对齐理解。

### 步骤 4：提取结构化数据

在对话中整理以下内容（不写文件，先给用户确认）：

**来源摘要**：
- 标题、日期、类型（article/paper/note）
- 关键要点列表
- 引用的实体和概念名称

**新建实体列表**（每个）：
- 名称 + 类型（person/organization/project/tool）+ 一句话描述

**新建概念列表**（每个）：
- 名称 + 一句话定义

**待更新页面列表**（每个）：
- 页面路径 + 要添加/修改的具体内容片段

整理完成后请用户确认，再进入阶段二。

## 阶段二：整合（Integrate）

用户确认后，逐一执行以下步骤。

### 步骤 5：批量写入文件

**优先使用 Obsidian CLI**（`/obsidian-cli` skill）创建和编辑页面。Obsidian CLI 能触发 Obsidian 的实时刷新和插件处理，比直接文件操作更可靠。只有 Obsidian CLI 不可用时，才回退到 Write/Edit 工具。

按 CLAUDE.md 中的页面格式约定，创建/更新以下页面：

1. **来源摘要页**（`wiki/sources/`）——必须包含摘要段落、核心要点、详细摘要、与现有知识的关联
2. **实体页面**（`wiki/entities/`）——必须包含摘要段落、概述、关键信息、相关实体与概念
3. **概念页面**（`wiki/concepts/`）——必须包含摘要段落、定义、关键要点、与其他概念的关系

每个页面都必须有 50-100 字的摘要段落（frontmatter 后到第一个 `##` 之间）。页面间引用使用 `[[wikilink]]` 语法。

### 步骤 6：更新索引和日志

**优先使用 Obsidian CLI** 更新索引和日志文件。

**更新 `wiki/index.md`**：在对应类别下添加新条目（链接 + 一句话摘要）。

**追加 `wiki/log.md`**：
```markdown
## [YYYY-MM-DD] ingest | 资料标题
- 创建了 [[sources/资料标题]]
- 更新了 [[entities/实体X]]
- 新增 [[concepts/概念Y]]
```

### 步骤 7：更新元数据

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

### 步骤 8：更新搜索索引

```bash
qmd-node update && qmd-node embed
```

## 质量检查清单

ingest 完成后自检：

- [ ] raw/ 文件已保存且未被修改
- [ ] 来源摘要页有摘要段落
- [ ] 所有新建实体/概念页面有摘要段落
- [ ] 页面间引用使用了 `[[wikilink]]`
- [ ] `index.md` 已更新
- [ ] `log.md` 已追加记录
- [ ] `.status.json` 已更新且 hash 正确
- [ ] `qmd-node update && qmd-node embed` 已执行
