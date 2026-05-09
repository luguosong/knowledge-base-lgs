# Wiki Skill Tier 1 优化设计

> 日期：2026-05-09
> 状态：已批准
> 影响范围：wiki-ingest、wiki-query

## 背景

参考 nashsu/llm_wiki 项目的实现，识别出当前 3 个 wiki skill 的优化空间。本设计覆盖 Tier 1（高价值 + 低改动量）的两项优化。

## 优化 1：overview.md 自动生成

### 问题

query 时 LLM 只读 `index.md`（条目列表），缺乏知识库全局概览，难以快速判断查询方向。

### 方案

每次 ingest 完成后，自动生成/更新 `wiki/overview.md`。

**内容结构**：
- frontmatter（title、last_updated、page_count、source_count）
- 150-200 字摘要段落，描述知识库整体覆盖范围和核心领域
- 知识领域分布表（领域 / 页面数 / 核心主题）
- 最近变更记录（从 log.md 末尾提取）

**数据来源**：只读 `index.md` + `log.md` 末尾，不读全部 wiki 页面。

**ingest 流程变更**：在步骤 5（更新索引和日志）之后、步骤 6（更新元数据）之前，新增"步骤 5.5：更新概览页"。

**query 流程变更**：步骤 2（精准读取摘要片段）增加优先读取 `overview.md` 前 30 行作为全局上下文。

## 优化 2：来源可追溯性强化

### 问题

部分 entity/concept 页面的 frontmatter 缺少 `sources:` 字段，无法追溯到原始 raw 文件。

### 方案

在 wiki-ingest 步骤 4（写入 Wiki 页面）中增加强制自检：

> 写入每个 wiki 页面后，验证 frontmatter 中 `sources:` 字段非空。如果缺失，自动填充当前摄入的 source 摘要页 wikilink。

这是执行层面的强化，不改变页面格式模板（CLAUDE.md 中已定义）。

## 改动清单

| 文件 | 改动 |
|------|------|
| `.claude/skills/wiki-ingest/SKILL.md` | 新增步骤 5.5（overview.md 生成）；步骤 4 增加来源追溯自检；质量检查清单新增 overview.md 检查项 |
| `.claude/skills/wiki-query/SKILL.md` | 步骤 2 增加 overview.md 作为首选全局上下文 |
| `wiki/overview.md` | 首次生成 |

## 不做的事

- 不改 CLAUDE.md 中的页面格式模板（已足够）
- 不新增 skill（ingest/query/lint 三分法保持不变）
- 不引入 graph 扩展或向量搜索（Tier 2/3 范畴）
