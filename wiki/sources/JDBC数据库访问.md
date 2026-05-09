---
title: JDBC 数据库访问
date: 2025-07-10
type: note
tags: [Java, JDBC, 数据库, 连接池, SQL]
related_concepts: [[concepts/JDBC]], [[concepts/数据库连接池]]
---

JDBC（Java Database Connectivity）学习笔记，完整覆盖 Java 数据库访问技术栈：核心接口（DriverManager/Connection/Statement/PreparedStatement/ResultSet）、事务管理、连接池（DataSource）、批处理、存储过程、CLOB 大对象、数据库元数据、异常处理以及最佳实践。共 13 个主题文件，适合全面掌握 JDBC 编程。

## 核心要点

- **JDBC 定位**：Java 应用与数据库之间的标准抽象层，屏蔽 MySQL/PostgreSQL/Oracle 等不同数据库的实现差异
- **核心接口**：`DriverManager`（获取连接）→ `Connection`（代表一次连接）→ `Statement`/`PreparedStatement`（执行 SQL）→ `ResultSet`（读取结果）
- **PreparedStatement**：预编译 SQL，防止 SQL 注入；参数用 `?` 占位；性能优于 `Statement`（执行计划可复用）
- **事务管理**：`connection.setAutoCommit(false)` 开启手动事务；`commit()` 提交；`rollback()` 回滚；需 try-catch 保证 rollback
- **连接池**：生产环境必须使用连接池（HikariCP/Druid/DBCP2），避免频繁创建/销毁连接开销；通过 `DataSource` 接口抽象
- **批处理**：`addBatch()` + `executeBatch()` 批量插入，性能远超逐条执行
- **CLOB 大对象**：`setClob()`/`getClob()` 处理大文本（超过 4KB 的文本字段）；BLOB 处理二进制大对象
- **存储过程**：`CallableStatement` 调用数据库存储过程，支持 IN/OUT/INOUT 参数
- **异常处理**：`SQLException` 包含 SQLState 和 ErrorCode；始终在 finally 中关闭连接（或用 try-with-resources）

## 详细摘要

### 典型 JDBC 代码骨架

```java
// 推荐：try-with-resources 自动关闭
try (Connection conn = dataSource.getConnection();
     PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE id = ?")) {
    ps.setInt(1, userId);
    try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            System.out.println(rs.getString("name"));
        }
    }
}
```

### 驱动加载演进

| 时代 | 方式 | 说明 |
|------|------|------|
| JDBC 1.0 | `DriverManager.registerDriver(new Driver())` | 显式注册，强依赖具体实现 |
| JDBC 2.0 | `Class.forName("com.mysql.cj.jdbc.Driver")` | 反射加载，减少耦合 |
| JDBC 4.0+ | 自动（SPI 机制） | jar 中 `META-INF/services/java.sql.Driver` 自动发现 |

### 主流连接池对比

| 连接池 | 特点 | 推荐场景 |
|--------|------|---------|
| HikariCP | 速度最快，代码轻量 | Spring Boot 默认，**首选** |
| Druid | 功能丰富（SQL 监控、慢查询）| 国内企业常用，需要监控时 |
| DBCP2 | Apache 出品，成熟稳定 | 遗留系统兼容 |

### ResultSet 游标操作

- `rs.next()` — 向下移动一行，返回 false 表示结束
- `rs.getString("列名")` / `rs.getInt(列索引)` — 读取数据
- `rs.getMetaData()` — 获取结果集元数据（列数、列名、类型）

## 与现有知识的关联

- [[concepts/JDBC]]：本资料是 JDBC 概念页的主要来源
- [[concepts/数据库连接池]]：连接池是 JDBC 生产使用的核心优化
- [[concepts/Java-SE]]：JDBC 是 Java SE 标准库（`java.sql`）的一部分
- [[concepts/Maven]]：JDBC 驱动通过 Maven `runtime` scope 引入
