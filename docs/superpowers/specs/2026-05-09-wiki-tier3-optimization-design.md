# Wiki Skill Tier 3 优化设计

> 日期：2026-05-09
> 状态：已批准
> 影响范围：wiki-ingest（改动）、wiki-delete（新增）、wiki-research（新增）

## 优化 7：持久化摄入队列

### 问题

ingest 中断后，.status.json 与实际文件状态可能不一致。

### 方案

在 .status.json 中引入 `pending` 状态：

- 开始处理文件前：写入 `status: "pending"` + `started_at` 时间戳
- 处理完成后：更新为完整记录（当前格式，无 status 字段表示已完成）
- 下次 ingest 启动时：扫描 pending 条目
  - 有 pending 条目 → 提示用户选择：重试（删除已创建的不完整页面后重新处理）或跳过（标记为已完成）

改动：wiki-ingest 的启动流程增加 pending 恢复步骤，处理流程增加 pending 写入步骤。

## 优化 6：级联删除（新增 wiki-delete skill）

### 问题

没有删除机制，摄入错误资料后无法清理。

### 方案

新增 skill，触发词：删除、delete、移除、remove、清理。

流程：
1. 确认删除目标（raw 文件路径）
2. 从 .status.json 找到对应的 source 摘要页和创建的 wiki 页面
3. 3-method 匹配找到所有关联页面：
   - frontmatter `sources: []` 引用
   - source 摘要页名匹配
   - `[[wikilinks]]` 引用
4. 从关联页面的 sources 中移除被删除来源
5. sources 为空的页面一并删除
6. 清理 index.md 条目
7. 清理剩余页面的死 wikilinks
8. 更新 .status.json（移除条目）
9. 追加 log.md

边界：不自动删除 raw/ 文件（用户管理），只删除 wiki/ 下的内容和元数据。需要用户确认后才执行。

## 优化 8：Deep Research（新增 wiki-research skill）

### 问题

知识库内容不足时只能建议用户手动补充。

### 方案

新增 skill，触发词：研究、research、深入调查、搜索资料。

流程：
1. 用户描述研究主题（或从 query 知识缺口 / lint 孤立页面触发）
2. 读取 overview.md 获取领域上下文
3. LLM 生成 2-3 个优化的搜索查询
4. 使用 WebSearch 工具搜索
5. 抓取 top 结果内容（mcp__web-reader__webReader 或 WebFetch）
6. 保存到 raw/编程学习/ 或对应子目录
7. 自动调用 /ingest 处理搜索结果
8. 汇报研究成果

质量把控：
- 搜索结果去重（与已有 wiki 内容对比）
- 最多处理 5 个搜索结果
- 每个结果保存为独立 .md 文件

## 文件清单

| 文件 | 操作 |
|------|------|
| `.claude/skills/wiki-ingest/SKILL.md` | 改动：启动流程增加 pending 恢复 |
| `.claude/skills/wiki-delete/SKILL.md` | 新增 |
| `.claude/skills/wiki-research/SKILL.md` | 新增 |
