---
title: Windows 开发环境
date: 2026-05-08
type: note
tags: [windows, 开发环境]
related_concepts: []
---

聚焦 Windows 平台开发环境搭建，核心内容为 WSL 2 和 CMD 命令速查两部分。WSL 2 部分详解基于 Hyper-V 轻量虚拟机的架构原理、多发行版管理、文件系统互访（/mnt/c/ 与 \\wsl$）、NAT 与镜像网络模式、.wslconfig 和 wsl.conf 配置，以及 VS Code Remote-WSL 与 Docker Desktop 的集成方案。CMD 部分按八大类别整理内置命令速查，覆盖文件操作到系统修复的常用场景。

## 核心要点

- WSL 2（Windows Subsystem for Linux）在 Windows 上直接运行真正的 Linux 内核，无需虚拟机或双系统
- CMD 内置命令覆盖文件/网络/进程/注册表等八大类别，是 Windows 系统管理的基础工具
- WSL 2 架构基于 Hyper-V 轻量虚拟机，接近 100% Linux 兼容，原生支持 Docker
- 文件系统互访：WSL 通过 `/mnt/c/` 访问 Windows，Windows 通过 `\\wsl$` 访问 WSL

## 详细摘要

### WSL 2 使用指南

WSL 解决了在 Windows 上搭建原生 Linux 开发环境的痛点。相比 WSL 1 的系统调用翻译层，WSL 2 使用真正的 Linux 内核（Hyper-V 轻量虚拟机），兼容性接近 100%，原生支持 Docker。

安装：`wsl --install` 一键完成（启用 WSL 功能 + 虚拟机平台 + 下载内核 + 安装 Ubuntu）。支持多发行版并行（Ubuntu、Debian、Arch、Kali 等），通过 `wsl --list --verbose` 查看已安装发行版。

发行版生命周期管理：安装 → 启动/停止 → 更新/升级 → 导出备份 → 导入恢复 → 迁移磁盘 → 注销卸载。导入后默认用户为 root，需手动恢复。

文件系统互访：WSL 通过 `/mnt/c/` 访问 Windows 驱动器（性能陷阱：大量文件 I/O 操作应放在 Linux 文件系统内），Windows 通过 `\\wsl$` 路径访问 WSL 文件系统。

网络配置：默认 NAT 模式（WSL 实例在虚拟网络中，通过 localhost 转发），Windows 11 22H2+ 支持镜像网络模式（WSL 直接使用 Windows 网络栈）。代理配置需获取宿主机 IP。

配置文件：`.wslconfig`（全局，Windows 用户目录）控制内存/处理器/swap/网络模式；`wsl.conf`（单发行版，`/etc/wsl.conf`）控制 systemd/挂载/默认用户。systemd 支持后可使用 systemctl 管理服务。

开发环境集成：Windows Terminal 自动检测 WSL 发行版、VS Code Remote-WSL 扩展实现无缝远程开发、Docker Desktop 原生支持 WSL 2 后端、独立的 Git 和 SSH 密钥配置。

### DOS 命令速查手册

CMD 内置命令按功能分为八大类别：

- **文件操作**：copy/move/del/ren/type/xcopy/robocopy/fc/attrib
- **目录操作**：dir/cd/md/rd/tree/pushd/popd
- **网络命令**：ping/ipconfig/netstat/tracert/nslookup/net/arp/route/pathping
- **进程与服务**：tasklist/taskkill/sc/net start/stop/wmic process
- **注册表操作**：reg query/add/delete/export/import
- **系统信息**：systeminfo/ver/date/time/set/where/whoami/hostname/wmic
- **用户与权限**：net user/localgroup/icacls/cacls/runas
- **批处理基础**：@echo off/echo/rem/set/if/for/goto/call/pause/%ERRORLEVEL%
- **输入输出重定向**：>/> >/2>/2>&1/</|
- **文本过滤**：find/findstr/sort/more
- **文件安全**：cipher/compact/takeown/certutil
- **磁盘与系统修复**：chkdsk/sfc/DISM/diskpart/format/fsutil

关键差异：robocopy 支持断点续传和镜像同步，比 xcopy 更鲁棒；`wmic` 在 Windows 11 22H2+ 已弃用，推荐改用 PowerShell；sfc + DISM 组合修复系统文件损坏。

## 引用的实体与概念

- 相关工具：WSL 2、PowerShell、Hyper-V、Windows Terminal、Docker Desktop
- 相关概念：CMD 命令行、Linux 子系统、虚拟化

## 与现有知识的关联

- WSL 2 是 [[sources/Docker容器化]] 中 Docker Desktop 运行的底层平台
- Windows 上的 Git 配置与 [[sources/Git版本控制]] 的 SSH 密钥和凭据管理相关
- CMD 批处理脚本是 Windows 自动化运维的基础工具
