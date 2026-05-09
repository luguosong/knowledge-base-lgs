---
title: MCP协议
tags: [MCP, AI工具, 协议, 扩展]
sources: [[sources/AI编程工具研究]]
---

MCP（Model Context Protocol）是由 Anthropic 发起的 AI 工具标准扩展协议，为 AI 模型提供统一的工具注册、资源管理和数据接入接口。协议定义了 Tools、Resources、Prompts 三种核心能力，支持 stdio 和 HTTP/SSE 两种传输方式，并通过 Sampling 机制允许服务器反向请求 AI 推理能力。

## 定义

Model Context Protocol（MCP），AI 工具的标准扩展协议。由 [[Anthropic]] 发起，旨在为 AI 模型提供统一的工具注册、资源管理和数据接入标准。类似于 USB 协议为硬件设备提供了统一接口，MCP 为 AI 工具提供了统一的外部连接方式。

## 关键要点

### 传输方式

MCP 支持两种传输方式：

- **stdio**：通过标准输入输出通信，适合本地进程间交互。AI 工具作为客户端启动 MCP 服务器子进程，通过 stdin/stdout 交换 JSON-RPC 消息
- **HTTP/SSE**：通过 HTTP 协议通信，支持远程服务。使用 Server-Sent Events 实现服务器推送

### 核心能力

MCP 协议定义了三种核心能力：

- **Tools（工具）**：AI 可调用的函数，如文件操作、数据库查询、API 调用。每个工具定义名称、描述、参数 schema
- **Resources（资源）**：AI 可读取的数据源，如文件内容、数据库记录、API 响应。提供结构化的上下文信息
- **Prompts（提示）**：预定义的提示模板，帮助用户快速发起常见任务

### 工具注册流程

1. MCP 服务器启动，声明支持的 capabilities
2. 客户端（如 [[AI编程助手]]）发送 `tools/list` 请求
3. 服务器返回可用工具列表及参数定义
4. AI 在执行过程中根据需要调用工具，客户端转发请求到服务器
5. 服务器执行操作并返回结果

### 采样机制（Sampling）

MCP 还提供了采样（Sampling）机制，允许 MCP 服务器向客户端请求 AI 推理能力：

- 服务器可以请求客户端进行 LLM 推理
- 客户端可以审批或拒绝采样请求
- 支持多轮对话式的采样交互
- 适用于需要 AI 判断的复杂工具链

### 实际应用

基于 MCP 的服务器已在多个领域实现：

- **开发工具**：文件系统、数据库、Git 操作
- **知识检索**：网页抓取、搜索引擎、文档查询
- **视觉能力**：图片分析、OCR、图表理解
- **通信集成**：Slack、邮件、通知服务

## 与其他概念的关系

- [[AI编程助手]]：MCP 是 AI 编程助手的核心扩展机制，Claude Code 和 Copilot CLI 均原生支持
- [[Anthropic]]：MCP 协议的发起者和主要推动者
- [[智谱AI]]：提供了基于 MCP 的实用服务器（视觉理解、联网搜索等）
