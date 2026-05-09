---
title: Maven 构建工具
date: 2025-07-10
type: note
tags: [Java, Maven, 构建工具, 依赖管理]
related_concepts: [[concepts/Maven]]
---

Maven 是 Java 生态最流行的项目构建与依赖管理工具。本组学习笔记完整覆盖 Maven 核心主题：安装配置、POM 详解、生命周期与插件、依赖管理机制（传递依赖/版本冲突/排除）以及仓库体系（本地/中央/私服）与 Profile 多环境配置。内容为系统性实践笔记，适合从零学习或深入理解 Maven 工作原理。

## 核心要点

- **核心理念**：约定优于配置（标准目录结构 `src/main/java`、`src/test/java`）；声明式依赖（在 POM 中声明，Maven 自动下载）
- **POM 文件**：`pom.xml` 是项目对象模型，定义坐标（groupId/artifactId/version）、依赖、插件、构建配置
- **仓库体系**：本地仓库（`~/.m2/repository`）→ 私服（Nexus/Artifactory）→ 中央仓库（Maven Central）三层查找
- **生命周期**：三套独立生命周期：default（`compile` → `test` → `package` → `install` → `deploy`）、clean、site
- **插件机制**：每个生命周期阶段绑定插件 Goal；常用插件：`maven-compiler-plugin`、`maven-surefire-plugin`、`spring-boot-maven-plugin`
- **依赖管理**：传递依赖自动引入；冲突解决遵循「最近定义原则」；`<dependencyManagement>` 统一管理版本
- **Profile**：支持按环境（dev/test/prod）切换配置，`mvn package -P prod` 激活指定 Profile

## 详细摘要

### 为什么需要 Maven？

无构建工具时，开发者需手动下载 jar 包、处理版本冲突、自定义构建脚本。Maven 解决了：版本冲突（传递依赖树管理）、目录不统一（约定标准结构）、构建不可重复（声明式 POM）。

### POM 关键配置项

| 元素 | 说明 |
|------|------|
| `<groupId>` | 组织/项目标识，如 `org.springframework` |
| `<artifactId>` | 模块名 |
| `<version>` | 版本号，`-SNAPSHOT` 表示开发中 |
| `<packaging>` | `jar`（默认）/ `war` / `pom` |
| `<dependencies>` | 依赖声明 |
| `<build><plugins>` | 插件配置 |
| `<parent>` | 继承父 POM（如 Spring Boot Parent） |

### 依赖范围（scope）

| scope | 编译 | 测试 | 运行 | 说明 |
|-------|------|------|------|------|
| compile（默认）| ✓ | ✓ | ✓ | 全阶段可用 |
| test | ✗ | ✓ | ✗ | 仅测试 |
| provided | ✓ | ✓ | ✗ | 容器提供（如 Servlet API） |
| runtime | ✗ | ✓ | ✓ | 仅运行时（如 JDBC 驱动） |

## 与现有知识的关联

- [[concepts/Maven]]：本资料是 Maven 概念页的主要来源
- [[concepts/Java-SE]]：Maven 是 Java SE 项目的标准构建工具
