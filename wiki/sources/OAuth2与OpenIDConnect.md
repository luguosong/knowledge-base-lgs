---
title: OAuth2 与 OpenID Connect
date: 2026-05-08
type: note
tags: [oauth, 认证授权, Spring]
related_concepts: [[concepts/OAuth2授权框架]]
---

## 核心要点

- OAuth2 是授权协议（回答「应用能访问哪些资源？」），OIDC 是认证层（回答「当前用户是谁？」）
- 四种角色：Resource Owner、Client、Authorization Server、Resource Server
- 推荐授权码流程 + PKCE，隐式流程和 ROPC 已在 OAuth 2.1 中弃用
- JWT 三段式结构（Header.Payload.Signature），注册声明中 exp 和 aud 是最关键的验证声明
- Spring Authorization Server 是 Java 生态的授权服务器实现
- OAuth 2.1 将分散在多个 RFC 中的安全最佳实践整合为一份规范

## 详细摘要

### OAuth2 核心概念

四种角色类比快递代取系统：Resource Owner（包裹主人）、Client（快递员/应用）、Authorization Server（前台工作人员）、Resource Server（仓库管理员）。

客户端分为两类：机密客户端（能安全保管 client_secret，如服务端 Web 应用）和公开客户端（无法安全存储密钥，如 SPA/移动 App）。客户端认证方式：Client Secret、Mutual TLS（mTLS）、Private Key JWT。

Scope（权限范围）限制应用对用户账户的访问范围，授权服务器或用户可以修改最终授予的 Scope（部分授权）。

### 授权流程

- **授权码流程（推荐）**：前端通道传递授权码，后端通道凭码 + client_secret 换 Token。授权码一次性的、无法独立使用
- **PKCE**：客户端生成 code_verifier，发送其哈希 code_challenge，换 Token 时提交原始值。即使授权码被截获，没有 code_verifier 也无法换 Token。OAuth 2.1 对所有授权码流程强制 PKCE
- **客户端凭证流程**：M2M 场景，无用户参与，不颁发 Refresh Token
- **设备授权流程**：无浏览器设备（智能电视、CLI 工具），通过 user_code 在辅助设备完成授权
- **隐式流程（已弃用）**：Token 暴露在浏览器 URL 片段中，已被授权码 + PKCE 替代
- **ROPC（已弃用）**：客户端直接持有用户密码，违背 OAuth 核心设计原则

### 令牌体系

- **Access Token**：短有效期（分钟到小时），有限权限，格式不固定（JWT 或 Opaque Token）
- **Refresh Token**：长有效期（天到月），只发送给授权服务器换取新 Access Token
- **Bearer Token 传递**：Authorization 请求头（推荐）、Form-Encoded Body（可选）、URI Query Parameter（OAuth 2.1 已禁止）
- **Sender-Constrained Token**：将令牌与客户端密钥绑定（mTLS 或 DPoP），解决「谁拿到谁就能用」的安全隐患

### JWT 令牌

JWT 三段式结构：Header（算法/类型） + Payload（声明） + Signature（签名）。Payload 是 Base64url 编码而非加密，不应存放敏感信息。

七个注册声明：`iss`（签发者）、`sub`（主体）、`aud`（受众）、`exp`（过期时间）、`nbf`（生效时间）、`iat`（签发时间）、`jti`（唯一标识）。**exp 和 aud 是最关键的验证声明**。

JWKS 端点（RFC 7517）让资源服务器动态获取授权服务器公钥。签名算法推荐 RS256 或 ES256（非对称，授权服务器私钥签名，资源服务器公钥验证）。

Opaque Token vs JWT：JWT 自包含可本地验证（高并发友好），Opaque Token 需远程验证但支持即时撤销。RFC 9068 标准化了 JWT Access Token 格式。

### OpenID Connect

OIDC 在 OAuth2 授权码流程基础上额外颁发 ID Token（JWT 格式，包含用户身份信息）。触发条件：scope 中包含 `openid`。

关键概念：
- **ID Token**：包含 sub/iss/aud/exp/nonce 等声明，客户端必须验证签名、iss、aud、exp、nonce
- **UserInfo 端点**：用 Access Token 查询最新用户信息
- **发现文档**：`/.well-known/openid-configuration` 包含所有端点地址
- **Hybrid Flow**：结合授权码和隐式流程，ID Token 在前端通道返回，Access Token 通过 Token 端点获取
- **登出机制**：RP-Initiated Logout（用户主动）、Front-Channel Logout（iframe 通知）、Back-Channel Logout（服务端直接通知，最可靠）

### Spring Authorization Server 实战

基于 Spring Boot 3.5.x + Spring Authorization Server 1.5.x（最后独立版本，Spring Security 7.0 起合并进主项目）。

核心 Bean：RegisteredClientRepository（客户端注册）、JWKSource（签名密钥）、AuthorizationServerSettings（端点配置）、SecurityFilterChain（安全链配置）。

支持自定义授权页面（consentPage）、自定义 Token Claims（OAuth2TokenCustomizer）、OIDC 支持。生产环境应使用 JdbcRegisteredClientRepository、固定密钥对、BCrypt 编码密码。

### OAuth 2.1 演进

OAuth 2.1 不是新协议，而是对 OAuth 2.0 生态中多年最佳实践的整合。七大关键差异：
1. PKCE 对所有授权码流程强制
2. 移除隐式流程
3. 移除 ROPC
4. redirect_uri 必须精确字符串匹配
5. 禁止 URI 查询参数传递 Bearer Token
6. Refresh Token 必须受限于发送者或一次性使用
7. 令牌请求中 redirect_uri 处理简化

OAuth 2.1 与 OAuth 2.0 向后兼容，现有实现大部分只需配置调整。

## 引用的实体与概念

- 相关工具：Spring Authorization Server、Spring Security、PKCE
- 相关实体：[[Spring Framework]]
- 相关概念：[[concepts/OAuth2授权框架]]

## 与现有知识的关联

- OAuth2 与 [[concepts/OAuth2授权框架]] 概念页对应，涵盖从理论到 Spring 实战的完整链路
- JWT 令牌与 [[concepts/网络安全]] 的加密/签名知识相关
- Spring Authorization Server 与 [[Spring Framework]] 生态紧密集成
- Docker 容器化部署与 Spring Boot 应用的生产发布相关（[[sources/Docker容器化]]）
