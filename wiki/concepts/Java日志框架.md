---
title: Java 日志框架
tags: [Java, 日志, SLF4J, Logback, Log4j2]
sources: [[sources/Java日志框架]]
---

Java 日志框架体系分为「门面层」和「实现层」两级。门面层（SLF4J/JCL）提供统一 API，实现层（Logback/Log4j2/JUL）负责实际写入。业务代码只依赖门面，运行时通过绑定包切换具体实现，是门面模式在日志领域的典型应用。

## 定义

Java 日志框架是解决 `System.out.println()` 不足的工程化解决方案，提供：日志级别控制（TRACE/DEBUG/INFO/WARN/ERROR）、多输出目标（控制台/文件/远程）、异步写入、格式化、归档压缩等能力。门面模式使实现可替换。

## 关键要点

- **SLF4J**（Simple Logging Facade for Java）：最主流的门面，API：`Logger logger = LoggerFactory.getLogger(Clazz.class);` + `logger.info("msg {}", arg)`；`{}` 占位符比字符串拼接更高效
- **Logback**：SLF4J 的默认实现，Spring Boot Starter 自动引入，无需额外配置即可使用
- **Log4j2**：支持异步日志（基于 LMAX Disruptor），适合超高并发场景；Log4Shell（CVE-2021-44228）漏洞已在 2.15+ 修复
- **桥接包**：将其他框架（JUL/Log4j/JCL）的日志路由到 SLF4J，实现统一管理（`jul-to-slf4j`、`log4j-to-slf4j`）
- **配置文件**：Logback 使用 `logback.xml`；Log4j2 使用 `log4j2.xml` 或 `log4j2.yml`
- **Spring Boot 集成**：`spring-boot-starter-logging` 自动配置 Logback；通过 `application.yml` 的 `logging.*` 属性快速配置

## 与其他概念的关系

- [[concepts/Java-SE]]：日志框架在 Java SE 运行时之上构建
- [[concepts/Maven]]：通过 Maven 依赖管理引入日志框架
