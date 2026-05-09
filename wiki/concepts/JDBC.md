---
title: JDBC
tags: [Java, 数据库, SQL, API]
sources: [[sources/JDBC数据库访问]]
---

JDBC（Java Database Connectivity）是 Java SE 标准库（`java.sql`）提供的数据库访问 API，作为 Java 应用与各类关系型数据库（MySQL/PostgreSQL/Oracle 等）之间的统一抽象层，屏蔽底层驱动差异，让上层代码无需因切换数据库而重写。

## 定义

JDBC 是 Java 的数据库连接 API，通过驱动程序接口（JDBC Driver）连接各种关系型数据库。核心接口位于 `java.sql` 和 `javax.sql` 包中，由各数据库厂商提供驱动实现。

## 关键要点

- **核心接口链**：`DriverManager.getConnection()` → `Connection` → `PreparedStatement` → `executeQuery()` → `ResultSet`
- **PreparedStatement 优先**：预编译 SQL 防止 SQL 注入；参数用 `?` 占位；执行计划缓存，批量执行时性能显著优于 `Statement`
- **事务控制**：
  ```java
  conn.setAutoCommit(false);  // 开启事务
  // ... 执行 SQL ...
  conn.commit();              // 提交
  // catch 中：conn.rollback(); 回滚
  ```
- **资源关闭**：`ResultSet` → `Statement` → `Connection` 必须显式关闭，推荐 try-with-resources 语法
- **JDBC 4.0 自动发现**：SPI 机制自动加载 `META-INF/services/java.sql.Driver`，无需 `Class.forName()`
- **批处理**：`ps.addBatch()` 收集 SQL；`ps.executeBatch()` 批量提交；适合批量插入场景
- **生产实践**：不要直接用 `DriverManager`；使用 `DataSource`（连接池）获取连接

## 与其他概念的关系

- [[concepts/数据库连接池]]：生产环境通过连接池（HikariCP/Druid）管理 JDBC 连接
- [[concepts/Java-SE]]：JDBC 是 Java SE 标准库的核心组件
- [[concepts/Maven]]：数据库驱动 jar 通过 Maven `runtime` scope 引入
