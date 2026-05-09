---
title: Spring Framework
type: project
tags: [Spring, Java, 框架, IoC, AOP]
sources: [[sources/设计模式与面向对象]]
---

## 概述

Spring 是 Java 企业级应用开发领域最主流的框架，由 Rod Johnson 于 2003 年首次发布。其核心设计理念是简化企业级开发，通过 IoC（控制反转）容器管理对象生命周期和依赖关系，通过 AOP（面向切面编程）处理横切关注点。Spring 是 Java 生态中设计模式应用密度最高的框架之一——几乎所有核心模块都能找到经典模式的影子。

## 关键信息

### 核心模块

- **IoC 容器**：`BeanFactory` / `ApplicationContext` 负责创建、装配、管理 Bean 的完整生命周期，是 Spring 的基石
- **AOP**：通过动态代理（JDK 代理或 CGLIB）在目标方法前后织入横切逻辑（事务、日志、权限检查）
- **Spring MVC**：基于 `DispatcherServlet` 的 Web MVC 框架，通过 `HandlerMapping` → `HandlerAdapter` → `Controller` 链路处理请求
- **Spring Cache**：统一缓存抽象层，支持 Redis、Caffeine 等多种缓存实现的透明切换
- **事务管理**：声明式事务（`@Transactional`）基于 AOP 代理实现，编程式事务通过 `TransactionTemplate` 回调

### 设计哲学

- **约定优于配置**：合理的默认值减少配置量
- **面向接口编程**：核心 API 全部面向接口设计（`BeanFactory`、`CacheManager`、`HandlerAdapter`）
- **一站式框架**：覆盖 Web、数据访问、安全、消息等企业级开发的方方面面

## 与设计模式的关系

Spring 中使用了至少 11 种经典设计模式，这些模式不是刻意堆砌，而是在解决具体工程问题时自然涌现的：

| 模式 | Spring 中的典型应用 | 解决的问题 |
|------|-------------------|-----------|
| 工厂 | `BeanFactory` / `ApplicationContext` | 根据配置创建 Bean，调用方不感知创建细节 |
| 单例 | Bean 默认 singleton 作用域 | IoC 容器管理对象唯一性，比手写单例更优雅 |
| 代理 | Spring AOP（JDK 代理 / CGLIB） | 在目标方法前后织入事务、日志等横切逻辑 |
| 策略 | `DefaultAopProxyFactory` 选择代理方式 | 根据目标类是否有接口动态选择 JDK 或 CGLIB 代理 |
| 适配器 | `HandlerAdapter` 统一 Controller 接口 | 三种不同 Controller 定义方式对外统一调用 |
| 观察者 | `ApplicationEvent` + `@EventListener` | 事件驱动的业务解耦，发布者不感知监听者 |
| 模板方法 | `JdbcTemplate` / `RedisTemplate` | 固化重复流程，通过回调注入变化的业务逻辑 |
| 装饰器 | `TransactionAwareCacheDecorator` | 缓存写入延迟到事务提交后，避免脏数据 |
| 组合 | `CompositeCacheManager` | 多级缓存（Redis + Caffeine）的统一管理 |
| 职责链 | `HandlerExecutionChain` 拦截器链 | 请求到达 Controller 前后依次执行鉴权、日志等 |
| 解释器 | SpEL 表达式语言 | 解析 `@Cacheable(key="#userId")` 等注解中的表达式 |

### 关键洞察

- Spring 的 `xxxTemplate` 类（`JdbcTemplate`、`RedisTemplate`）使用回调而非继承实现模板思想——调用方通过 lambda 注入逻辑，符合好莱坞原则
- Spring Bean 的单例由容器管理，Bean 本身是普通 POJO，不需要手写 `getInstance()`，更易于测试和依赖注入
- Spring AOP 同时运用了策略模式（选择代理方式）、代理模式（创建代理对象）、职责链模式（多个 Advisor 排列），是多种模式协同的典型案例

## 相关实体与概念

- [[设计模式]]：Spring 是设计模式在工业界最密集的应用案例之一
- [[SOLID原则]]：Spring IoC 容器是 DIP（依赖倒置原则）的直接工程实现
