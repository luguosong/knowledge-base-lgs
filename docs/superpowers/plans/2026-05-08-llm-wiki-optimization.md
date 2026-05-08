# LLM Wiki 架构优化实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 基于 nashsu/llm_wiki 参考项目的优化理念，通过修改 CLAUDE.md Schema 层和新增约定文件，提升 Wiki 的查询精准度、降低 Token 消耗、加快摄入速度。

**Architecture:** 所有优化都通过修改 Schema 层（CLAUDE.md）和新增元数据文件实现，不引入新的外部依赖。核心改动包括：页面摘要约定、两步入库管道、qmd 深度集成、增量 hash 追踪、结构化 Lint。

**Tech Stack:** Claude Code CLI、qmd 搜索引擎、Markdown 文件系统、Git Bash（sha256sum）

---

## 文件结构

| 文件 | 操作 | 职责 |
|------|------|------|
| `CLAUDE.md` | 修改 | 核心改动——更新页面格式约定、Ingest/Query/Lint 流程、新增 .status.json 说明 |
| `wiki/.status.json` | 新建 | 处理状态追踪文件（含 hash） |
| `wiki/.lint-results.md` | 新建 | Lint 结果存储 |

---

### Task 1: CLAUDE.md — 添加页面摘要约定

**Files:**
- Modify: `CLAUDE.md:64-149`（页面格式约定部分）

- [ ] **Step 1: 在页面格式约定章节开头添加摘要规则说明**

在 `## 页面格式约定` 标题之后、第一个 `### 来源摘要页` 之前，插入摘要约定说明：

```markdown
### 摘要段落（所有页面必须）

每个 Wiki 页面在 frontmatter（`---`）之后、第一个 `##` 标题之前，必须包含一段 **50-100 字的摘要段落**。摘要应独立可读，概括页面的核心内容。

**作用**：Query 时 LLM 只读取摘要段落即可判断相关性，避免读取全文消耗 Token。

**示例**：
```markdown
---
title: 网络安全
tags: [网络安全]
---

网络安全是通过技术和管理手段保护系统免受攻击的综合性学科。核心是攻防对抗的认知升级，涵盖 Web 安全、二进制安全、内网渗透等分支。

## 定义
...
```
```

- [ ] **Step 2: 更新所有四种页面类型的格式模板**

在每种页面类型的代码块中，frontmatter 闭合 `---` 之后、第一个 `##` 之前，插入摘要行。

**来源摘要页**（`### 来源摘要页`），将代码块替换为：

```markdown
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
```

**实体页面**（`### 实体页面`），在 frontmatter 后插入：

```markdown
一句话描述该实体的身份、核心业务和在当前知识库中的相关性。
```

**概念页面**（`### 概念页面`），在 frontmatter 后插入：

```markdown
一句话定义该概念及其在知识体系中的位置。
```

**综合页面**（`### 综合页面`），在 frontmatter 后插入：

```markdown
一句话说明该综合分析的核心结论或发现。
```

- [ ] **Step 3: 验证改动**

用 Read 工具读取 CLAUDE.md，确认：
1. 摘要约定说明在 `## 页面格式约定` 下、第一个 `###` 之前
2. 四种页面模板都包含摘要行（frontmatter 后、第一个 `##` 前）
3. 没有破坏其他内容的缩进和格式

- [ ] **Step 4: 提交**

```bash
git add CLAUDE.md
git commit -m "docs(schema): 添加页面摘要约定（TL;DR）"
```

---

### Task 2: CLAUDE.md — 重写 Ingest 流程为两步入库管道

**Files:**
- Modify: `CLAUDE.md:33-43`（Ingest 部分）

- [ ] **Step 1: 替换 Ingest 流程**

将当前的 `### Ingest（摄入）` 部分整体替换为：

```markdown
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
```

- [ ] **Step 2: 验证改动**

读取 CLAUDE.md 确认：
1. Ingest 部分有两个清晰的阶段标题
2. 步骤编号从 1-8 连续
3. 提到了 `.status.json` 和 hash 检查
4. 没有破坏后续的 Query/Lint 部分

- [ ] **Step 3: 提交**

```bash
git add CLAUDE.md
git commit -m "docs(schema): 重写 Ingest 流程为两步入库管道"
```

---

### Task 3: CLAUDE.md — 重写 Query 流程并深化 qmd 集成

**Files:**
- Modify: `CLAUDE.md:45-52`（Query 部分）
- Modify: `CLAUDE.md:188-209`（qmd 搜索工具部分）

- [ ] **Step 1: 替换 Query 流程**

将当前的 `### Query（查询）` 部分整体替换为：

```markdown
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
```

- [ ] **Step 2: 更新 qmd 搜索工具章节**

将当前的 `## 搜索工具：qmd` 部分替换为：

```markdown
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
```

- [ ] **Step 3: 验证改动**

