---
title: RFC 6749 OAuth 2.0 授权框架（中文翻译）
date: 2025-07-10
type: article
source_url: https://datatracker.ietf.org/doc/html/rfc6749
tags: [OAuth2, RFC, 认证授权, 规范翻译]
related_concepts: [[concepts/OAuth2授权框架]]
related_entities: [[entities/Aaron Parecki]]
---

RFC 6749《OAuth 2.0 授权框架》中文翻译，原文约 20065 字，作者 D. Hardt（Microsoft），2012 年 10 月发布，取代 RFC 5849（OAuth 1.0）。本文是 OAuth 2.0 的核心规范，定义了四种角色、协议流程、四种授权许可类型以及令牌端点交互的完整规范。与 [[sources/OAuth2官方规范索引]] 形成互补：索引页提供规范全景，本页提供 RFC 6749 原文的中文翻译内容。

## 核心要点

- **四种角色**：资源所有者（Resource Owner）、资源服务器（Resource Server）、客户端（Client）、授权服务器（Authorization Server）
- **四种授权类型（Authorization Grant）**：
  1. **授权码（Authorization Code）**：最安全，推荐 Web 应用和移动应用使用，PKCE 扩展（RFC 7636）增强安全性
  2. **隐式授权（Implicit）**：已在 OAuth 2.1 中废弃，不建议使用
  3. **资源所有者密码凭证（Password）**：直接传递用户名密码，仅限高度可信的客户端，OAuth 2.1 中废弃
  4. **客户端凭证（Client Credentials）**：机器到机器（M2M）场景，无用户参与
- **令牌类型**：访问令牌（Access Token）短期有效；刷新令牌（Refresh Token）用于获取新的访问令牌
- **端点**：授权端点（`/authorize`）处理用户交互；令牌端点（`/token`）处理机器交互
- **Bearer Token**：RFC 6750 定义令牌在 HTTP 请求中的携带方式（`Authorization: Bearer <token>`）
- **取代 RFC 5849**：OAuth 1.0 要求签名每个请求（复杂）；OAuth 2.0 依赖 HTTPS 传输安全

## 协议流程概述

### 授权码流程（推荐）

```
用户             客户端          授权服务器       资源服务器
 │ ─→ 访问 ─→   │               │               │
 │               │ ─→ 重定向 ─→ │               │
 │ ←─ 登录授权 ─ │               │               │
 │               │ ←─ code ─── │               │
 │               │ ─→ code+secret ─→           │
 │               │ ←─────── access_token ──────│
 │               │ ─→ access_token ─────────→  │
 │               │ ←─────── 受保护资源 ─────── │
```

## 与现有知识的关联

- 与 [[sources/OAuth2官方规范索引]] 互补：本页是 RFC 6749 全文翻译，索引页是整个 OAuth 2.0 生态规范全景
- 与 [[concepts/OAuth2授权框架]] 关联：本规范是 OAuth2 概念的核心定义文档
