# Wiki 操作日志

> append-only 日志，记录 Wiki 的所有变更历史。可通过 `grep "^## \[" log.md | tail -5` 查看最近操作。

## [2026-04-30] init | Wiki 初始化
- 创建了 LLM Wiki 目录结构
- 初始化了 index.md 和 log.md
- 创建了 CLAUDE.md Schema 文件

## [2026-05-08] ingest | AI编程工具研究
- 创建了 [[sources/AI编程工具研究]]
- 新增 [[entities/Anthropic]]
- 新增 [[entities/GitHub]]
- 新增 [[entities/智谱AI]]
- 新增 [[concepts/AI编程助手]]
- 新增 [[concepts/MCP协议]]
- 新增 [[concepts/Agentic Loop]]
- 更新了 index.md 索引

## [2026-05-08] ingest | 设计模式与面向对象
- 创建了 [[sources/设计模式与面向对象]]
- 新增 [[concepts/设计模式]]
- 新增 [[concepts/SOLID原则]]
- 新增 [[entities/Spring Framework]]
- 更新了 index.md 索引

## [2026-05-08] ingest | Docker 容器化（9 个文件）
- 创建了 [[sources/Docker容器化]]
- 新增 [[concepts/Docker容器化]]
- 更新了 index.md 索引

## [2026-05-08] ingest | Git 版本控制（15 个文件）
- 创建了 [[sources/Git版本控制]]
- 新增 [[concepts/Git版本控制]]
- 更新了 index.md 索引

## [2026-05-08] ingest | OAuth2 与 OpenID Connect（14 个文件）
- 创建了 [[sources/OAuth2与OpenIDConnect]]
- 新增 [[concepts/OAuth2授权框架]]
- 更新了 index.md 索引

## [2026-05-08] ingest | Windows 开发环境（3 个文件）
- 创建了 [[sources/Windows开发环境]]
- 更新了 index.md 索引

## [2026-05-08] ingest | UOCS Harness 架构（1 个文件）
- 创建了 [[sources/UOCS-Harness架构]]
- 更新了 index.md 索引

## [2026-05-08] ingest | 密码学体系学习（22 个文件）
- 创建了 [[sources/密码学体系学习]]
- 新增 [[concepts/密码学]]
- 新增 [[concepts/TLS协议]]
- 新增 [[concepts/数字签名]]
- 新增 [[concepts/后量子密码]]
- 新增 [[entities/Bouncy Castle]]
- 更新了 index.md 索引

## [2026-05-08] ingest | Linux 系统学习（58 个文件）
- 创建了 [[sources/Linux系统学习]]
- 新增 [[concepts/Linux文件系统]]
- 新增 [[concepts/Shell编程]]
- 新增 [[concepts/Linux网络服务]]
- 新增 [[concepts/Linux系统编程]]
- 更新了 index.md 索引

## [2026-05-08] integration | 整合旧内容
- 将旧有页面（网络安全学习路线、渗透测试、Web安全漏洞、内网渗透、网络安全）纳入索引
- 补全了 [[sources/网络安全学习路线]] 索引条目
- 补全了 [[concepts/网络安全]]、[[concepts/渗透测试]]、[[concepts/Web安全漏洞]]、[[concepts/内网渗透]] 索引条目

## [2026-05-09] ingest | Superpowers 技能框架 + Git 起步 + Linux 概述
- 创建了 [[sources/Superpowers技能框架]]
- 新增 [[entities/Superpowers]]
- 更新了 [[sources/Git版本控制]]（补充 VCS 演进史、安装配置）
- 处理了 raw/编程学习/专项研究/linux/00-Linux.md（导航页，无新内容，不更新 wiki）
- 更新了 index.md 索引

## [2026-05-09] lint | Wiki 健康检查
- 发现 27 个问题（26 个 warning，1 个 info）
- [missing-summary] 26 个概念/实体页面缺少摘要段落
- [orphan] Harness架构层次图.excalidraw.md 未被引用且未在索引中
- [suggestion] synthesis/ 目录为空，建议创建综合分析页面

