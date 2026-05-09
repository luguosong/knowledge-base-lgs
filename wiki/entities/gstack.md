---
title: gstack
type: project
tags: [AI编程, Claude Code, 工作流, 开源项目]
sources: [[sources/gstack工作流]]
---

gstack 是 Y Combinator President & CEO Garry Tan 开发的开源 Claude Code 工作流框架，MIT 许可证，GitHub 仓库 garrytan/gstack。它通过 23 个专家角色和 8 个工具，将编码 Agent 变成虚拟工程团队，支持 10+ 种 AI 编码 Agent。

## 概述

gstack 的核心理念是将软件开发流程结构化为 Sprint：Think → Plan → Build → Review → Test → Ship。每个 Skill 的输出是下一个 Skill 的输入，形成闭环。支持 10-15 个并行 Sprint，配合 Conductor 可同时管理多个隔离的 Agent 会话。

## 关键信息

- **作者**：Garry Tan（[@garrytan](https://x.com/garrytan)）
- **身份**：Y Combinator President & CEO，Palantir 早期工程师，Posterous 联合创始人
- **仓库**：[github.com/garrytan/gstack](https://github.com/garrytan/gstack)
- **许可证**：MIT License
- **支持平台**：Claude Code、Codex CLI/App、OpenCode、Cursor、Factory Droid、Gemini CLI、Slate、Kiro、Hermes、GBrain
- **核心组件**：23 个斜杠命令 Skill + 8 个强力工具 + GBrain 持久记忆 + GStack Browser

## 设计哲学

- **Builder 精神**：Boil the Lake、Search Before Building、知识三层
- **流程优于猜测**：系统化 Sprint 流程替代临时应对
- **真实浏览器**：Agent 有眼睛（/browse），能发现和修复真实 Bug
- **品味记忆**：/design-shotgun 学习用户的设计偏好，跨迭代优化
- **测试一切**：/ship 自动引导测试框架，100% 覆盖率是目标

## 与 Superpowers 的对比

| 维度 | gstack | Superpowers |
|------|--------|-------------|
| 核心理念 | 虚拟工程团队（角色扮演） | 系统化方法论（TDD/调试） |
| Skill 数量 | 23+ 角色 + 8 工具 | ~14 个技能 |
| 特色能力 | 真实浏览器、设计探索、QA 自动修复 | brainstorming、subagent 驱动 |
| 开发者 | Garry Tan（YC CEO） | Jesse Vincent（Prime Radiant） |
| 适用场景 | 完整产品 Sprint | 编码任务自动化 |

## 相关实体与概念

- [[entities/Superpowers]]：同领域的编码 Agent 技能框架，理念互补
- [[entities/Anthropic]]：Claude Code 是 gstack 的主要运行平台
- [[concepts/AI编程助手]]：gstack 是 AI 编程助手的高级工作流封装
- [[concepts/Agentic Loop]]：gstack 的 Skill 在 Agent 循环中自动触发
