---
title: OAuth 2.0 官方规范索引
date: 2026-05-09
type: article
source_url: https://oauth.net/2/
tags: [oauth, 认证授权, 规范, RFC]
related_entities: [[entities/Aaron Parecki]]
related_concepts: [[concepts/OAuth2授权框架]]
---

oauth.net 官网的 OAuth 2.0 规范索引页面，系统梳理了 OAuth 2.0 生态中所有 RFC 规范、授权类型、令牌管理、发现注册、高安全扩展、草案规范及基于 OAuth 2.0 构建的上层协议。本文是对已有 OAuth2 知识的 RFC 编号补充和规范全景索引。

## 核心要点

- OAuth 2.0 框架定义于 RFC 6749，Bearer Token 定义于 RFC 6750
- 安全最佳实践已整合为 RFC 9700（OAuth Security Best Current Practice）
- 令牌管理三大规范：Introspection（RFC 7662）、Revocation（RFC 7009）、Exchange（RFC 8693）
- JWT Access Token 格式标准化为 RFC 9068
- 发现与注册：Authorization Server Metadata（RFC 8414）、Dynamic Client Registration（RFC 7591/7592）
- 高安全扩展：PAR（RFC 9126）、DPoP（RFC 9449）、mTLS（RFC 8705）、Private Key JWT
- 基于 OAuth 2.0 构建的上层协议：OpenID Connect、UMA 2.0、IndieAuth
- OAuth 2.1 正在将 OAuth 2.0 及其常用扩展整合为统一规范

## RFC 规范索引

### 核心规范

| RFC | 标题 | 说明 |
|-----|------|------|
| 6749 | OAuth 2.0 Framework | 框架核心，定义四种角色和授权流程 |
| 6750 | Bearer Token Usage | Bearer Token 的三种传递方式 |
| 6819 | Threat Model | OAuth 2.0 威胁模型和安全考量 |
| 9700 | Security Best Practices | 安全最佳实践（BCP） |

### 授权类型

| RFC | 类型 | 状态 |
|-----|------|------|
| 6749 | Authorization Code | 推荐 |
| 6749 | Client Credentials | M2M 场景 |
| 8628 | Device Authorization | 无浏览器设备 |
| 6749 | Refresh Token | 令牌刷新 |
| - | Implicit | 已弃用 |
| - | Password Grant | 已弃用 |

### PKCE

RFC 7636 定义了 PKCE（Proof Key for Code Exchange），OAuth 2.1 对所有授权码流程强制要求。

### 令牌管理

| RFC | 功能 | 说明 |
|-----|------|------|
| 7519 | JSON Web Token (JWT) | JWT 令牌格式 |
| 9068 | JWT Profile for Access Tokens | 结构化 Access Token 标准 |
| 7662 | Token Introspection | 查询 Token 活跃状态和元信息 |
| 7009 | Token Revocation | 通知授权服务器 Token 不再需要 |
| 8693 | Token Exchange | 令牌交换，在不同安全域间委托授权 |

### 发现与注册

| RFC | 功能 |
|-----|------|
| 8414 | Authorization Server Metadata - 客户端发现端点和能力 |
| 7591 | Dynamic Client Registration - 编程方式注册客户端 |
| 7592 | Dynamic Client Registration Management - 管理已注册客户端（实验性） |

### 高安全扩展

| RFC/规范 | 技术 | 说明 |
|----------|------|------|
| 9126 | PAR (Pushed Authorization Requests) | 防止授权请求篡改 |
| 9449 | DPoP (Demonstration of Proof of Possession) | 将令牌绑定到客户端密钥对 |
| 8705 | Mutual TLS (mTLS) | 双向 TLS 客户端认证 |
| 7521/7523 | Private Key JWT / JWT Bearer | 非对称密钥客户端认证 |
| - | FAPI | 金融级 API 安全配置文件 |

### 其他扩展

| RFC | 功能 |
|-----|------|
| 7521 | OAuth Assertions Framework |
| 7522 | SAML2 Bearer Assertion - 与 SAML 身份系统集成 |
| 7523 | JWT Bearer Assertion |
| 9207 | Authorization Server Issuer Identification |
| 9396 | Rich Authorization Requests (RAR) - 细粒度权限请求 |
| 9470 | Step-up Authentication Challenge |

## 基于 OAuth 2.0 的上层协议

- **OpenID Connect**（OpenID Foundation）：在 OAuth2 上增加身份认证层
- **UMA 2.0**（Kantara）：User-Managed Access，用户主导的资源授权管理
- **IndieAuth**（W3C）：基于个人域名的去中心化身份认证

## 社区相关

- **WebAuthn / passkeys**：无密码认证，与 OAuth 互补
- **HTTP Message Signatures**：通用 HTTP 消息签名规范
- **OpenID for Verifiable Credentials**：可验证凭证的 OpenID 集成

## 推荐资源

- 书籍：《OAuth 2.0 Simplified》（Aaron Parecki）、《OAuth 2 in Action》（Justin Richer & Antonio Sanso）
- 视频：The Nuts and Bolts of OAuth 2.0（Aaron Parecki）

## 与现有知识的关联

- 与 [[concepts/OAuth2授权框架]] 互补：概念页详述原理和实践，本页提供 RFC 编号索引
- 与 [[sources/OAuth2与OpenIDConnect]] 互补：已有来源详述 OAuth2+OIDC 理论与 Spring 实战，本页补充规范全景
- 令牌管理（Introspection/Revocation/Exchange）在已有知识中未单独列出 RFC 编号
