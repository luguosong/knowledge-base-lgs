# LLM Wiki 架构优化设计

> 基于 nashsu/llm_wiki 参考项目的分析，优化当前 LLM Wiki 的精准度、Token 用量和处理速度。

## 背景

当前项目实现了 Karpathy 的 LLM Wiki 模式，使用 Claude Code CLI + Obsidian + qmd 的技术栈。参考项目 nashsu/llm_wiki 是一个基于 Tauri 的桌面应用，其核心优化理念可以移植到 CLI 环境：

- **分块级向量搜索**（chunk-level embedding）—— 提高检索精准度
- **两步入库管道**（two-step ingest）—— 减少 Token 消耗，提高摄入速度
- **结构化 Lint**（structured lint）—— 稳定可解析的质量检查输出
- **文件 hash 追踪**（file hash tracking）—— 增量式处理，避免重复工作

由于我们是 CLI 环境而非桌面应用，不引入额外的向量数据库或 embedding 服务，而是通过 Schema 层（CLAUDE.md）的约定优化 + qmd 深度集成来实现同等效果。

## 设计概览

五个优化点，全部通过修改 CLAUDE.md 和新增约定文件实现：

| 优化点 | 目标维度 | 改动文件 |
|--------|---------|---------|
| 页面摘要约定 | Token、精准度 | CLAUDE.md、已有页面格式 |
| 两步入库管道 | Token、速度 | CLAUDE.md |
| qmd 深度集成 | 精准度 | CLAUDE.md |
| 增量式缓存 + hash 追踪 | 速度、精准度 | CLAUDE.md、wiki/.status.json |
| 结构化 Lint | 精准度 | CLAUDE.md、wiki/.lint-results.md |

---

## 1. 页面摘要约定（TL;DR）

### 问题

Query 时 LLM 需要读取多个 Wiki 页面的全文来判断相关性，消耗大量 Token。以平均 1500 字/页面、匹配 5 个页面计算，每次 Query 仅定位阶段就消耗约 7500 字的 context。

### 方案

所有 Wiki 页面（来源摘要、实体、概念、综合）的 frontmatter 后、第一个 `##` 之前，必须包含一段 50-100 字的摘要段落，直接以正文形式书写。

### 格式示例

```markdown
---
title: 网络安全
tags: [网络安全, 安全, 黑客]
sources: [[sources/网络安全学习路线]]
---

网络安全是通过技术和管理手段保护系统免受攻击的综合性学科。核心是攻防对抗的认知升级，涵盖 Web 安全、二进制安全、内网渗透等分支。学习路线分六个阶段，从基础筑基到顶级专家专精。

## 定义
...
```

### Query 时使用方式

1. qmd 搜索获取匹配页面列表
2. 只读取每个匹配页面的摘要段落（frontmatter 后到第一个 `##` 之间的内容）
3. 仅对最相关的 1-2 个页面读取全文

### 预期效果

假设匹配 5 个页面：原来 7500 字，现在 500 字摘要 + 1500 字全文 = 2000 字，节省约 73%。

---

## 2. 两步入库管道（Two-Step Ingest）

### 问题

当前 Ingest 是 7 步线性流程，LLM 需要同时理解资料、找到关联页面、更新所有内容，prompt 巨大且容易遗漏跨页面更新。

### 方案

将 Ingest 拆为两阶段。

#### 阶段一：提取（Extract）

1. 保存原始文件到 `raw/`
2. 阅读资料，与用户讨论关键要点
3. 提取结构化数据（不写文件，在对话中确认）：
   - 来源摘要内容（标题、日期、关键要点列表、引用的实体和概念名称）
   - 需要新建的实体列表（名称 + 类型 + 一句话描述）
   - 需要新建的概念列表（名称 + 一句话定义）
   - 需要更新的已有页面列表（页面路径 + 要添加/修改的具体内容）

#### 阶段二：整合（Integrate）

4. 基于阶段一的提取结果，批量写入文件：
   - 创建来源摘要页（带摘要段落）
   - 创建/更新实体页面
   - 创建/更新概念页面
   - 更新 `index.md`
   - 追加 `log.md`
5. 运行 `qmd-node update && qmd-node embed` 更新搜索索引
6. 更新 `wiki/.status.json`

### 对比

| 维度 | 当前流程 | 优化后 |
|------|---------|--------|
| LLM 调用模式 | 一次性大 prompt，边读边写 | 两步小 prompt，先提取后写入 |
| Token 消耗 | 所有关联页面全文加载到 context | 阶段一只处理原始资料；阶段二定向写入 |
| 准确性 | 容易遗漏跨页面更新 | 阶段一明确列出待更新项，阶段二逐项执行 |
| 速度 | 每写一个文件都要重新确认上下文 | 阶段二纯执行，无再思考 |

---

## 3. qmd 深度集成与查询优化

### 问题

当前 Query 流程是"读 index.md → 深入阅读相关页面 → 回答"，index.md 在页面数量增长后检索效率下降，且无法利用段落级匹配。

### 方案

#### 3.1 Query 流程重设计

```
1. qmd 搜索 → 获取匹配页面 + 匹配段落
2. 读取匹配页面的摘要段落
3. 按相关性排序，选取 top 3 页面
4. 仅对 top 3 读取全文
5. 综合回答，附 wikilink 引用
6. 有价值的洞察回填到 wiki/synthesis/
```

#### 3.2 搜索结果聚合策略

