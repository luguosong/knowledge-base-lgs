---
title: Linux 文件系统
tags: [linux, 文件系统, 存储, LVM, RAID]
sources: [[sources/Linux系统学习]]
---

## 定义

Linux 文件系统是操作系统用于组织、存储和检索磁盘数据的核心机制。它定义了文件在存储设备上的布局方式，包括目录层次结构（FHS）、元数据管理（inode/superblock）、以及具体的文件系统实现（ext4、XFS、Btrfs 等）。

## 关键要点

### FHS 目录结构

Linux 遵循 FHS（Filesystem Hierarchy Standard）标准，主要目录职责：

- `/` — 根目录，所有文件的起点
- `/boot` — 内核与启动引导文件
- `/etc` — 系统配置文件
- `/home` — 用户家目录
- `/var` — 可变数据（日志、缓存、邮件）
- `/usr` — 用户程序与库文件
- `/tmp` — 临时文件
- `/dev` — 设备文件（一切皆文件）
- `/proc` — 虚拟文件系统，内核与进程信息

### inode 与 superblock

- **inode**：每个文件对应一个 inode，存储文件元数据（权限、所有者、时间戳、数据块指针），不存储文件名
- **superblock**：记录文件系统整体信息（块大小、inode 总数、空闲块数等），是文件系统的"目录"
- 查看工具：`stat`、`df -i`、`dumpe2fs`
- 硬链接共享 inode，软链接（符号链接）拥有独立 inode

### 主流文件系统对比

| 文件系统 | 特点 | 适用场景 |
|---------|------|---------|
| ext4 | 成熟稳定，日志式，最大 16TB 单文件 | 通用服务器、桌面 |
| XFS | 高性能大文件处理，动态空间分配 | 大数据、媒体存储 |
| Btrfs | CoW、快照、子卷、数据校验、内置 RAID | 需要高级特性的场景 |

### LVM 逻辑卷管理

LVM（Logical Volume Manager）提供灵活的磁盘管理：

- **三层抽象**：PV（物理卷）→ VG（卷组）→ LV（逻辑卷）
- 核心优势：在线扩容、快照、跨磁盘卷组
- 常用命令：`pvcreate`、`vgcreate`、`lvcreate`、`lvextend`、`resize2fs`
- 与传统分区的区别：解耦了物理磁盘与逻辑空间

### RAID 磁盘阵列

| 级别 | 冗余 | 最少磁盘 | 特点 |
|------|------|---------|------|
| RAID 0 | 无 | 2 | 条带化，性能最优，无容错 |
| RAID 1 | 有 | 2 | 镜像，读性能提升，磁盘利用率 50% |
| RAID 5 | 有 | 3 | 条带+校验，兼顾性能与冗余 |
| RAID 6 | 有 | 4 | 双校验，允许两盘同时故障 |
| RAID 10 | 有 | 4 | RAID 1+0，高性能高可靠 |

- 软 RAID 配置工具：`mdadm`
- 硬 RAID 由 RAID 卡管理，性能更好但成本高

### 磁盘配额

- 限制用户或组对磁盘空间的使用：block 限额（空间）和 inode 限额（文件数）
- 实现方式：quota、quotaon/quotaoff、edquota、repquota
- 启用条件：分区挂载时添加 `usrquota`/`grpquota` 选项

## 与其他概念的关系

- [[concepts/Shell编程]]：Shell 脚本常用于自动化文件系统管理任务（批量备份、日志轮转、配额检查）
- [[concepts/Linux系统编程]]：文件 I/O 系统调用（open/read/write）直接操作文件系统，epoll 可监控文件描述符事件
- [[concepts/Linux网络服务]]：NFS/Samba 等文件共享服务建立在文件系统之上
