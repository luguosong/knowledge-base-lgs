---
title: Java 日志框架
date: 2025-07-10
type: note
tags: [Java, 日志, SLF4J, Logback, Log4j2, Spring-Boot]
related_concepts: [[concepts/Java日志框架]]
---

Java 日志框架学习笔记，完整覆盖 Java 生态的六大日志组件：JUL（JDK 内置）、JCL（Commons Logging）、SLF4J（门面）、Log4j（经典，已停维护）、Log4j2（高性能实现）、Logback（Spring Boot 默认）以及 Spring Boot 的日志集成配置。内容阐明门面模式在日志领域的应用，帮助开发者理解日志框架的选型逻辑。

## 核心要点

- **门面模式**：业务代码只依赖 SLF4J/JCL 等日志门面 API，具体实现（Logback/Log4j2）可在不修改业务代码的情况下替换
- **SLF4J**：最主流的日志门面，通过绑定桥接包切换实现；提供 `{}` 占位符，避免字符串拼接性能损耗
- **Logback**：Spring Boot 默认日志实现（`spring-boot-starter` 自动引入）；由 Log4j 作者重写，性能更优
- **Log4j2**：Apache 维护的高性能实现，支持异步日志（LMAX Disruptor），适合高吞吐量场景
- **JUL**（`java.util.logging`）：JDK 内置，无需额外依赖，功能基础，不建议直接用于生产项目
- **Log4j**：经典框架，已于 2015 年停止维护，不建议新项目使用；Log4Shell 漏洞（CVE-2021-44228）存在于 Log4j2 的 JNDI 功能
- **Spring Boot 日志**：通过 `logging.level.*` 配置日志级别；`logging.file.name` 配置日志文件；支持 Logback XML 自定义

## 详细摘要

### 日志框架关系图

```
业务代码
    ↓ 调用
SLF4J（门面/接口层）
    ↓ 运行时绑定
Logback / Log4j2 / JUL（实现层）
```

### 框架对比

| 框架 | 类型 | 状态 | 推荐场景 |
|------|------|------|---------|
| JUL | 实现 | 维护中 | 仅学习/极简项目 |
| JCL | 门面 | 维护中 | 遗留项目兼容 |
| SLF4J | 门面 | 主流 | **所有新项目** |
| Log4j | 实现 | 停止维护 | 不建议使用 |
| Log4j2 | 实现 | 主流 | 高并发/高吞吐量 |
| Logback | 实现 | 主流 | Spring Boot 默认首选 |

### 日志级别（由低到高）

`TRACE` < `DEBUG` < `INFO` < `WARN` < `ERROR`

生产环境通常设置为 `INFO` 级别；开发调试时设置 `DEBUG`。

### Spring Boot 日志配置

```yaml
logging:
  level:
    root: INFO
    com.example: DEBUG
  file:
    name: app.log
```

## 与现有知识的关联

- [[concepts/Java日志框架]]：本资料是日志框架概念页的主要来源
- [[concepts/Java-SE]]：日志框架基于 Java SE 运行时环境
- [[concepts/Maven]]：日志框架通过 Maven 依赖引入