## [2026-05-09] ingest | gstack 工作流 + 文件路径迁移
- 创建了 [[sources/gstack工作流]]
- 新增 [[entities/gstack]]
- 迁移了 Superpowers.md 路径（好用的扩展/ → 好用的扩展/开发工作流/）
- 迁移了 网络安全学习路线路径（编程学习/ → 编程学习/学习路线/）
- 更新了 index.md 索引

## [2026-05-09] ingest | Harness架构详解 + LLM Wiki模式 + 新概念英语001课
- 更新了 [[sources/UOCS-Harness架构]]（补充摘要段落和 sources 字段）
- 创建了 [[sources/LLM-Wiki模式]]
- 新增 [[entities/Andrej Karpathy]]
- 新增 [[concepts/LLM Wiki模式]]
- 创建了 [[sources/新概念英语第一册001课]]
- 新增 [[entities/新概念英语]]
- 更新了 index.md 索引

## [2026-05-09] ingest | OAuth 2.0 官方规范索引
- 创建了 [[sources/OAuth2官方规范索引]]
- 新增 [[entities/Aaron Parecki]]
- 更新了 [[concepts/OAuth2授权框架]]（补充 sources 引用）
- 更新了 index.md 索引

## [2026-05-09] lint | Wiki 健康检查
- 发现 3 个问题（1 个 warning，2 个 info）
- [missing-summary] 34 个页面缺少摘要段落（概念 20 + 实体 5 + 来源 9）
- [orphan] Harness架构层次图.excalidraw.md 未被内容页面引用
- [suggestion] synthesis/ 目录为空，建议创建综合分析页面

## [2026-05-09] fix | 批量修复 missing-summary
- 为 34 个页面添加了 50-100 字摘要段落（概念 20 + 实体 5 + 来源 9）
- 验证通过：check-missing-summary.sh 返回 ALL_OK

## [2025-07-10] ingest | 批量摄入 Java/前端/OAuth 学习笔记（58 个文件）

### 处理重命名（hash 验证 + status.json 更新，无需创建 wiki 页面）
- AI 目录重命名（`Ai/` → `AI/`）：批量添加 74 条新路径到 status.json，指向原有 [[sources/AI编程工具研究]]
- 英语 001 路径迁移（`英语/新概念英语/第一册/001.md` → `英语/001.md`）：hash 验证一致，添加新路径映射
- 黑客路线路径迁移（`学习路线/从零基础...` → `编程学习/从零基础...`）：hash 验证一致，添加新路径映射

### 创建新 wiki 页面
- 创建了 [[sources/Java-SE基础学习]]
- 新增 [[concepts/Java-SE]]
- 新增 [[concepts/Java-IO流]]
- 创建了 [[sources/Maven构建工具]]
- 新增 [[concepts/Maven]]
- 创建了 [[sources/Java日志框架]]
- 新增 [[concepts/Java日志框架]]
- 创建了 [[sources/JDBC数据库访问]]
- 新增 [[concepts/JDBC]]
- 新增 [[concepts/数据库连接池]]
- 创建了 [[sources/HTML基础学习]]
- 新增 [[concepts/HTML]]
- 创建了 [[sources/React前端框架]]（占位，笔记内容待完善）
- 新增 [[concepts/React]]（占位）
- 创建了 [[sources/RFC6749-OAuth2授权框架翻译]]（RFC 6749 中文全文翻译）
- 更新了 index.md 索引（新增 8 条来源、9 条概念）

## [2025-07-10] lint | Wiki 健康检查
- 发现 5 个问题（1 个 warning，2 个 info，1 个 warning 修复，1 个 info 修复）
- [broken-link/warning] .review-queue.md 模板注释中含伪链接（false positive，不修复）
- [orphan/info] Harness架构层次图.excalidraw 预存在孤立（已知）
- [orphan/info] overview.md 无入链（符合预期）
- [self-ref-sources/warning] 8 个 source 页面 frontmatter 中有自引用 sources 字段 → **已修复**
- [missing-source-ref/info] OAuth2授权框架缺少 RFC6749 来源引用 → **已修复**
- [suggestion/info] synthesis/ 目录为空，建议创建 Java 技术栈综合页

