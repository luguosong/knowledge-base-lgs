---
title: Java SE 基础学习
date: 2025-07-10
type: note
tags: [Java, Java-SE, IO流, 文件操作, JDK]
related_concepts: [[concepts/Java-SE]], [[concepts/Java-IO流]]
---

Java SE（Standard Edition）基础学习笔记，涵盖 Java 语言概述、JDK 与 JVM 原理、IO 流体系、文件操作 API（`java.io.File` 与 `java.nio.file`）以及 JDK 8/11/17/21/25/26 各 LTS 版本更新日志。内容来自系统性学习笔记，适合有一定编程基础的开发者深入理解 Java 核心机制。

## 核心要点

- Java 于 1995 年发布，核心理念「一次编写，到处运行」；字节码在 JVM 上跨平台运行
- 版本体系：JavaSE（桌面/服务端）、JavaEE（企业级）、JavaME（嵌入式）；每 6 个月发布新版，LTS 版本为 8/11/17/21/25
- IO 流体系：字节流（InputStream/OutputStream）与字符流（Reader/Writer）两大分支，装饰者模式层层包装
- 旧版文件 API：`java.io.File`（JDK 1.0）——功能有限，错误处理靠 boolean 返回值
- 新版文件 API：`java.nio.file`（Java 7+）——`Path` + `Files` 工具类，支持 Stream，异常报错更清晰
- `WatchService` 可监听目录文件变化，实现热更新等场景
- JDK 21 LTS 引入虚拟线程（Virtual Threads）、记录模式、switch 模式匹配，是当前推荐的 LTS 版本
- JDK 8 LTS 引入 Lambda、Stream API；JDK 11 LTS 移除 JavaFX；JDK 17 LTS 引入密封类

## 详细摘要

### Java 概述

Java 由 Sun Microsystems 的 Green 项目演化而来，1995 年正式发布。程序员编写 `.java` 源码 → 编译为 `.class` 字节码 → 由 JVM 加载/链接/初始化 → JIT 编译为本机指令。JDK 包含编译器等开发工具，JRE 仅包含运行时环境。

### IO 流体系

```
字节流
├── InputStream（抽象）
│   ├── FileInputStream
│   ├── BufferedInputStream（装饰器，加缓冲）
│   └── DataInputStream（装饰器，读基本类型）
└── OutputStream（抽象）
    └── ...

字符流
├── Reader（抽象）
│   ├── InputStreamReader（字节→字符的桥接器）
│   └── BufferedReader（加缓冲，提供 readLine()）
└── Writer（抽象）
```

### 文件操作演进

| 特性 | `java.io.File` | `java.nio.file` |
|------|----------------|------------------|
| JDK 版本 | 1.0 | 7+ |
| 错误处理 | 返回 boolean | 抛出异常 |
| 目录遍历 | `listFiles()` | `Files.walk()`/`Files.find()` |
| 复制/移动 | 需手动实现 | `Files.copy()`/`Files.move()` |
| 目录监听 | 无 | `WatchService` |

### JDK 更新日志要点

- **JDK 8**：Lambda、Stream、Optional、新日期时间 API（`java.time`）
- **JDK 11**：`String` 新方法（`strip()`、`isBlank()`），`Files.readString()`，HTTP 客户端 API
- **JDK 17**：密封类（`sealed`）、文本块（`"""`），随机数增强
- **JDK 21**：虚拟线程（`Thread.ofVirtual()`），记录模式，字符串模板预览
- **JDK 25**：量子安全算法支持，G1 GC 改进

## 与现有知识的关联

- 与 [[concepts/Java-SE]] 关联：本资料是 Java SE 概念页的主要来源
- 与 [[concepts/Java-IO流]] 关联：IO 流体系和文件操作是核心子主题
- 与 [[concepts/JDBC]] 相关：JDBC 建立在 Java IO/NIO 之上的数据库访问层
