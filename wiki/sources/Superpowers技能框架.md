---
title: Superpowers 技能框架
date: 2026-05-09
type: article
source_url: https://github.com/obra/superpowers
tags: [AI编程, Agent, 技能框架, TDD, subagent]
related_entities: [[entities/Superpowers]]
related_concepts: [[concepts/AI编程助手]]
---

Superpowers 是一套面向编码 Agent 的可组合技能框架，由 Jesse Vincent 开发。它通过苏格拉底式设计打磨、子 Agent 驱动开发、强制 TDD 等工作流，让编码 Agent 自主工作数小时不跑偏。支持 Claude Code、Codex CLI、Gemini CLI、Cursor 等多种编码 Agent。

## 核心要点

- **设计先行**：Agent 不会立刻写代码，而是通过 brainstorming 技能用苏格拉底式提问打磨需求，分段展示设计方案供用户验证
- **子 Agent 驱动开发**：将工作拆分为 2-5 分钟的小任务，为每个任务分派独立子 Agent，执行两阶段审查（规格符合度 + 代码质量）
- **强制 TDD**：RED-GREEN-REFACTOR 循环，会删除先于测试编写的代码
- **多 Agent 支持**：Claude Code、Codex CLI/App、Factory Droid、Gemini CLI、OpenCode、Cursor、GitHub Copilot CLI
- **自动化工作流**：brainstorming → worktree 隔离 → 编写计划 → subagent 开发 → TDD → code review → 完成 branch
- **设计哲学**：测试驱动开发、系统化优于临时应对、降低复杂度、证据优于断言

## 工作流详解

### brainstorming（头脑风暴）
在写代码前激活。通过提问打磨粗略想法，探索替代方案，分段展示设计以供验证。

### using-git-worktrees
在设计确认后激活。在新分支上创建隔离工作区，运行项目设置，验证干净的测试基线。

### writing-plans（编写计划）
将工作拆分为小任务（每个 2-5 分钟），每个任务包含精确的文件路径、完整代码和验证步骤。

### subagent-driven-development
为每个任务分派独立的子 Agent，执行两阶段审查：先检查是否符合规格，再检查代码质量。或使用 executing-plans 分批执行并在关键节点暂停。

### test-driven-development
强制执行 RED-GREEN-REFACTOR 循环：写失败测试 → 看着它失败 → 写最少的代码 → 看着它通过 → 提交。

### requesting-code-review
在任务之间激活。对照计划审查，按严重程度报告问题。Critical 级别阻塞进度。

### finishing-a-development-branch
验证测试，提供选项（merge/PR/保留/丢弃），清理 worktree。

## 安装方式

不同编码 Agent 安装方式各异：
- **Claude Code**：`/plugin install superpowers@claude-plugins-official`
- **Codex CLI/App**：插件市场搜索安装
- **Gemini CLI**：`gemini extensions install https://github.com/obra/superpowers`
- **Cursor**：`/add-plugin superpowers`

## 与现有知识的关联

- 与 [[concepts/AI编程助手]] 的关系：Superpowers 是编码 Agent 的技能层，增强了 [[concepts/Agentic Loop]] 的执行质量
- 与 [[entities/Superpowers]] 的关系：该实体页记录项目本身的元信息
