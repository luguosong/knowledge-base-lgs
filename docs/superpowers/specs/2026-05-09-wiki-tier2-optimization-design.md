# Wiki Skill Tier 2 优化设计

> 日期：2026-05-09
> 状态：已批准
> 影响范围：wiki-ingest、wiki-query、wiki-lint

## 优化 3：两步摄入

### 问题

ingest 步骤 3（提取）和步骤 4（写入）一次完成，LLM 边读边写，容易遗漏关联和矛盾。

### 方案

拆分为两个显式阶段：

**Phase A - Analysis（分析）**：
- 输入：raw 文件内容 + 步骤 2 搜索到的已有 wiki 内容
- 输出：结构化分析清单
  - 实体列表（名称、类型、描述）
  - 概念列表（名称、定义）
  - 与已有知识的关联（哪些页面需要更新）
  - 发现的矛盾或歧义（→ 生成 review 条目）
  - 建议的 wiki 结构变更

**Phase B - Generation（生成）**：
- 输入：Phase A 的分析清单
- 输出：wiki 页面文件

改动集中在 wiki-ingest SKILL.md 的步骤 3-4 重写。

## 优化 4：异步 Review 队列

### 问题

ingest 发现矛盾/歧义时没有标准化标记机制。

### 方案

**存储**：`wiki/.review-queue.md`（Markdown 格式，与 wiki 风格一致）

**条目格式**：
```markdown
### R{N}: {简短标题}
- **类型**：contradiction | ambiguity | categorization
- **来源**：[[sources/对应来源页]]
- **内容**：具体描述
- **建议操作**：创建/合并/跳过 + 具体建议
- **预生成搜索**：`qmd-node search "..."`
- **状态**：pending
```

**流程**：
- wiki-ingest：Phase A（分析）发现矛盾/歧义时，追加到 .review-queue.md
- wiki-lint：新增步骤，读取 pending review 条目，作为检查线索之一

## 优化 5：Query 图扩展 + 预算控制

### 问题

query 固定读 top 3 页面，不利用 wikilink 结构，无 token 预算管理。

### 方案

**图扩展**：搜索得到候选页面后，提取 `[[wikilinks]]`，做 2-hop 扩展发现间接关联页面。

**预算控制**：

| 分配 | 比例 | 内容 |
|------|------|------|
| wiki 页面 | 60% | 深入阅读的页面全文 |
| 图扩展 | 15% | 2-hop 页面的摘要段落 |
| 全局上下文 | 10% | overview.md + index.md |
| 系统提示 | 15% | CLAUDE.md 规则 |

改动集中在 wiki-query SKILL.md 步骤 2-4 重写。

## 改动清单

| 文件 | 改动 |
|------|------|
| `.claude/skills/wiki-ingest/SKILL.md` | 步骤 3-4 拆分为两步；新增 review 生成 |
| `.claude/skills/wiki-query/SKILL.md` | 步骤 2-4 重写（图扩展+预算控制） |
| `.claude/skills/wiki-lint/SKILL.md` | 新增 review 条目处理步骤 |
| `wiki/.review-queue.md` | 首次创建（空模板） |