- qmd 返回结果后，按页面分组
- 同一页面命中多个段落时，排名提升（加权尾部得分）
- 页面类型亲和性：概念页面 > 来源摘要页面（概念页通常更精炼）
- wikilink 密度：被更多其他页面引用的页面，排名微调提升

#### 3.3 搜索回退策略

1. 先尝试 qmd 混合搜索（默认）
2. 结果不足 3 个页面时，回退到读取 `index.md` 手动定位
3. 仍然不足时，提示用户可能需要 Lint 或补充相关资料

---

## 4. 增量式缓存与文件 Hash 追踪

### 问题

每次 Ingest/Lint 都需要扫描所有文件判断状态，无法区分新文件和已处理文件。

### 方案

#### 4.1 处理状态文件 `wiki/.status.json`

```json
{
  "version": 1,
  "processed": {
    "raw/编程学习/学习路线/从零基础到顶级黑客完整学习路线.md": {
      "ingested_at": "2026-04-30",
      "raw_hash": "a1b2c3d4e5f6...",
      "source_page": "wiki/sources/网络安全学习路线.md",
      "created_pages": [
        "wiki/concepts/网络安全.md",
        "wiki/concepts/渗透测试.md",
        "wiki/concepts/Web安全漏洞.md",
        "wiki/concepts/内网渗透.md"
      ],
      "page_hashes": {
        "wiki/concepts/网络安全.md": "e5f6g7h8i9j0...",
        "wiki/concepts/渗透测试.md": "k1l2m3n4o5p6..."
      },
      "last_lint_at": null
    }
  }
}
```

#### 4.2 Hash 追踪机制

| Hash | 计算时机 | 作用 |
|------|---------|------|
| `raw_hash` | Ingest 完成时 | 检测 `raw/` 文件是否被修改，触发重新摄入 |
| `page_hashes` | Ingest/Lint 完成时 | 检测 Wiki 页面是否被外部修改，触发重新索引或 Lint |

#### 4.3 Hash 对比逻辑

- Hash 算法：`sha256sum`（Git Bash 自带）
- Ingest 前：计算 raw 文件 hash，与 `.status.json` 中的 `raw_hash` 对比
  - 相同 → 跳过，提示"该资料已摄入且未修改"
  - 不同 → 执行两步入库，完成后更新 hash
  - 不存在 → 首次摄入，正常执行
- Lint 前：计算所有 Wiki 页面 hash，与 `page_hashes` 对比
  - 有变化的页面 → 优先检查
  - 全部相同 → 可跳过或仅做轻量检查

---

## 5. 结构化 Lint

### 问题

当前 Lint 输出为自由文本，无法被解析、统计或追踪，容易消失在对话历史中。

### 方案

#### 5.1 结构化输出格式

```
---LINT: 类型 | 严重度 | 简短标题---
问题描述。
PAGES: page1.md, page2.md
---END LINT---
```

类型：
- `contradiction`: 两个或多个页面存在矛盾
- `stale`: 信息过时或被新资料取代
- `orphan`: 没有入链的孤立页面
- `broken-link`: 指向不存在的页面的 wikilink
- `missing-page`: 被频繁引用但缺少独立页面的概念
- `suggestion`: 建议补充的来源或方向
- `missing-summary`: 页面缺少摘要段落

严重度：
- `warning`: 应该修复
- `info`: 建议改进

#### 5.2 Lint 结果存储

Lint 结果写入 `wiki/.lint-results.md`，格式：

```markdown
# Lint 结果

> 最近检查：2026-05-08

## Warning

### [contradiction] 关于 XSS 防御方案的矛盾
concepts/Web安全漏洞.md 和 sources/某文章.md 对 CSP 策略的建议矛盾。
PAGES: concepts/Web安全漏洞.md, sources/某文章.md

## Info

### [missing-summary] 渗透测试页面缺少摘要
concepts/渗透测试.md 缺少 TL;DR 摘要段落。
PAGES: concepts/渗透测试.md
```

#### 5.3 Lint 检查项完整列表

| 检查项 | 类型 | 说明 |
|--------|------|------|
| 矛盾信息 | contradiction | 两个页面存在冲突声明 |
| 过时信息 | stale | 信息被更新资料取代 |
| 孤立页面 | orphan | 没有入链的页面 |
| 断链 | broken-link | 指向不存在页面的 wikilink |
| 缺失页面 | missing-page | 高频引用但无独立页面的概念 |
| 缺失摘要 | missing-summary | 页面没有 TL;DR 摘要段落 |
| 改进建议 | suggestion | 建议补充的来源或方向 |

---

## 变更范围

| 文件 | 操作 | 内容 |
|------|------|------|
| `CLAUDE.md` | 修改 | 页面格式约定（+摘要）、Ingest 两步流程、Query 新流程、Lint 结构化格式、.status.json 说明 |
| `wiki/.status.json` | 新建 | 处理状态文件（含 hash 追踪） |
| `wiki/.lint-results.md` | 新建 | Lint 结果存储 |

不涉及：`raw/` 目录（不可变）、已有 Wiki 页面内容（自然演进，不批量重写）、qmd 配置（已有）。

## 预期效果

| 维度 | 改善机制 | 预估提升 |
|------|---------|---------|
| Token 用量 | Query 只读摘要；Ingest 分步聚焦 | Query 减少约 70%，Ingest 减少约 30% |
| 精准度 | qmd 混合搜索 + 聚合排序 + 类型亲和性 | 多段落匹配页面排名更高，减少无关结果 |
| 速度 | Ingest 阶段二纯执行；hash 避免重复处理 | Ingest 速度提升约 40%，零重复处理 |
