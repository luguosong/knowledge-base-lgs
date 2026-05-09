# Wiki 索引

> 本索引由 LLM 自动维护，记录 Wiki 中所有页面的目录。

## 来源摘要

- [[sources/AI编程工具研究]] - 汇总 Agent SDK、Claude Code、Copilot CLI、MCP 服务器的 AI 编程工具研究笔记
- [[sources/Superpowers技能框架]] - 编码 Agent 可组合技能框架，苏格拉底式设计、子 Agent 驱动开发、强制 TDD
- [[sources/设计模式与面向对象]] - GoF 23 种经典设计模式、SOLID 原则、OOP 基础及主流框架中的模式应用
- [[sources/Linux系统学习]] - Linux 完整知识体系（基础、存储、Shell、系统管理、网络服务、系统编程），覆盖 Debian 和 Red Hat 两大发行版
- [[sources/密码学体系学习]] - 从密码学原语到应用协议的完整体系（22 个模块），含 Java/Bouncy Castle 实现与后量子密码
- [[sources/Docker容器化]] - Docker 基础、Compose 编排、Harbor 私有仓库、CI/CD 集成、镜像安全扫描、生产实践
- [[sources/Git版本控制]] - Git 分布式版本控制、VCS 演进、分支策略、变基、内部原理、钩子机制、最佳实践
- [[sources/OAuth2与OpenIDConnect]] - OAuth2 授权框架、OIDC 认证层、JWT 令牌、Spring Authorization Server 实战
- [[sources/OAuth2官方规范索引]] - oauth.net 官网 OAuth 2.0 生态全规范 RFC 索引（令牌管理、发现注册、高安全扩展）
- [[sources/Windows开发环境]] - WSL 2 使用指南、DOS 命令速查手册、开发环境集成
- [[sources/UOCS-Harness架构]] - 基于 Spring AI 和 LLM 的 Harness Engineering 架构，多模型、三层记忆、意图路由
- [[sources/网络安全学习路线]] - 从零基础到网络安全专家的六阶段学习路线，涵盖渗透测试、Web 安全、内网攻防
- [[sources/gstack工作流]] - Garry Tan 的 Claude Code 工作流，23 个专家角色 + 8 个工具，虚拟工程团队 Sprint 流程
- [[sources/LLM-Wiki模式]] - Karpathy 提出的 LLM 增量构建个人知识库模式，三层架构 + 三个核心操作
- [[sources/新概念英语第一册001课]] - 新概念英语第一册第001课 "Excuse me!"，一般疑问句、Excuse me/Pardon 多语境用法

## 实体

- [[entities/Anthropic]] - AI 安全公司，Claude 模型、Claude Code、Agent SDK 的开发者
- [[entities/GitHub]] - 全球最大代码托管平台，Copilot CLI 的开发者
- [[entities/智谱AI]] - 中国 AI 公司，GLM 模型和 MCP 服务器的提供者
- [[entities/Spring Framework]] - Java 企业级应用开发框架，大量使用设计模式
- [[entities/Bouncy Castle]] - Java/C# 开源密码学库，JCA Provider 与 PQC 算法实现
- [[entities/Superpowers]] - 编码 Agent 技能框架，支持 Claude Code/Gemini CLI/Cursor 等多种编码 Agent
- [[entities/gstack]] - Y Combinator CEO Garry Tan 的 Claude Code 工作流框架，23 个专家角色虚拟工程团队
- [[entities/Andrej Karpathy]] - AI 研究者、OpenAI 联合创始人、前 Tesla AI 总监，LLM Wiki 模式提出者
- [[entities/新概念英语]] - 经典英语教材系列（四册），从零基础到高级渐进式学习
- [[entities/Aaron Parecki]] - OAuth 2.0 核心贡献者，oauth.net 维护者，《OAuth 2.0 Simplified》作者

## 概念

- [[concepts/AI编程助手]] - 基于 LLM 的编程辅助工具，采用代理循环模式自主执行开发任务
- [[concepts/MCP协议]] - Model Context Protocol，AI 工具的标准扩展协议
- [[concepts/Agentic Loop]] - AI 代理的循环执行模式（思考→行动→观察→再思考）
- [[concepts/设计模式]] - GoF 23 种经典设计模式，分为创建型、结构型、行为型三大类
- [[concepts/SOLID原则]] - 面向对象设计的五大原则（SRP、OCP、LSP、ISP、DIP）
- [[concepts/Linux文件系统]] - Linux 文件系统层次结构、inode 机制、LVM 逻辑卷管理、RAID 磁盘阵列
- [[concepts/Shell编程]] - Bash 脚本编程、正则表达式、grep/sed/awk 文本处理三剑客、Vim 编辑器
- [[concepts/Linux网络服务]] - Linux 常见网络服务部署（SSH/Nginx/Apache/DNS/Postfix/NFS/Samba）
- [[concepts/Linux系统编程]] - Linux 系统级编程接口（系统调用、进程、线程、IPC、Socket、epoll）
- [[concepts/Docker容器化]] - 容器化技术原理、镜像分层、Docker Compose 编排、CI/CD 集成、生产环境最佳实践
- [[concepts/Git版本控制]] - 分布式版本控制、快照存储、分支策略、rebase、内部原理、Git 钩子
- [[concepts/OAuth2授权框架]] - OAuth2 授权码/PKCE/客户端凭证流程、JWT 令牌、OIDC 认证层、Spring Authorization Server
- [[concepts/密码学]] - 保护信息安全的科学与技术，涵盖对称/非对称加密、哈希、签名、密钥交换等
- [[concepts/TLS协议]] - Transport Layer Security，保护网络通信安全的协议（TLS 1.2/1.3 握手、密码套件、前向保密）
- [[concepts/数字签名]] - 提供身份认证和不可否认性的密码学技术（DSA/ECDSA/EdDSA/RSA-PSS/SM2）
- [[concepts/后量子密码]] - 抵抗量子计算机攻击的密码学算法（ML-KEM/ML-DSA、NIST 标准、混合方案）
- [[concepts/网络安全]] - 网络安全核心概念，涵盖攻防对抗、安全评估、合规要求
- [[concepts/渗透测试]] - 模拟攻击以评估系统安全性的方法论
- [[concepts/Web安全漏洞]] - Web 应用常见安全漏洞（SQL 注入、XSS、CSRF 等）
- [[concepts/内网渗透]] - 内部网络渗透测试技术与防御策略
- [[concepts/LLM Wiki模式]] - 使用 LLM 增量构建个人知识库的架构模式（Karpathy 提出），知识编译一次持续更新

## 综合

<!-- ingest 时在此添加综合分析条目 -->

---

*最后更新：2026-05-09*
*页面总数：46*
