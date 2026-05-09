---
title: Superpowers
type: project
tags: [AI编程, Agent, 开源项目]
sources: [[sources/Superpowers技能框架]]
---

Superpowers 是由 Jesse Vincent（Prime Radiant 公司）开发的开源编码 Agent 技能框架，旨在为多种 AI 编程助手提供可组合的工作流技能。MIT 许可证，GitHub 仓库 obra/superpowers。

## 概述

Superpowers 通过一组可自动触发的技能（skill），为编码 Agent 注入系统化的软件开发方法论。核心功能包括苏格拉底式设计打磨、子 Agent 驱动开发、强制测试驱动开发（TDD）和代码审查。

## 关键信息

- **作者**：Jesse Vincent（[blog.fsck.com](https://blog.fsck.com/)）
- **公司**：Prime Radiant（[primeradiant.com](https://primeradiant.com/)）
- **仓库**：[github.com/obra/superpowers](https://github.com/obra/superpowers)
- **许可证**：MIT License
- **支持平台**：Claude Code、Codex CLI、Codex App、Factory Droid、Gemini CLI、OpenCode、Cursor、GitHub Copilot CLI
- **发布时间**：2025 年 10 月（[原始发布公告](https://blog.fsck.com/2025/10/09/superpowers/)）

## 技能库

| 类别 | 技能 | 说明 |
|------|------|------|
| 测试 | test-driven-development | RED-GREEN-REFACTOR 循环 |
| 调试 | systematic-debugging | 4 阶段根因分析 |
| 调试 | verification-before-completion | 确保问题真正修复 |
| 协作 | brainstorming | 苏格拉底式设计打磨 |
| 协作 | writing-plans | 详细实施计划 |
| 协作 | executing-plans | 带检查点的分批执行 |
| 协作 | dispatching-parallel-agents | 并发子 Agent 工作流 |
| 协作 | subagent-driven-development | 两阶段审查的快速迭代 |
| 协作 | requesting-code-review | 预审查清单 |
| 协作 | using-git-worktrees | 并行开发分支 |
| 协作 | finishing-a-development-branch | 合并/PR 决策工作流 |
| 元技能 | writing-skills | 创建新 skill |
| 元技能 | using-superpowers | 技能系统入门 |

## 相关实体与概念

- [[concepts/AI编程助手]]：Superpowers 为编码 Agent 提供技能层
- [[concepts/Agentic Loop]]：Superpowers 的技能在 Agent 循环中自动触发
- [[entities/Anthropic]]：Claude Code 是 Superpowers 支持的主要平台之一
- [[entities/GitHub]]：Copilot CLI 是 Superpowers 支持的平台之一