读取 CLAUDE.md 确认：
1. Query 部分有清晰的 6 步流程 + 回退策略
2. qmd 章节的阈值从 50 降为 20（更积极使用搜索）
3. 两部分之间没有重复或矛盾
4. 后续的 Lint 和页面格式部分未被破坏

- [ ] **Step 4: 提交**

```bash
git add CLAUDE.md
git commit -m "docs(schema): 重写 Query 流程并深化 qmd 集成"
```

---

### Task 4: CLAUDE.md — 重写 Lint 流程为结构化输出

**Files:**
- Modify: `CLAUDE.md:54-63`（Lint 部分）

- [ ] **Step 1: 替换 Lint 部分**

将当前的 `### Lint（检查）` 部分整体替换为：

```markdown
### Lint（检查）

定期检查 Wiki 健康状况。输出使用结构化格式，结果写入 `wiki/.lint-results.md`。

#### Lint 输出格式

每个问题必须使用以下格式：

```
---LINT: 类型 | 严重度 | 简短标题---
问题描述。
PAGES: page1.md, page2.md
---END LINT---
```

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
```

- [ ] **Step 2: 验证改动**

读取 CLAUDE.md 确认：
1. Lint 部分有结构化输出格式定义
2. 7 种检查类型都已列出
3. 执行流程从 1-6 编号连续
4. 提到了 `.lint-results.md` 和 `.status.json`

- [ ] **Step 3: 提交**

```bash
git add CLAUDE.md
git commit -m "docs(schema): 重写 Lint 流程为结构化输出"
```

---

### Task 5: CLAUDE.md — 更新目录结构和重要规则

**Files:**
- Modify: `CLAUDE.md:13-29`（目录结构部分）
- Modify: `CLAUDE.md:211-221`（重要规则部分，行号为改动前的位置）

- [ ] **Step 1: 更新目录结构**

在 `wiki/` 目录结构中添加新文件：

```markdown
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
```

- [ ] **Step 2: 更新重要规则**

将当前的 `## 重要规则` 部分替换为：

```markdown
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
```

- [ ] **Step 3: 添加 .status.json 格式说明**

在 `## 日志格式` 之后、`## 搜索工具：qmd` 之前，新增章节：

```markdown
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
```

- [ ] **Step 4: 验证整体 CLAUDE.md 完整性**

读取完整的 CLAUDE.md，确认：
1. 目录结构包含 `.status.json` 和 `.lint-results.md`
2. Ingest 流程引用了 `.status.json`
3. Query 流程引用了 qmd 和摘要
4. Lint 流程引用了结构化格式和 `.lint-results.md`
5. 重要规则包含所有新增条目
6. `.status.json` 格式说明在日志格式之后
7. 没有重复章节或断裂的 Markdown 结构

- [ ] **Step 5: 提交**

```bash
git add CLAUDE.md
git commit -m "docs(schema): 更新目录结构、重要规则和 status.json 说明"
```

---

### Task 6: 创建 wiki/.status.json 初始文件

**Files:**
- Create: `wiki/.status.json`

- [ ] **Step 1: 创建文件**

```json
{
  "version": 1,
  "processed": {}
}
```

- [ ] **Step 2: 提交**

```bash
git add wiki/.status.json
git commit -m "chore(wiki): 创建处理状态追踪文件"
```

---

### Task 7: 创建 wiki/.lint-results.md 初始文件

**Files:**
- Create: `wiki/.lint-results.md`

- [ ] **Step 1: 创建文件**

```markdown
# Lint 结果

> 本文件存储最近一次 Lint 检查的结构化结果。每次 Lint 后整体替换内容。

最近检查：尚未执行
```

- [ ] **Step 2: 提交**

```bash
git add wiki/.lint-results.md
git commit -m "chore(wiki): 创建 Lint 结果存储文件"
```

---

### Task 8: 最终验证

- [ ] **Step 1: 读取完整 CLAUDE.md，验证所有改动一致性**

检查清单：
- [ ] 摘要约定：4 种页面模板都包含摘要行 ✓
- [ ] 两步入库：阶段一提取、阶段二整合，步骤 1-8 ✓
- [ ] Query 流程：6 步 + 回退策略 ✓
- [ ] qmd 集成：阈值 20 页面，优先 MCP ✓
- [ ] Lint 结构化：7 种检查类型，`---LINT---` 格式 ✓
- [ ] .status.json：格式说明 + hash 追踪 ✓
- [ ] 目录结构：包含新文件 ✓
- [ ] 重要规则：10 条规则完整 ✓

- [ ] **Step 2: 验证新文件存在**

```bash
ls -la wiki/.status.json wiki/.lint-results.md
```

预期：两个文件都存在且内容正确。

- [ ] **Step 3: 验证 git log 中的提交历史**

```bash
git log --oneline -6
```

预期：看到 5-6 个新提交，每个对应一个 Task 的改动。
