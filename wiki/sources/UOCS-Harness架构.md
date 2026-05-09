---
title: UOCS Harness 架构
date: 2026-05-09
type: note
tags: [AI, Spring, 架构设计, Harness Engineering]
related_entities: [[Spring Framework]]
related_concepts: [[AI编程助手]]
sources: [[sources/UOCS-Harness架构]]
---

UOCS 项目基于 Harness Engineering 模式，以 Spring Boot 3.5.7 + Spring AI 1.1.2 为基础，构建了完整的 AI Agent 架构。核心包括 4 角色多模型架构、三层记忆系统（Session/Project/DrawingMemory）、五层上下文压缩管线、47 个工具（11 模块）、视觉记忆管线（Stage A/B/C）、WASM 硬件许可、以及意图驱动的统一 ReAct 执行循环。

## 核心要点

- 核心理念：「评估一个 AI Agent = 评估模型 + Harness。模型是商品，Harness 才是护城河。」
- 基于 Spring Boot 3.5.7 + Spring AI 1.1.2 构建的工程化 AI Agent 架构
- 采用 Harness Engineering 模式，将 LLM 调用作为最小盒子，围绕它构建完整系统层
- 多模型架构（4 角色模型 × 多供应商）、三层记忆系统、意图驱动路由、五层上下文压缩
- 47 个 @Tool 涵盖 11 个功能模块，支持内置工具 + MCP 外部工具

## 详细摘要

### 技术栈

| 项 | 值 |
|---|---|
| Spring Boot | 3.5.7 |
| Spring AI | 1.1.2 |
| Spring AI Alibaba | 1.1.2.2 |
| Java | 17 |
| 向量数据库 | Qdrant（端口 18140/18141） |
| Embedding | Ollama bge-m3（本地）/ DashScope text-embedding-v3/v4（云端） |
| 密码学 | Bouncy Castle 1.78.1（SM2/SM3） |

### 系统层次

从上到下分为多层：

1. **ChatService**：SSE 入口 + UIMessageStreamAdapter 协议适配 + 意图驱动路由 + 多模型解析
2. **IntentRouter**：两层意图识别（关键词快速通道 + LLM 兜底），SkillRecipeLoader 按意图匹配注入
3. **执行引擎**：ToolRegistry（工具注册，内置 + MCP）、PromptAssembler（15 个 Section）、ContextManager（五层压缩管线）
4. **BackpressureController**：滑动窗口预测性背压
5. **ModelResolverService**：4 角色模型（default/review/vision/memory-init）× 多供应商（OpenAI/DashScope/DeepSeek/Qwen）+ Thinking Mode
6. **Memory 系统**：L1 SessionMemory + L2 ProjectMemory（Redis） + L3 DrawingMemory（Qdrant + Redis）+ 视觉记忆管线（Stage A/B/C）
7. **RagService**：RAG 三级缓存 + SingleFlight + 熔断 + Rerank
8. **Tool 层**：11 模块 47 个 @Tool（read/write/pipeline/execution/analysis/interaction/review/atomic/planning/memory + MCP）
9. **License**：WASM 硬件许可（6 步验证 + SM2 签名 + SM3 指纹）

### 请求处理流程

前端发送 POST /api/ai/chat（SSE），经 ChatService → IntentRouter 意图识别 → SkillRecipeLoader 匹配 Recipe → ContextManager 压缩上下文 → QueryEngine 执行 ReAct 循环（调用 LLM + ToolOrchestrator 编排工具），最终以 SSE 流返回。

### 多模型架构

4 个独立角色模型（default/review/vision/memory-init），每个角色独立配置 apiKey/baseUrl/model。供应商类型：openai（标准协议）、dashscope（Qwen3 Thinking Mode）、deepseek/qwen（OpenAI 兼容）。Embedding 双供应商（Ollama 本地 / DashScope 云端），CachedEmbeddingModel 包装并 Redis 缓存。

### 意图路由

两层策略：关键词快速通道（零延迟，按优先级匹配：审图 > 读取 > 修改 > 创建 > 删除 > 变换）和 LLM 结构化分析兜底（仅 MIXED 意图时触发）。意图枚举：READ/MODIFY/CREATE/DELETE/TRANSFORM/REVIEW/MIXED。

### Harness Engineering 设计理念

借鉴《Claude Code 论文》七大设计视角，将 LLM 调用视为最小盒子，围绕它构建：工具编排、上下文管理、Prompt 装配、Memory 系统、视觉记忆管线、多模型架构、硬件许可、审图编排、错误恢复、扩展机制等系统层。核心思想是「模型可替换，Harness 持久」。

## 引用的实体与概念

- 相关实体：[[Spring Framework]] — Spring Boot 3.5.7 + Spring AI 是项目的技术基础
- 相关概念：[[AI编程助手]] — AI Agent 架构的工程化实践

## 与现有知识的关联

- Spring Boot 和 Spring AI 与 [[Spring Framework]] 实体页紧密关联
- Qdrant 向量数据库与 RAG 检索增强生成的知识相关
- 多模型架构体现了 LLM 应用中的模型选型和降级策略
- Harness Engineering 模式可作为 AI 应用工程化的参考架构
