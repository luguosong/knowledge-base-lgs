---
title: TLS协议
tags: [密码学, TLS, 网络安全, 协议]
sources: "[[sources/密码学体系学习]]"
---

# TLS 协议

## 定义

TLS（Transport Layer Security，传输层安全协议）是保护网络通信安全的标准协议，前身是 Netscape 于 1994 年设计的 SSL。TLS 在客户端和服务端之间建立加密通道，同时解决窃听（机密性）、篡改（完整性）和冒充（认证）三大威胁。当前主流版本为 TLS 1.2（RFC 5246）和 TLS 1.3（RFC 8446）。

## 关键要点

### 威胁模型

TLS 的设计基于 Dolev-Yao 模型：假设攻击者完全控制网络（可窃听、拦截、修改、注入消息），拥有无限计算资源，可同时与多个端点建立连接。安全目标为机密性、完整性和认证。

### 握手流程

**TLS 1.2**（2-RTT）：ClientHello → ServerHello + Certificate + ServerKeyExchange → ClientKeyExchange + ChangeCipherSpec → ChangeCipherSpec

**TLS 1.3**（1-RTT）：ClientHello（含 Key Share）→ ServerHello（Key Share）+ EncryptedExtensions + Certificate + Finished → Finished。通过在 ClientHello 中预发送密钥交换参数，将握手压缩到一次往返。

### 密码套件（Cipher Suite）

密码套件定义连接使用的所有加密算法，包含四个组件：

```
TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
     │     │       │    │     │
  密钥交换  认证  对称加密  模式  哈希
```

- **TLS 1.2**：支持数百个套件（含弱套件），命名包含全部组件
- **TLS 1.3**：仅 5 个精选套件，密钥交换固定 ECDHE，命名简化为对称加密 + 哈希

### 前向保密（Forward Secrecy）

前向保密保证：即使服务端长期私钥泄露，攻击者也无法解密历史会话。关键机制是临时密钥交换（ECDHE）——每次握手生成全新的临时密钥对，用完即销毁。TLS 1.3 强制前向保密，移除了不支持前向保密的 RSA 密钥交换。

### TLS 1.3 的关键改进

| 维度 | TLS 1.2 | TLS 1.3 |
|------|---------|---------|
| 握手轮次 | 2-RTT | 1-RTT（0-RTT 可选） |
| 密钥交换 | RSA/DHE/ECDHE 均可选 | 仅 ECDHE/DHE |
| 加密模式 | CBC + MAC（Padding Oracle 风险） | 仅 AEAD |
| 密码套件 | 数百个 | 5 个 |
| 废弃算法 | — | RC4、3DES、MD5、SHA-1 |
| 可证明安全 | 无 | 基于 SIGMA 框架，可归约到 CDH 假设 |

### 0-RTT 与重放风险

TLS 1.3 的 0-RTT 机制允许客户端在握手同时发送数据，但无法防止重放攻击——只能用于幂等操作（HTTP GET），绝不能用于支付等非幂等操作。

### 密钥派生链

TLS 1.3 使用统一的 HKDF 链：Early Secret → Handshake Secret → Master Secret → Application Traffic Secret → 记录层密钥。每个阶段的密钥绑定握手消息哈希，确保握手参数不可篡改。

### QUIC 与 HTTP/3

QUIC 将 TLS 1.3 内嵌进传输层，以 UDP 为基础，解决了 HTTP/2 over TCP 的队头阻塞问题。支持 0-RTT 连接恢复和连接迁移（Wi-Fi 切 4G 不中断）。

### Java JSSE 编程

```
SSLContext（核心入口）
  ├── KeyManager（管理自己的私钥和证书）
  ├── TrustManager（验证对端证书）
  └── SecureRandom（随机数生成器）
       ↓
  SSLSocket / SSLServerSocket（加密通信端点）
```

关键类：`SSLContext`、`KeyManagerFactory`、`TrustManagerFactory`、`SSLSocket`、`SSLSession`。

### 常见 TLS 攻击

| 攻击 | 针对版本 | 根本防御 |
|------|---------|---------|
| POODLE | SSL 3.0 | 禁用 SSL 3.0 |
| BEAST | TLS 1.0 | 升级到 TLS 1.1+ |
| DROWN | SSLv2 | 完全禁用 SSLv2 |
| Lucky13 | TLS 1.2 CBC | 升级到 TLS 1.3 |

## 与其他概念的关系

- [[密码学]]：TLS 是密码学原语（ECDHE + AES-GCM + 数字签名 + 证书）组合成安全系统的典型范例
- [[数字签名]]：TLS 握手中 CertificateVerify 消息使用数字签名验证服务端身份

## 生产环境建议

- 新项目直接配置 TLSv1.3，历史系统至少启用 TLS 1.2
- 禁用所有含 RSA 密钥交换的密码套件，只保留 ECDHE 前缀
- 绝不能实现"信任所有证书"的 TrustManager——等于关闭身份认证
- 自签名证书应导入 TrustStore 或精确匹配公钥指纹
