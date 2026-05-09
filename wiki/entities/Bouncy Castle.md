---
title: Bouncy Castle
type: project
tags: [密码学, Java, 加密库, 开源]
sources: "[[sources/密码学体系学习]]"
---

# Bouncy Castle

## 概述

Bouncy Castle 是一个开源的 Java/C# 密码学库，提供丰富的加密算法实现。它是 Java 生态中最主要的第三方 JCA Provider，填补了 JDK 内置加密功能之外的空白，尤其在后量子密码（PQC）、OpenPGP、CMS/S/MIME 等领域是 Java 平台上唯一的成熟实现。

- **官网**：https://www.bouncycastle.org/
- **许可证**：MIT-like（适应性强，可商用）
- **维护者**：David Hook、Jon Eaves 等（也是《Java Cryptography》的作者）

## 关键信息

### 架构设计

Bouncy Castle 提供两层 API：

1. **JCA Provider 层**：实现 `java.security.Provider` 接口，注册后即可通过标准 JCA 引擎类（`Cipher`、`Signature`、`MessageDigest`、`KeyPairGenerator` 等）透明使用
2. **轻量级 API 层**：`org.bouncycastle.crypto` 包下的直接 API，用于 JCA 尚未标准化的算法（如 ML-KEM、OpenPGP）

```java
// 注册 Provider（应用启动时调用一次）
Security.addProvider(new BouncyCastleProvider());

// 之后所有 JCA 调用都可使用 "BC" 作为 Provider
Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding", "BC");
Signature sig = Signature.getInstance("SHA256withECDSA", "BC");
```

### Maven 依赖

```xml
<dependency>
    <groupId>org.bouncycastle</groupId>
    <artifactId>bcprov-jdk18on</artifactId>
    <version>1.80</version>
</dependency>
```

### 核心能力

| 领域 | 能力 | 备注 |
|------|------|------|
| **对称加密** | AES/CBC/CTR/GCM/EAX、ChaCha20-Poly1305 | 全模式覆盖 |
| **非对称加密** | RSA-OAEP、ECIES | 支持 RSA 和椭圆曲线混合加密 |
| **数字签名** | DSA、ECDSA、EdDSA（Ed25519/Ed448）、RSA-PSS、SM2 | 标准 JCA `Signature` 接口 |
| **哈希与 MAC** | SHA-2/3、HMAC、BLAKE2 | 包含 XOF（SHAKE） |
| **密钥交换** | DH、ECDH（X25519/X448） | 标准 JCA `KeyAgreement` |
| **后量子密码** | ML-KEM、ML-DSA、SLH-DSA、Falcon | 1.80+ 版本，Java 生态唯一 PQC 实现 |
| **证书与 PKI** | X.509 证书生成/验证、CRL、OCSP | |
| **OpenPGP** | PGP 加密/签名/密钥环管理 | `bcpg` 模块 |
| **CMS/S/MIME** | 加密消息语法、邮件加密 | `bcpkix` + `bcmail` 模块 |
| **ASN.1** | 完整的 ASN.1 编解码 | 密码学协议的基础设施 |

### 后量子密码支持（1.80+）

Bouncy Castle 1.80 是 Java 生态中**唯一生产可用的 PQC 实现**：

- **ML-DSA**：已注册到标准 JCA Provider，`Signature.getInstance("ML-DSA-65", "BC")` 直接可用
- **ML-KEM**：通过底层 API（`MLKEMGenerator`/`MLKEMExtractor`）操作
- **SLH-DSA**：`Signature.getInstance("SLH-DSA-SHA2-128f", "BC")`
- **Falcon**：`Signature.getInstance("Falcon-512", "BC")`
- **混合方案辅助**：`HybridValueParameterSpec`、`PQCOtherInfoGenerator`

### 与 JDK 内置加密的对比

| 维度 | JDK 内置（SunJCE/SunEC） | Bouncy Castle |
|------|------------------------|---------------|
| AES 模式 | CBC/CTR/GCM | + EAX/KW/XTS 等 |
| 椭圆曲线 | P-256/P-384/P-521 | + Ed25519/Ed448/X25519/sm2p256v1 |
| 后量子算法 | 无 | ML-KEM/ML-DSA/SLH-DSA |
| OpenPGP/CMS | 无 | 完整支持 |
| 证书操作 | 基础 | 完整（生成/验证/路径验证） |

### KeyStore 类型

Bouncy Castle 提供专有 KeyStore 格式 **BCFKS**（Bouncy Castle FIPS KeyStore），相比 JKS/PKCS12 的优势：
- 密钥和证书都经过加密保护
- 支持 HMAC 完整性校验
- 适合安全要求更高的生产环境

## 相关实体与概念

- [[密码学]]：Bouncy Castle 提供了密码学算法的 Java 实现集合
- [[sources/密码学体系学习]]：本文的学习笔记中大量使用 Bouncy Castle 作为代码示例基础
