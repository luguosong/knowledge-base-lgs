---
title: Java IO 流
tags: [Java, IO, NIO, 文件操作]
sources: [[sources/Java-SE基础学习]]
---

Java IO 流体系是 Java SE 提供的输入/输出抽象，分为字节流和字符流两大分支，采用装饰者模式实现功能组合。JDK 7 引入的 `java.nio.file` 包（NIO.2）提供了现代文件操作 API，大幅简化了目录遍历、文件复制等操作。

## 定义

Java IO 流（`java.io`）是一套基于流（Stream）概念的输入/输出 API，将数据的读写抽象为"水流"模型。`java.nio.file` 是 JDK 7 引入的新一代文件系统 API，提供 `Path`、`Files` 等工具类。

## 关键要点

### 字节流（处理二进制数据）

```
InputStream（抽象基类）
├── FileInputStream      ← 读取文件字节
├── BufferedInputStream  ← 装饰器：加缓冲，减少系统调用
└── DataInputStream      ← 装饰器：读取基本类型

OutputStream（抽象基类）
├── FileOutputStream
├── BufferedOutputStream
└── DataOutputStream
```

### 字符流（处理文本数据，处理编码）

```
Reader（抽象基类）
├── InputStreamReader   ← 字节到字符的桥接器（指定编码）
└── BufferedReader      ← 加缓冲，提供 readLine()

Writer（抽象基类）
├── OutputStreamWriter
└── PrintWriter         ← 便利方法 print()/println()
```

### 文件操作 API 对比

| 特性 | `java.io.File` | `java.nio.file` (NIO.2) |
|------|----------------|--------------------------|
| JDK 版本 | 1.0 | 7+ |
| 错误处理 | 返回 boolean | 抛出 IOException |
| 目录遍历 | `listFiles()` | `Files.walk()` / `Files.find()` |
| 读取文件 | 需要流包装 | `Files.readAllBytes()` / `Files.readString()` |
| 监听变化 | 不支持 | `WatchService` |
| Stream 集成 | 无 | `Files.lines()` 返回 `Stream<String>` |

### NIO.2 核心类

- **`Path`**：表示文件系统路径，不绑定文件是否存在
- **`Paths.get()`** / **`Path.of()`**：创建 Path 实例
- **`Files`**：工具类，提供复制/移动/读写/属性查询等静态方法
- **`WatchService`**：监听目录文件变化，实现热加载等场景

## 与其他概念的关系

- [[concepts/Java-SE]]：IO 流是 Java SE 核心 API 的重要组成部分
- [[concepts/JDBC]]：JDBC 底层通过 IO 流与数据库驱动通信
