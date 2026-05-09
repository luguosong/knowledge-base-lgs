---
title: OAuth2 授权框架
tags: [oauth, 认证授权, 安全, Spring]
sources: [[sources/OAuth2与OpenIDConnect]], [[sources/OAuth2官方规范索引]]
---

OAuth2（RFC 6749）是行业标准的授权协议，核心思想是"令牌替代密码"，允许第三方应用在用户不暴露密码的情况下获取有限的资源访问权限。涵盖四种角色、多种授权流程（授权码/PKCE/客户端凭证/设备授权）、JWT 令牌体系、OpenID Connect 身份认证层，以及 OAuth 2.1 的安全演进和 Spring Authorization Server 实践。

## 定义

OAuth2（Open Authorization 2.0，RFC 6749）是一个行业标准的授权协议，允许第三方应用在资源所有者（用户）不暴露密码的情况下，获取有限的访问权限来访问其受保护的资源。核心思想是「令牌替代密码」：用户通过授权服务器授权，第三方应用只获得有限期的访问令牌，且用户可随时撤销。

OpenID Connect（OIDC）是构建在 OAuth2 之上的身份认证层，解决「当前用户是谁」的问题，而 OAuth2 解决「应用能访问哪些资源」的问题。OIDC 并不替代 OAuth2，而是在授权流程基础上额外颁发包含用户身份信息的 ID Token。

## 四种角色

OAuth2 定义了四个核心参与者：

- **Resource Owner（资源所有者）**：拥有受保护资源的实体，通常是最终用户。决定谁可以访问其资源
- **Client（客户端）**：代表资源所有者访问受保护资源的应用程序。分为机密客户端（能安全保管 client_secret，如服务端 Web 应用）和公开客户端（无法安全存储密钥，如 SPA/移动 App）
- **Authorization Server（授权服务器）**：验证资源所有者身份并颁发访问令牌的服务器。是整个 OAuth2 流程的核心
- **Resource Server（资源服务器）**：托管受保护资源的服务器，接受访问令牌并返回资源

## 授权流程

### 授权码流程（推荐）

最安全的标准流程，将授权过程拆分为前端通道（浏览器重定向传递授权码）和后端通道（服务端直接通信换取 Token）。

关键设计：授权码作为中间步骤是因为前端通道的重定向容易被拦截，授权码无法独立使用（需要 client_secret），且用后即焚。Token 仅在后端通道传输，不经过浏览器。

### PKCE（Proof Key for Code Exchange）

授权码流程的安全增强扩展。客户端在发起授权请求前生成随机密钥（code_verifier），发送其 SHA-256 哈希（code_challenge），换 Token 时提交原始密钥。即使授权码被截获，攻击者没有 code_verifier 也无法换 Token。

OAuth 2.1 将 PKCE 对所有授权码流程设为强制（包括机密客户端）。PKCE 用 code_verifier/code_challenge 绑定替代 client_secret，使公开客户端也能安全使用授权码流程。

### 客户端凭证流程

适用于没有用户参与的机器对机器（M2M）调用。客户端直接用 client_id + client_secret 换取 Access Token，不颁发 Refresh Token。

### 设备授权流程

适用于无浏览器或输入受限的设备（智能电视、CLI 工具、IoT）。设备申请 user_code 和 verification_uri，用户在另一设备上完成授权，设备轮询等待结果。

### 已弃用流程

- **隐式流程**（OAuth 2.1 已移除）：直接在 URL 片段中返回 Access Token，Token 暴露在浏览器中，存在多种泄露风险
- **ROPC（资源所有者密码凭证）**（OAuth 2.1 已移除）：客户端直接持有用户密码，违背 OAuth 核心设计原则，无法支持 MFA

## 令牌体系

### Access Token

访问受保护资源的凭证，短有效期（分钟到小时），有限权限。格式不固定，可以是 JWT（自描述、可本地验证）或 Opaque Token（纯随机字符串，需远程验证）。

### Refresh Token

用于在 Access Token 过期后无需用户重新授权即可获取新 Token。长有效期（天到月），只发送给授权服务器，不发送给资源服务器。OAuth 2.1 要求公开客户端的 Refresh Token 必须是发送者约束（DPoP/mTLS）或一次性使用（Rotation）。

### Bearer Token 传递

