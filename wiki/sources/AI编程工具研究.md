---
title: AI编程工具研究
date: 2026-05-08
type: note
tags: [AI编程, Agent SDK, Claude Code, Copilot CLI, MCP]
related_entities: [[Anthropic]], [[GitHub]], [[智谱AI]]
related_concepts: [[Agentic Loop]], [[MCP协议]], [[AI编程助手]]
---

系统梳理了当前 AI 编程工具领域的四大代表性产品：Agent SDK、Claude Code、Copilot CLI 和实用 MCP 服务器。核心发现是所有工具都基于 Agentic Loop（思考-行动-观察循环）模式运作，MCP 协议已成为 AI 工具扩展的事实标准。资料涵盖架构原理、核心特性、扩展机制及三大厂商（Anthropic、GitHub、智谱 AI）的技术方案对比。

## 核心要点

- AI 编程工具的核心是 **Agentic Loop**（代理循环）模式：思考 → 行动 → 观察 → 再思考，循环往复直到任务完成
- **MCP 协议**已成为 AI 工具扩展的事实标准，Claude Code 和 Copilot CLI 均原生支持
- Claude Code 和 Copilot CLI 都具备 Skills（技能）、Hooks（钩子）、子代理（Sub-agent）扩展能力
- **Agent SDK** 让开发者能在代码中构建与 Claude Code 相同的 Agent 能力，实现自定义 AI 应用

## 详细摘要

### Agent SDK（12 个文件）

Anthropic 官方提供的 Python/TypeScript SDK，用于构建自定义 AI 应用。核心能力：

- **多语言支持**：同时提供 Python 和 TypeScript SDK
- **Agent 构建**：封装了完整的 [[Agentic Loop]] 循环，支持工具调用、上下文管理
- **与 Claude Code 同源**：底层能力和 Claude Code 一致，但可编程定制
- **Tool Use**：支持注册自定义工具，扩展 Agent 的行动范围

### Claude Code（35 个文件）

Anthropic 推出的终端 AI 编程助手，直接在命令行中运行。核心特性：

- **终端原生**：在终端环境中理解项目代码，直接执行编辑、搜索、运行等操作
- **Skills 系统**：用户可定义可复用的技能模块，封装常见工作流
- **Hooks 机制**：支持在工具执行前后插入自定义逻辑（PreToolUse / PostToolUse）
- **MCP 扩展**：通过 [[MCP协议]] 连接外部工具和数据源
- **子代理**：支持并行派发多个子代理处理独立任务
- **上下文管理**：自动压缩过长对话，维护有效上下文窗口

### GitHub Copilot CLI（26 个文件）

GitHub 推出的终端 AI 助手，具备工程代理能力。核心特性：

- **工程代理**：不仅能回答问题，还能自主执行多步骤工程任务
- **MCP 扩展**：支持通过 [[MCP协议]] 连接自定义服务器
- **GitHub 生态集成**：与 GitHub Issues、PR、Actions 等深度集成
- **终端操作**：在命令行中直接辅助开发操作

### 实用 MCP 介绍（1 个文件）

智谱 AI 提供的 4 个 MCP 服务器，展示 [[MCP协议]] 的实际应用：

- **视觉理解服务器**：图片分析能力
- **联网搜索服务器**：实时网络信息检索
- **网页读取服务器**：抓取和解析网页内容
- **仓库检索服务器**：GitHub 仓库代码搜索

## 与现有知识的关联

- 与 [[Agentic Loop]] 的关系：所有工具都基于代理循环模式运作，这是 AI 编程工具的核心范式
- 与 [[MCP协议]] 的关系：MCP 是工具扩展的标准协议，Claude Code 和 Copilot CLI 均采用
- 与 [[AI编程助手]] 的关系：这四个工具是当前 AI 编程助手领域的代表性产品
- 与 [[Anthropic]] 的关系：Agent SDK 和 Claude Code 均为 Anthropic 开发
- 与 [[GitHub]] 的关系：Copilot CLI 为 GitHub 开发
- 与 [[智谱AI]] 的关系：MCP 服务器由智谱 AI 提供
