---
title: Docker 容器化
date: 2026-05-08
type: note
tags: [docker, 容器化, DevOps]
related_concepts: [[concepts/Docker容器化]]
---

全面覆盖 Docker 容器化技术栈，从架构原理（client-server 模型、分层存储、Union File System）到生产实践（多阶段构建、安全扫描、资源限制）。内容包含核心三对象操作、Dockerfile 编写规范、Compose 多容器编排、Harbor 私有仓库部署、Trivy 镜像安全扫描，以及 GitHub Actions 和 Jenkins 的 CI/CD 流水线集成，形成从开发到生产的完整知识链路。

## 核心要点

- Docker 采用 client-server 架构（CLI → Daemon → containerd → runc），通过 REST API 通信
- 镜像采用分层存储（只读层 + 可写层），Union File System（如 OverlayFS）合并为统一视图
- 核心三对象：镜像（只读模板）、容器（运行实例）、仓库（镜像分发）
- Docker Compose 实现多容器编排，一条命令启动完整应用栈
- Harbor 是 CNCF 毕业的企业级私有镜像仓库，提供 RBAC、漏洞扫描、镜像复制
- CI/CD 集成：GitHub Actions 和 Jenkins 流水线中的镜像构建、扫描、推送自动化
- 生产实践：多阶段构建、非 root 用户、资源限制、日志轮转、健康检查

## 详细摘要

### 架构原理

Docker 解决了「在我电脑上跑得好好的」环境不一致问题。它把应用和依赖打包成标准化镜像，在任何支持 Docker 的机器上以相同方式运行。

架构调用链：`docker CLI` → `Docker Daemon (dockerd)` → `containerd` → `runc` → 容器进程。与虚拟机相比，容器是进程级隔离（共享宿主内核），启动秒级、镜像 MB 级，但安全隔离较弱。

镜像分层原理：每层只记录与上一层的差异，多个镜像可共享底层。联合文件系统（Union File System，如 OverlayFS）将所有层合并为统一视图。构建缓存利用分层机制——未变化的层直接复用。

### 核心操作

- **镜像操作**：`docker pull`/`push`、`docker build`、`docker images`、`docker rmi`
- **容器操作**：`docker run`（核心命令，支持 `-d`/`-p`/`-v`/`--name`/`-e` 等参数）、`docker exec`、`docker logs`、`docker stats`
- **数据持久化**：Volume（Docker 管理，推荐）和 Bind Mount（宿主机目录挂载，适合开发热更新）
- **网络**：bridge（默认）、host、自定义 bridge（同网络内容器可通过容器名互访）

### Dockerfile 编写

常用指令：`FROM`/`RUN`/`COPY`/`WORKDIR`/`ENV`/`EXPOSE`/`ENTRYPOINT`/`CMD`/`HEALTHCHECK`。推荐多阶段构建（构建阶段 + 运行阶段），减小最终镜像体积。

### Docker Compose 编排

通过 `docker-compose.yml` 定义多服务应用，支持依赖关系（`depends_on` + `healthcheck`）、环境变量注入（`.env` 文件）、多环境配置（文件叠加）、Watch 模式（文件变更自动同步/重建）、Profiles（按环境选择性启动服务）。

### 私有仓库 Harbor

Harbor（VMware 开源，CNCF 毕业）在 Docker Registry 基础上增加了 RBAC 权限管理、Trivy 漏洞扫描集成、Notary 镜像签名、跨仓库镜像复制、Webhook 事件通知、垃圾回收机制。通过 Docker Compose 部署，配置文件为 `harbor.yml`。

### 镜像安全扫描

主要工具：Trivy（CNCF 项目，扫描 OS 包/语言依赖/IaC/Secret）和 Docker Scout（Docker 官方内置）。CI 中可设置漏洞阈值，发现 CRITICAL 漏洞时以非零状态码退出。最佳实践：使用最小化基础镜像（alpine/slim/distroless）、多阶段构建、非 root 用户运行、SBOM 生成与 cosign 签名。

### CI/CD 流水线

- **GitHub Actions**：使用 `docker/build-push-action` 构建多架构镜像，集成 Trivy 安全扫描，支持 Docker Hub/GHCR/私有 Harbor 推送
- **Jenkins**：声明式流水线（检出 → 构建 → 扫描 → 推送 → 部署），支持自动部署到测试环境
- **构建优化**：将变化频率低的层放在前面、GitHub Actions 缓存（`cache-from/to: type=gha`）、Registry 缓存

### Docker Swarm

Docker 官方内置的容器编排工具，核心概念：Node（Manager/Worker）、Service、Task、Stack、Overlay Network。支持滚动更新、自动回滚、节点标签与调度约束、Secret/Config 管理。高可用建议：3 或 5 个 Manager 节点（奇数保证 Raft 多数派）。

### 生产环境 Checklist

- 多阶段构建 + 最小化基础镜像 + 精确版本标签
- 非 root 用户 + `cap_drop: ALL` + `no-new-privileges` + 只读根文件系统
- CPU/内存限制 + 健康检查 + 重启策略 + 日志轮转
- 自定义网络 + 端口绑定指定接口 + HTTPS

## 引用的实体与概念

- 相关工具：Docker Engine、Docker Compose、Harbor、Trivy、Docker Scout、Docker Swarm
- 相关平台：GitHub Actions、Jenkins、Docker Hub、GHCR

## 与现有知识的关联

- Docker 容器化与 [[concepts/Docker容器化]] 概念页对应，提供从原理到实践的完整视图
- Docker 网络和安全配置与 [[concepts/网络安全]] 的安全最佳实践相关
- Docker CI/CD 集成与 [[concepts/Git版本控制]] 的 Git 工作流紧密配合
