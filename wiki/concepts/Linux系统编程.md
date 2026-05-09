---
title: Linux 系统编程
tags: [linux, 系统编程, 系统调用, 进程, 线程, IPC, socket, epoll]
sources: [[sources/Linux系统学习]]
---

Linux 系统编程通过内核系统调用直接利用底层资源进行程序开发，涵盖文件 I/O、进程控制、线程同步（pthread）、进程间通信（IPC）、信号处理和 Socket 网络编程。其中 epoll I/O 多路复用是 Nginx、Redis 等高性能网络服务的核心基础，是理解操作系统原理和开发高性能服务的关键能力。

## 定义

Linux 系统编程是指通过操作系统内核提供的接口（系统调用），直接利用底层资源进行程序开发。与上层应用编程不同，系统编程关注进程管理、内存操作、文件 I/O、进程间通信和网络通信等内核级能力，是理解操作系统工作原理和开发高性能服务的基础。

## 关键要点

### 系统调用

系统调用是用户程序请求内核服务的唯一入口：

- **文件 I/O**：`open()`、`read()`、`write()`、`close()`、`lseek()`
- **错误处理**：系统调用失败返回 -1，`errno` 记录错误码，`perror()` / `strerror()` 输出错误信息
- **用户态与内核态切换**：系统调用触发软中断（int 0x80 / syscall），从用户态切换到内核态执行
- 标准库函数（如 `fopen`/`fread`）是对系统调用的封装，增加了缓冲层

### 进程控制

- **fork()**：创建子进程，子进程获得父进程的完整拷贝（写时复制）
- **exec 族**：`execl`/`execlp`/`execv`/`execvp`，用新程序替换当前进程映像
- **wait()/waitpid()**：父进程回收子进程资源，获取退出状态
- **僵尸进程**：子进程结束但父进程未调用 wait()，残留 PCB 占用资源
- **孤儿进程**：父进程先于子进程结束，子进程被 init 进程收养
- **守护进程**（Daemon）：后台运行、脱离终端、会话组长，创建流程：fork → exit 父进程 → setsid → fork → exit → chdir("/") → 关闭描述符

### 线程编程（pthread）

- **创建与终止**：`pthread_create()`、`pthread_exit()`、`pthread_join()`
- **同步机制**：
  - 互斥锁（Mutex）：`pthread_mutex_lock/unlock`，保护临界区
  - 条件变量（Condition Variable）：`pthread_cond_wait/signal/broadcast`，线程间通知
  - 读写锁（RW Lock）：允许多读者并发，写者独占
- **线程 vs 进程**：线程共享地址空间（轻量），进程独立（安全但开销大）
- **线程安全**：可重入函数、线程局部存储（`__thread`）、避免全局状态竞争

### IPC（进程间通信）

| 方式 | 特点 | 适用场景 |
|------|------|---------|
| 管道（pipe） | 半双工、父子进程间、字节流 | 简单父子通信 |
| 命名管道（FIFO） | 可用于无亲缘关系进程 | 任意进程间通信 |
| 消息队列 | 消息格式化、按类型读取 | 结构化数据传递 |
| 共享内存 | 最快的 IPC 方式、需同步 | 大量数据共享 |
| 信号量 | 计数器、PV 操作 | 资源计数与同步 |

选择原则：小数据用管道/消息队列，大数据用共享内存，同步用信号量。

### 信号处理

- **常见信号**：SIGINT（Ctrl+C）、SIGTERM（终止）、SIGKILL（强杀，不可捕获）、SIGSEGV（段错误）、SIGCHLD（子进程状态变化）
- **处理方式**：默认处理、忽略（SIG_IGN）、自定义处理函数
- **API**：`signal()`（简单）、`sigaction()`（推荐，功能更完善）
- **信号屏蔽**：`sigprocmask()` 控制信号 delivery 时机
- **注意**：信号处理函数中只能调用异步安全函数

### Socket 网络编程

- **TCP 流程**：
  - 服务端：`socket()` → `bind()` → `listen()` → `accept()` → `recv()/send()` → `close()`
  - 客户端：`socket()` → `connect()` → `send()/recv()` → `close()`
- **UDP**：无连接，`sendto()`/`recvfrom()`，适用于实时性要求高、允许丢包的场景
- **地址转换**：`inet_pton()`（字符串 → 二进制）、`inet_ntop()`（二进制 → 字符串）
- **字节序**：`htons()`/`htonl()`（主机序 → 网络序）、`ntohs()`/`ntohl()`（网络序 → 主机序）
- **并发模型**：多进程（fork）、多线程（pthread）、I/O 多路复用（epoll）

### I/O 多路复用

| 模型 | 最大连接数 | 性能 | 触发方式 |
|------|-----------|------|---------|
| select | 1024（FD_SETSIZE） | O(n) 遍历 | 水平触发 |
| poll | 无限制 | O(n) 遍历 | 水平触发 |
| epoll | 无限制 | O(1) 事件驱动 | 水平/边缘触发 |

- **epoll** 是 Linux 高性能网络编程的核心：
  - `epoll_create()`：创建 epoll 实例
  - `epoll_ctl()`：注册/修改/删除监听的文件描述符
  - `epoll_wait()`：阻塞等待就绪事件
- **ET（边缘触发）** vs **LT（水平触发）**：ET 仅在状态变化时通知一次，需一次性读完数据；LT 持续通知直到处理完毕
- epoll 是 Nginx、Redis 等高性能网络服务的基础

## 与其他概念的关系

- [[concepts/Shell编程]]：Shell 命令是对系统调用的封装，理解系统编程能更好地理解 Shell 行为
- [[concepts/Linux网络服务]]：Nginx/Redis 等高性能网络服务基于 epoll 和 Socket 编程实现
- [[concepts/Linux文件系统]]：文件 I/O 系统调用直接操作文件系统，理解 inode 等概念有助于优化 I/O 性能
