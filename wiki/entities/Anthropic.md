---
title: Anthropic
type: organization
tags: [AI公司, Claude, 安全]
sources: [[sources/AI编程工具研究]]
---

## 概述

Anthropic 是一家专注于 AI 安全的美国科技公司，由 Dario Amodei 和 Daniela Amodei 等人于 2021 年创立。公司以 "AI 安全" 为核心使命，开发了 Claude 系列大语言模型和相关产品。Anthropic 在 AI 编程工具领域具有重要影响力，推出了 Claude Code 终端助手和 Agent SDK，同时也是 [[MCP协议]] 的发起者。

## 关键信息

### 核心人物

- **Dario Amodei**：CEO，前 OpenAI 研究副总裁
- **Daniela Amodei**：President，前 OpenAI 运营副总裁

### 产品矩阵

| 产品 | 类型 | 描述 |
|------|------|------|
| Claude 模型 | LLM | 包括 Opus、Sonnet、Haiku 三个等级，覆盖不同性能和成本需求 |
| Claude Code | [[AI编程助手]] | 终端 AI 编程助手，支持 Skills、Hooks、[[MCP协议]] 扩展 |
| Agent SDK | 开发框架 | Python/TypeScript SDK，用于构建自定义 AI Agent 应用 |
| MCP 协议 | 开放协议 | Model Context Protocol，AI 工具的标准扩展协议 |

### 技术理念

- **Constitutional AI**：通过"宪法"原则引导模型行为，减少有害输出
- **可解释性**：研究模型内部机制，提升 AI 决策的透明度
- **安全优先**：在能力提升和安全性之间优先考虑安全

### 在 AI 编程领域的影响

- 发起并推动了 [[MCP协议]]，成为 AI 工具扩展的事实标准
- Claude Code 是终端 [[AI编程助手]] 的代表性产品
- Agent SDK 让开发者能在代码中复用 [[Agentic Loop]] 能力

## 相关实体与概念

- [[GitHub]]：竞合关系，Copilot CLI 是 Claude Code 的主要竞争产品，但两者都支持 MCP
- [[智谱AI]]：同为 AI 公司，智谱提供了基于 MCP 的服务器
- [[AI编程助手]]：Anthropic 通过 Claude Code 参与该领域
- [[MCP协议]]：Anthropic 发起的开放协议
- [[Agentic Loop]]：Claude Code 和 Agent SDK 的核心执行模式
