---
title: gstack：Garry Tan 的 Claude Code 工作流
date: 2026-05-09
type: article
source_url: https://github.com/garrytan/gstack
tags: [AI编程, Claude Code, 工作流, 技能框架, Agent, 开发方法论]
related_entities: [[entities/gstack]], [[entities/Superpowers]]
related_concepts: [[concepts/AI编程助手]], [[concepts/Agentic Loop]]
---

gstack 是 Y Combinator CEO Garry Tan 开发的 Claude Code 完整工作流框架，包含 23 个专业化斜杠命令角色和 8 个强力工具，将 Claude Code 变成虚拟工程团队。核心流程为 Think → Plan → Build → Review → Test → Ship，支持 10-15 个并行 Sprint，配合 Conductor 可同时运行多个隔离的 Claude Code 会话。

## 核心要点

- **虚拟工程团队**：23 个专家角色（CEO、设计师、工程经理、QA Lead、安全官、发布工程师等），全部是斜杠命令，全部 Markdown 驱动
- **Sprint 流程**：每个 Skill 的输出是下一个 Skill 的输入，形成完整的开发流水线（/office-hours → /plan-ceo-review → /plan-eng-review → /review → /qa → /ship）
- **真实浏览器能力**：/browse 和 /open-gstack-browser 提供真实 Chromium 浏览器，带反爬虫隐身、侧边栏 Agent、Prompt 注入防御（ML 分类器 + Claude Haiku 双层检测）
- **设计探索管道**：/design-shotgun（AI Mockup 变体生成 + 品味记忆）→ /design-html（Pretext 计算布局，生产级 HTML）
- **跨 Agent 协调**：/pair-agent 让不同厂商的 AI Agent 共享浏览器，/codex 从 OpenAI Codex 获取独立代码审查
- **GBrain 持久记忆**：Agent 跨会话保留知识，支持 PGLite 本地 / Supabase 云端两种部署
- **多 Agent 支持**：不仅限于 Claude Code，还支持 Codex CLI、OpenCode、Cursor、Factory Droid 等 10 种编码 Agent
- **生产力数据**：Garry Tan 报告 2026 年日均逻辑代码变更约 11,417 行，是 2013 年的约 810 倍

## 关键 Skill 速查

| Skill | 角色 | 职责 |
|-------|------|------|
| /office-hours | YC Office Hours | 六个追问式问题，重新审视产品，反驳框架 |
| /plan-ceo-review | CEO/创始人 | 重新思考问题，四种范围模式（扩展/选择性扩展/保持/缩减） |
| /plan-eng-review | 工程经理 | 锁定架构、数据流、边界情况、测试 |
| /review | Staff Engineer | 发现能过 CI 但生产环境会爆炸的 Bug |
| /qa | QA Lead | 真实浏览器测试，发现并修复 Bug，自动生成回归测试 |
| /cso | 首席安全官 | OWASP Top 10 + STRIDE 威胁模型 |
| /ship | 发布工程师 | 同步 main、测试、审计覆盖率、推送、创建 PR |
| /design-shotgun | 设计探索者 | 生成 4-6 个 AI Mockup 变体，品味记忆学习偏好 |
| /design-html | 设计工程师 | Mockup 转生产级 HTML，Pretext 计算布局 |
| /autoplan | Review Pipeline | 一条命令运行 CEO → 设计 → 工程审查 |
| /learn | 记忆 | 跨会话积累项目特定模式和偏好 |

## 安全特性

- **Prompt 注入防御**：22MB ML 分类器本地扫描 + Claude Haiku 转录检查 + 随机 Canary Token，三重防护
- **安全护栏**：/careful（破坏性命令警告）、/freeze（目录锁定）、/guard（两者合一）
- **浏览器交接**：遇到 CAPTCHA/MFA 时 $B handoff 交由人类处理

## 与现有知识的关联

- 与 [[entities/Superpowers]] 的关系：两者都是编码 Agent 技能框架，gstack 更侧重完整开发流程和团队角色模拟，Superpowers 更侧重系统化方法论（TDD、调试）
- 与 [[concepts/AI编程助手]] 的关系：gstack 是 AI 编程助手的高级工作流封装，将单次交互升级为结构化 Sprint
- 与 [[concepts/Agentic Loop]] 的关系：gstack 的 Skill 在 Agent 循环中自动触发和衔接
