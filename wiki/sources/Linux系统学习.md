---
title: Linux 系统学习
date: 2026-05-08
type: note
tags: [linux, 操作系统, 系统管理, 网络服务, 系统编程]
related_concepts: [[concepts/Linux文件系统]], [[concepts/Shell编程]], [[concepts/Linux网络服务]], [[concepts/Linux系统编程]]
---

## 核心要点

- 覆盖 **Debian**（Ubuntu/Debian）和 **Red Hat**（CentOS/RHEL/Fedora）两大发行版体系，包管理器分别对应 apt 和 yum/dnf
- 从基础操作到系统编程的 **完整知识链路**：文件系统 → Shell 编程 → 系统管理 → 网络服务 → 系统编程
- 兼顾 **理论**（OS 原理、TCP/IP 协议栈）和 **实战**（服务器部署、防火墙配置、LVM/RAID 管理）
- 涵盖 9 大子主题、共 58 个原始学习文件，构成系统化的 Linux 知识体系

## 子主题概览

### 基础篇（7 文件）

- Linux 发行版选择与安装（Debian vs Red Hat 体系对比）
- 文件权限模型：rwx 权限位、chown/chmod/chgrp、umask
- FHS（Filesystem Hierarchy Standard）目录结构规范
- 磁盘分区与挂载：fdisk/gdisk/parted、fstab 配置
- SSH 远程管理基础

### 存储篇（9 文件）

- 文件系统原理：ext4/XFS/Btrfs 特点与选型
- inode 与 superblock 机制
- LVM（Logical Volume Manager）逻辑卷管理：PV → VG → LV
- RAID 磁盘阵列：RAID 0/1/5/6/10 原理与 mdadm 配置
- 磁盘配额（quota）管理
- 数据备份策略：tar、rsync、dump/restore

### Shell 篇（7 文件）

- Bash 脚本语法：变量、条件、循环、函数
- 重定向与管道机制
- 正则表达式基础与扩展
- 文本处理三剑客：grep（过滤）、sed（流编辑）、awk（字段处理）
- Vim 编辑器：模式切换、常用操作、配置定制

### 账户权限（3 文件）

- 用户与组管理：useradd/usermod/userdel、groupadd
- sudo 提权与 /etc/sudoers 配置
- PAM（Pluggable Authentication Modules）认证框架
- ACL（Access Control List）精细化权限控制

### 系统管理（7 文件）

- 进程管理：ps/top/htop、信号（kill）、前台后台控制
- systemd 服务管理：unit 文件、systemctl、journalctl
- SELinux 安全上下文与策略管理
- 计划任务：crontab、at、anacron
- 系统日志：rsyslog、/var/log 目录结构、logrotate

### 软件安装（2 文件）

- 源码编译安装：./configure → make → make install
- 包管理器：apt（Debian 系）、yum/dnf（Red Hat 系）、仓库配置

### 网络基础（9 文件）

- TCP/IP 协议栈：四层模型、封装与解封装
- IP 地址与子网划分：CIDR、子网掩码计算
- 路由与网关配置
- 防火墙：iptables/netfilter、firewalld、nftables
- NAT（Network Address Translation）原理与配置
- 网络诊断工具：ping、traceroute、netstat/ss、tcpdump、nslookup/dig

### 服务器实战（13 文件）

- **OpenSSH**：sshd 配置、密钥认证、安全加固
- **DHCP**：dhcpd 配置、地址池管理
- **DNS**：BIND 安装配置、正向/反向解析、主从同步
- **Nginx**：虚拟主机、反向代理、负载均衡、HTTPS 配置
- **Apache**：httpd 配置、虚拟主机、模块管理
- **Postfix**：邮件服务器搭建、SMTP 认证、Dovecot 集成
- **FTP**：vsftpd 配置、被动模式、虚拟用户
- **NFS**：网络文件系统共享、exportfs 配置
- **Samba**：Windows/Linux 文件共享、SMB/CIFS 协议
- **NTP**：时间同步服务、chrony 配置

### 系统编程（9 文件）

- 系统调用接口：文件 I/O（open/read/write/close）、错误处理
- 进程控制：fork()、exec 族、wait()、僵尸进程
- 线程编程：pthread 创建/同步/互斥/条件变量
- IPC（进程间通信）：管道、命名管道、消息队列、共享内存、信号量
- 信号处理：signal()、sigaction()、常见信号类型
- Socket 网络编程：TCP/UDP socket、地址转换、连接管理
- I/O 多路复用：select/poll/epoll 模型对比与应用

## 与现有知识的关联

- 与 [[concepts/Linux文件系统]] 的关系：基础篇和存储篇的详细知识汇总于该概念页
- 与 [[concepts/Shell编程]] 的关系：Shell 篇的详细知识汇总于该概念页
- 与 [[concepts/Linux网络服务]] 的关系：网络基础和服务器实战的详细知识汇总于该概念页
- 与 [[concepts/Linux系统编程]] 的关系：系统编程篇的详细知识汇总于该概念页
