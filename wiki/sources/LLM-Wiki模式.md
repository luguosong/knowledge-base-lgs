---
title: LLM Wiki 模式
date: 2026-05-09
type: article
source_url: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
tags: [AI, 知识管理, LLM, Wiki]
related_entities: [[Andrej Karpathy]]
related_concepts: [[LLM Wiki模式]]
---

Andrej Karpathy 提出的 LLM Wiki 模式，是一种使用 LLM 增量构建和维护个人知识库的架构。与传统 RAG（每次查询从零推导）不同，LLM Wiki 让 LLM 持续编译知识到结构化的 Markdown 文件中，形成可复利的持久化产物。三层架构（Raw → Wiki → Schema）和三个核心操作（Ingest / Query / Lint）定义了完整的知识管理工作流。

## 核心要点

- **核心区别**：wiki 是持久化的、可复利的产物，交叉引用已建好，矛盾已标记，不是每次查询都重新推导
- **三层架构**：Raw sources（不可变源文档）→ Wiki（LLM 维护的结构化 Markdown）→ Schema（告诉 LLM 如何维护 wiki 的规则文档）
- **三个核心操作**：Ingest（摄入新资料）、Query（查询并回填洞察）、Lint（健康检查）
- **人机分工**：人类管理资料来源、引导方向、提问题；LLM 承担摘要、交叉引用、归档等维护工作
- **工具生态**：Obsidian（浏览 wiki）、qmd（本地 Markdown 搜索引擎）、Marp（幻灯片）、Dataview（frontmatter 查询）
- **精神传承**：与 Vannevar Bush 的 Memex（1945）相关——私有的、主动管理的知识存储，文档间连接与文档本身同等重要

## 关键洞察

### 为什么这能工作

维护知识库的繁琐不在于阅读或思考，而在于归档管理——更新交叉引用、保持摘要最新、标注矛盾。人们放弃 wiki 的原因是维护负担增长得比价值快。LLM 不会厌倦，能一次处理 15 个文件，使维护成本接近零。

### 适用场景

- **个人**：追踪目标、健康、自我提升
- **研究**：深入主题，增量构建综合 wiki
- **读书**：逐章归档，构建角色/主题/情节关联
- **商业/团队**：LLM 维护的内部 wiki，输入来自 Slack/会议/文档
- **竞争分析、尽职调查、旅行规划、课程笔记**

### 实践建议

- Obsidian 是 IDE，LLM 是程序员，wiki 是代码库
- 好的回答应回填到 wiki 中（如对比、分析、关联发现）
- 索引文件 + append-only 日志是导航 wiki 的两个关键文件
- 可选工具（如 qmd 搜索引擎）按需引入，小规模时索引文件足够

## 与现有知识的关联

- 本知识库（LLM Wiki 知识库）正是该模式的完整实现
- Schema 层对应本项目的 `CLAUDE.md` 文件
- LLM 的维护工作通过 `/ingest`、`/query`、`/lint` 等 skill 实现
- 与 [[AI编程助手]] 的关系：LLM Wiki 是 AI 编程助手在知识管理领域的特定应用模式
