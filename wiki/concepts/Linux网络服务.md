---
title: Linux 网络服务
tags: [linux, 网络服务, nginx, ssh, dns, 邮件服务器]
sources: [[sources/Linux系统学习]]
---

Linux 网络服务涵盖在 Linux 系统上部署运行的各类网络应用，包括 OpenSSH 远程管理、Nginx/Apache Web 服务、BIND DNS 解析、Postfix+Dovecot 邮件服务、NFS/Samba 文件共享等。Linux 凭借稳定性和开源生态成为互联网服务器的主流操作系统，防火墙（iptables/firewalld）和诊断工具是运维必备能力。

## 定义

Linux 网络服务是指在 Linux 系统上部署和运行的各种网络应用服务，涵盖远程管理、Web 服务、域名解析、邮件收发、文件共享等。Linux 凭借其稳定性、安全性和开源生态，是互联网服务器的主流操作系统。

## 关键要点

### 网络基础

- **TCP/IP 四层模型**：链路层 → 网络层（IP）→ 传输层（TCP/UDP）→ 应用层
- **子网划分**：CIDR 表示法、子网掩码计算、网络地址与广播地址
- **防火墙**：
  - iptables/netfilter：基于规则的包过滤，四表五链
  - firewalld：CentOS 7+ 默认，zone 概念，动态管理
  - nftables：新一代防火墙框架，替代 iptables
- **NAT**：SNAT（源地址转换，内网上网）、DNAT（目标地址转换，端口映射）
- **诊断工具**：`ping`、`traceroute`、`ss/netstat`、`tcpdump`、`nslookup/dig`

### OpenSSH 远程管理

- **服务端**：sshd 配置（`/etc/ssh/sshd_config`）
- **认证方式**：密码认证、公钥认证（`ssh-keygen` / `ssh-copy-id`）
- **安全加固**：禁止 root 远程登录、修改默认端口、限制访问来源、使用 fail2ban
- **文件传输**：scp、sftp
- **端口转发**：本地转发（`-L`）、远程转发（`-R`）、动态转发（`-D`，SOCKS 代理）

### Web 服务器

**Nginx**：
- 高性能事件驱动架构，适合高并发场景
- 核心功能：虚拟主机、反向代理、负载均衡（round-robin/ip-hash/least-conn）
- HTTPS 配置：Let's Encrypt + certbot 自动证书
- 配置文件：`/etc/nginx/nginx.conf`、`/etc/nginx/conf.d/`

**Apache**（httpd）：
- 进程/线程模型：prefork / worker / event
- `.htaccess` 目录级配置
- 模块化架构：mod_ssl、mod_rewrite、mod_proxy
- 适用场景：需要复杂动态处理、.htaccess 分布式配置

### DNS 服务（BIND）

- BIND 是最广泛使用的开源 DNS 服务器
- **正向解析**：域名 → IP（A 记录）
- **反向解析**：IP → 域名（PTR 记录）
- **记录类型**：A、AAAA、CNAME、MX、NS、TXT、SOA
- **主从同步**：zone 传输（AXFR/IXFR），从服务器自动同步主服务器数据
- 配置文件：`/etc/named.conf`、zone 文件

### 邮件服务（Postfix + Dovecot）

- **Postfix**：SMTP 服务器，负责邮件发送与路由
- **Dovecot**：IMAP/POP3 服务器，负责邮件接收与用户邮箱访问
- SMTP 认证：SASL + TLS 加密
- 反垃圾邮件：SPF、DKIM、DMARC 配置

### 文件共享

**NFS**（Network File System）：
- Linux/Unix 间文件共享的标准方案
- 服务端：`/etc/exports` 配置共享目录和权限
- 客户端：`mount -t nfs` 挂载远程目录
- 适用场景：集群内共享存储

**Samba**（SMB/CIFS）：
- 跨平台文件共享（Windows ↔ Linux）
- 用户认证与权限映射
- 可配置为域控制器或成员服务器
- 适用场景：混合操作系统环境

### 其他服务

- **DHCP**（dhcpd）：自动分配 IP 地址，配置地址池、租约、保留地址
- **FTP**（vsftpd）：文件传输服务，被动模式配置、虚拟用户、TLS 加密
- **NTP/Chrony**：系统时间同步，确保集群服务器时间一致

## 与其他概念的关系

- [[concepts/Linux系统编程]]：网络服务的底层实现依赖 Socket 编程和 I/O 多路复用（epoll）
- [[concepts/Linux文件系统]]：NFS/Samba 文件共享服务直接建立在文件系统之上
- [[concepts/Shell编程]]：服务管理脚本、日志分析、配置自动化都依赖 Shell 编程能力
