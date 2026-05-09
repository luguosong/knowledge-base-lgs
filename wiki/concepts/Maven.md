---
title: Maven
tags: [Java, 构建工具, 依赖管理, DevOps]
sources: [[sources/Maven构建工具]]
---

Maven 是 Apache 基金会开发的 Java 项目构建与依赖管理工具，基于「约定优于配置」理念，通过 `pom.xml` 声明式地管理项目依赖、构建生命周期和插件配置，是 Java 生态中最广泛使用的构建工具之一。

## 定义

Maven 是一款项目管理工具，核心功能包括：依赖自动下载与版本管理、标准化项目目录结构、生命周期驱动的构建流程。通过坐标系统（groupId:artifactId:version）唯一标识每个 jar 包，从仓库体系中自动解析和下载依赖。

## 关键要点

- **坐标系统**：`groupId:artifactId:version` 三元组唯一定位 artifact（如 `org.springframework:spring-core:6.0.0`）
- **标准目录结构**：
  - `src/main/java`：主代码
  - `src/main/resources`：配置文件
  - `src/test/java`：测试代码
  - `target/`：构建输出
- **三层仓库**：本地缓存（`~/.m2/`）→ 私服（Nexus/Artifactory）→ 中央仓库（`repo.maven.apache.org`）
- **生命周期**：`default`（validate → compile → test → package → verify → install → deploy）
- **常用命令**：
  - `mvn clean compile` — 清理并编译
  - `mvn test` — 运行单元测试
  - `mvn package` — 打包为 jar/war
  - `mvn install` — 安装到本地仓库
  - `mvn deploy` — 发布到远程仓库
- **依赖冲突解决**：最近定义原则（依赖树中距离根节点最近的版本胜出）
- **版本管理**：`<dependencyManagement>` 在父 POM 中集中声明版本，子模块不再指定版本号

## 与其他概念的关系

- [[concepts/Java-SE]]：Maven 是 Java 项目的标准构建工具
- [[concepts/Java日志框架]]：日志框架（SLF4J/Logback）通过 Maven 依赖引入
- [[concepts/JDBC]]：数据库驱动通过 Maven `runtime` scope 引入
