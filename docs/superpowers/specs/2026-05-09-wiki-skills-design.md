# LLM Wiki Skills 封装设计

## 背景

LLM Wiki 的三个核心操作（Ingest、Query、Lint）目前全部定义在 CLAUDE.md 中，总计约 200 行规则文本。存在的问题：

- 每次对话都要加载全部规则，即使只做简单查询
- 操作入口不明确，依赖 Claude 自行判断用户意图
- 规则执行质量不稳定，复杂流程容易遗漏步骤

## 目标

1. 将三个操作封装为独立的 Claude Code skill，通过 `/ingest`、`/query`、`/lint` 斜杠命令触发
2. 精简 CLAUDE.md，减少 context 占用
3. 标准化执行流程，提高操作质量

## 方案：纯 Skill 封装

三个独立 skill，CLAUDE.md 保留基础架构定义，详细操作流程迁入各 skill。

```
.claude/skills/
├── wiki-ingest/SKILL.md   # /ingest 触发
├── wiki-query/SKILL.md    # /query 触发
└── wiki-lint/SKILL.md     # /lint 触发
```

共享知识（页面格式、目录结构、重要规则）保留在 CLAUDE.md 中，各 skill 通过 CLAUDE.md 获取。

## CLAUDE.md 重构

### 保留内容（约 120-150 行）

1. 三层架构概述
2. 目录结构
3. 核心操作索引——简要指向三个 skill
4. 页面格式约定（所有 skill 共享）
5. 索引/日志格式
6. status.json 格式
7. qmd 搜索工具说明
8. 重要规则

### 迁出内容

- Ingest 的两阶段 8 步详细流程 → `wiki-ingest/SKILL.md`
- Query 的 6 步流程和搜索回退策略 → `wiki-query/SKILL.md`
- Lint 的检查项和执行流程 → `wiki-lint/SKILL.md`

## Skill 详细规格

### wiki-ingest

**触发词**：摄入、ingest、添加资料、新资料、导入、摄入资料

**SKILL.md 内容**：

- **边界说明**：做且只做摄入新资料，不处理查询和 lint
- **阶段一：提取**（4 步）：
  1. 检查处理状态（SHA-256 hash 对比）
  2. 保存原始文件到 raw/ 对应子目录
  3. 阅读资料并与用户讨论关键要点
  4. 提取结构化数据（来源摘要、实体列表、概念列表、待更新页面）
- **阶段二：整合**（4 步）：
  5. 批量写入文件（来源摘要页、实体页面、概念页面）
  6. 更新索引（index.md）和日志（log.md）
  7. 更新元数据（.status.json 中的 hash）
  8. 更新搜索索引（`qmd-node update && qmd-node embed`）
- **页面格式参考**：简要列出各页面类型的必需字段
- **质量检查清单**：ingest 完成后的自检项

### wiki-query

**触发词**：查询、query、搜索、查找（当问题明显与知识库内容相关时）

**SKILL.md 内容**：

- **边界说明**：基于 Wiki 内容回答问题，不涉及摄入和检查
- **搜索流程**（6 步）：
  1. qmd 混合搜索获取匹配页面
  2. 读取每个匹配页面的摘要段落
  3. 聚合排序（同页面多段落命中 > 概念页 > 来源页）
  4. 深入阅读 top 3 页面全文
  5. 综合回答，附 `[[wikilink]]` 引用
  6. 回填洞察到 `wiki/synthesis/`（如适用）
- **搜索回退策略**：qmd → index.md → 提示用户补充
- **回填规则**：何时生成 synthesis 页面，以及需要同步更新 index.md 和 log.md

### wiki-lint

**触发词**：lint、检查、wiki 检查、健康检查

**SKILL.md 内容**：

- **边界说明**：检查 Wiki 健康，不修改 raw/ 目录，不自动修复问题
- **7 项检查**：
  | 类型 | 严重度 | 说明 |
  |------|--------|------|
  | contradiction | warning | 页面间矛盾 |
  | stale | warning | 信息过时 |
  | orphan | info | 孤立页面 |
  | broken-link | warning | 失效 wikilink |
  | missing-page | info | 缺少独立页面的概念 |
  | missing-summary | warning | 缺少摘要段落 |
  | suggestion | info | 建议补充方向 |
- **执行流程**（6 步）：
  1. 对比 page_hashes 确定变化页面
  2. 优先检查有变化的页面
  3. 扫描所有页面执行结构化检查
  4. 写入 `.lint-results.md`
  5. 追加 `log.md`
  6. 更新 `.status.json` 的 `last_lint_at`
- **输出格式**：`---LINT: 类型 | 严重度 | 标题---` 结构化格式

## 跨 Skill 协调

- **Query → Ingest**：如果回答产生新洞察，按照 ingest 的页面格式创建 synthesis 页面，并更新 index.md 和 log.md。不需要调用 `/ingest` skill，直接执行写入。
- **Lint → 用户**：发现问题记录到 `.lint-results.md`，不自动修复，提示用户确认后修复。
- **三个 skill 共享**：页面格式约定、重要规则、status.json 格式——全部定义在 CLAUDE.md 中，skill 不重复定义。

## 实施步骤

1. 创建 `wiki-ingest/SKILL.md`——从 CLAUDE.md 迁入 Ingest 详细流程
2. 创建 `wiki-query/SKILL.md`——从 CLAUDE.md 迁入 Query 详细流程
3. 创建 `wiki-lint/SKILL.md`——从 CLAUDE.md 迁入 Lint 详细流程
4. 重构 CLAUDE.md——删除详细流程，添加 skill 索引
5. 测试验证——依次触发三个 skill 确认正常工作
