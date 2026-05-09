---
title: Docker 容器化
tags: [docker, 容器化, DevOps]
sources: [[sources/Docker容器化]]
---

Docker 容器化是基于 Linux 内核 cgroup 和 namespace 机制的轻量级虚拟化技术，将应用及其依赖打包为标准化容器运行。其分层镜像架构带来空间效率和构建加速优势，配合 Docker Compose 实现多服务编排，通过 CI/CD 集成实现自动化构建部署，是企业级 DevOps 的核心基础设施。

## 定义

Docker 容器化是一种轻量级虚拟化技术，通过 Linux 内核的 cgroup 和 namespace 机制，将应用及其全部依赖打包到标准化的容器中运行。与虚拟机不同，容器共享宿主机内核，以进程级隔离替代硬件级隔离，实现秒级启动、MB 级镜像和接近原生的运行性能。

## 核心架构

Docker 采用 client-server 架构，通过 REST API 通信。调用链为：`docker CLI` → `Docker Daemon (dockerd)` → `containerd`（容器运行时管理器） → `runc`（OCI 标准底层运行时） → 容器进程。这个分层设计使得排错时可快速定位问题层级。

### 镜像分层原理

Docker 镜像由多个只读层叠加而成，每层只记录与上一层的差异。容器运行时在镜像顶部添加一个可写层（Container Layer）。联合文件系统（Union File System，如 OverlayFS）将所有层合并为统一视图。

分层存储带来三个关键优势：
- **空间效率**：多个镜像共享相同底层，节省磁盘空间
- **构建加速**：未变化的层直接复用，构建缓存利用分层机制
- **分发优化**：只需传输变化的层，加快镜像拉取速度

### 容器 vs 虚拟机

| 对比维度 | Docker 容器 | 虚拟机 |
|---------|------------|--------|
| 隔离级别 | 进程级（共享宿主内核） | 硬件级（独立内核） |
| 启动速度 | 秒级 | 分钟级 |
| 镜像大小 | MB 级 | GB 级 |
| 资源开销 | 接近原生 | 有虚拟化损耗 |
| 安全隔离 | 较弱（需注意逃逸风险） | 较强 |

## 三大核心对象

### 镜像（Image）

只读模板，包含运行应用所需的代码、运行时、库、环境变量和配置文件。通过 Dockerfile 定义构建步骤，每条指令创建一个镜像层。支持多阶段构建（构建阶段 + 运行阶段），显著减小最终镜像体积。

### 容器（Container）

镜像的运行实例。类似面向对象编程中「类」与「对象」的关系。容器在镜像只读层之上增加可写层，所有写操作发生在这一层。容器删除后写层数据消失（除非使用 Volume 持久化）。

### 仓库（Registry）

存储和分发镜像的服务。官方公共仓库为 Docker Hub，企业可自建私有仓库（如 Harbor）。镜像标签（tag）用于标识版本，推荐使用精确版本号而非 `latest`。

## Docker Compose 编排

当应用需要同时运行多个服务（数据库、缓存、应用服务器等）时，Docker Compose 通过一个 YAML 文件统一配置和启动。

核心能力：
- **服务定义**：指定镜像/构建方式、端口映射、环境变量、卷挂载、依赖关系
- **健康检查**：`depends_on` + `healthcheck` 实现服务就绪等待
- **多环境配置**：文件叠加（`-f docker-compose.yml -f docker-compose.prod.yml`）和 `.env` 变量注入
- **Watch 模式**：监听文件变更自动 sync/rebuild，精确控制每种文件类型的处理方式
- **Profiles**：按环境选择性启动服务（如调试工具、监控组件）

## CI/CD 集成

将 Docker 镜像构建、安全扫描、推送集成到 CI/CD 流水线，实现代码合并时自动构建、扫描漏洞、推送部署。

### GitHub Actions 模式

使用 `docker/build-push-action` 构建多架构镜像（amd64 + arm64），集成 Trivy 安全扫描（SARIF 格式报告上传 GitHub Security），支持 Docker Hub/GHCR/私有 Harbor 推送，构建缓存利用 GitHub Actions Cache（`type=gha`）。

### Jenkins 模式

声明式流水线（Jenkinsfile）：检出 → 构建镜像 → Trivy 安全扫描 → 推送到 Harbor → SSH 部署到测试环境。构建后清理本地镜像节省磁盘。

### 构建优化

将变化频率低的层（依赖文件）放在前面，变化频繁的层（源码）放在后面，充分利用构建缓存。

## 企业级实践

### 私有仓库 Harbor

Harbor（VMware 开源，CNCF 毕业）在 Docker Registry 基础上增加 RBAC 权限管理、Trivy 漏洞扫描集成、Notary 镜像签名、跨仓库镜像复制、Webhook 事件通知。

### 安全扫描

Trivy（CNCF 项目）扫描 OS 包、语言依赖、IaC 配置和 Secret 泄露。CI 中设置漏洞阈值（`--exit-code 1 --severity CRITICAL`），发现高危漏洞时阻断流水线。

### Docker Swarm 编排

Docker 官方内置的容器编排工具，将多台 Docker 主机组成集群。核心概念：Node（Manager/Worker）、Service、Stack、Overlay Network。支持滚动更新、自动回滚、节点标签调度、Secret/Config 管理。高可用建议：3 或 5 个 Manager 节点。

## 生产环境关键实践

- **镜像安全**：多阶段构建 + 最小化基础镜像（alpine/slim/distroless）+ 精确版本标签 + 非 root 用户 + Trivy 扫描
- **运行时安全**：`cap_drop: ALL` + `no-new-privileges` + 只读根文件系统 + Secret 管理替代环境变量明文
- **稳定性**：CPU/内存限制 + HEALTHCHECK 健康检查 + `restart: unless-stopped` + 日志轮转（`max-size`/`max-file`）
- **网络**：自定义 bridge 网络 + 端口绑定指定接口（`127.0.0.1`）+ HTTPS

## 与其他概念的关系

- [[concepts/Git版本控制]]：Git 管理代码版本，Docker 管理运行环境，两者通过 CI/CD 流水线紧密集成
- [[concepts/网络安全]]：Docker 容器安全是网络安全的重要组成部分，涉及镜像漏洞扫描、网络隔离、Secret 管理
- [[concepts/OAuth2授权框架]]：OAuth2 保护的微服务可容器化部署，Spring Authorization Server 可运行在 Docker 中