RFC 6750 定义了三种传递方式。Authorization 请求头（`Bearer <token>`）是推荐方式，Form-Encoded Body 是可选替代，URI Query Parameter 已被 OAuth 2.1 完全禁止（URL 会被记录在浏览器历史、服务器日志、Referer 头中）。

### Sender-Constrained Token

解决 Bearer Token「谁拿到谁就能用」的安全隐患。通过 mTLS（RFC 8705）或 DPoP（RFC 9449）将令牌与客户端密钥绑定，即使令牌被盗也无法在其他客户端使用。

## JWT 令牌

JWT（JSON Web Token，RFC 7519）是 OAuth2 和 OIDC 中最常用的令牌格式，由三部分组成：Header（算法/类型）. Payload（声明）. Signature（签名）。

### 关键声明

七个注册声明中，**exp（过期时间）和 aud（受众）是最关键的验证声明**。不验证 exp 会接受过期令牌，不验证 aud 会导致令牌重定向攻击。其他声明：iss（签发者）、sub（主体）、nbf（生效时间）、iat（签发时间）、jti（唯一标识）。

### 签名与验证

推荐 RS256 或 ES256（非对称算法），授权服务器用私钥签名，资源服务器用公钥验证。公钥通过 JWKS 端点（RFC 7517）动态获取，支持密钥轮换。

安全陷阱：算法篡改攻击（`alg: none` 必须拒绝）、密钥来源信任（必须验证 TLS 证书链）、不安全算法与弱密钥长度。

### Opaque Token vs JWT

JWT 自包含可本地验证，适合高并发场景，但撤销有延迟。Opaque Token 需 Introspection 端点远程验证，支持即时撤销，但每次请求都有网络开销。RFC 9068 标准化了 JWT Access Token 格式。

## OpenID Connect

OIDC 在 OAuth2 授权码流程基础上额外颁发 ID Token（JWT 格式，包含用户身份信息）。触发条件：scope 参数中包含 `openid`。

### 核心组件

- **ID Token**：包含 sub（用户唯一标识）、iss、aud、exp、nonce 等声明的 JWT。客户端必须验证签名、iss、aud、exp、nonce
- **UserInfo 端点**：用 Access Token 查询最新用户信息（ID Token 是登录时快照，可能过时）
- **发现文档**：`/.well-known/openid-configuration` 发布所有端点地址，客户端无需硬编码

### 登出机制

三种互补的登出机制：RP-Initiated Logout（用户主动发起，浏览器重定向）、Front-Channel Logout（OP 通过 iframe 通知 RP，实现简单但不可靠）、Back-Channel Logout（OP 通过服务端 HTTP POST 通知 RP，最可靠但实现复杂）。生产环境应优先实现 Back-Channel Logout。

## OAuth 2.1 演进

OAuth 2.1 不是新协议，而是将 OAuth 2.0 生态中分散在多个 RFC 和 BCP 中的安全要求整合为一份规范。七大关键变化：PKCE 强制、移除隐式流程、移除 ROPC、redirect_uri 精确匹配、禁止 URI 传递 Token、Refresh Token 发送者约束或一次性使用、简化令牌请求参数。

与 OAuth 2.0 向后兼容：遵循 2.1 的实现自动兼容 2.0，现有实现大部分只需配置调整。

## Spring Authorization Server

Java 生态的授权服务器实现，基于 Spring Boot 3.5.x + Spring Authorization Server 1.5.x（Spring Security 7.0 起合并进主项目）。

核心组件：RegisteredClientRepository（客户端注册）、JWKSource（JWT 签名密钥）、AuthorizationServerSettings（端点配置）、SecurityFilterChain（安全链）。支持 OIDC、自定义授权页面、自定义 Token Claims、PKCE 强制。生产环境应使用 JDBC 存储、固定密钥对、BCrypt 编码。

## 与其他概念的关系

- [[concepts/Docker容器化]]：OAuth2 服务（Spring Authorization Server）可容器化部署，CI/CD 流水线集成安全扫描
- [[concepts/Git版本控制]]：GitHub/GitLab 的第三方登录就是 OAuth2 的典型应用场景
- [[concepts/网络安全]]：OAuth2 是现代 Web 安全架构的核心组件，令牌安全和 HTTPS 是基础要求
