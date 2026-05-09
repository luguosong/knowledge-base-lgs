---
title: Java SE
tags: [Java, JVM, 编程语言]
sources: [[sources/Java-SE基础学习]]
---

Java SE（Standard Edition）是 Java 平台的核心标准版，提供了编写桌面与服务端程序所需的完整 API。其核心理念是「一次编写，到处运行」，字节码在 JVM 上跨平台执行，是整个 Java 生态（Spring、Android 等）的基础。

## 定义

Java SE 是 Oracle 维护的 Java 标准版，包含语言规范、JVM 规范和核心类库（`java.lang`、`java.util`、`java.io` 等）。与 JavaEE（企业级）、JavaME（嵌入式）共同构成 Java 平台三大体系。

## 关键要点

- **版本演进**：JDK 8（Lambda/Stream）→ JDK 11 → JDK 17（密封类）→ JDK 21（虚拟线程）LTS；每 6 个月一个小版本
- **执行原理**：`.java` → 编译 → `.class` 字节码 → JVM 加载/链接/初始化 → JIT 本机代码
- **JDK vs JRE**：JDK 含编译器等开发工具；JRE 仅运行时；JDK 11+ 建议直接安装 JDK
- **核心 API 分层**：
  - 基础：`java.lang`（Object、String、Thread）
  - 集合：`java.util`（List、Map、Set）
  - IO：`java.io` + `java.nio`（字节流/字符流/文件操作）
  - 并发：`java.util.concurrent`
  - 网络：`java.net`
- **LTS 策略**：推荐生产环境使用 LTS 版本（8/11/17/21/25）；Oracle 对 JDK 21 支持至 2031 年 9 月

## 与其他概念的关系

- [[concepts/Java-IO流]]：Java SE 内置 IO 体系，字节流与字符流双分支
- [[concepts/JDBC]]：Java SE 标准库的数据库访问 API
- [[concepts/Java日志框架]]：基于 Java SE 运行时的日志体系
- [[concepts/Maven]]：Java SE 项目的标准构建工具
