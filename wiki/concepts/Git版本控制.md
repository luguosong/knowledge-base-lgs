---
title: Git 版本控制
tags: [git, 版本控制, 分布式系统]
sources: [[sources/Git版本控制]]
---

Git 是由 Linus Torvalds 创建的分布式版本控制系统，采用快照存储模型，每个开发者持有完整仓库镜像，支持完全离线工作。其核心围绕工作目录、暂存区和本地仓库三个区域展开，分支创建代价极低。内部基于 blob、tree、commit、tag 四种对象构建，配合 Hooks 机制实现自动化质量管控。

## 定义

Git 是一个分布式版本控制系统（DVCS），由 Linus Torvalds 于 2005 年创建。与集中式 VCS（如 SVN）不同，Git 的核心设计采用快照存储模型——每次提交记录项目在某个时刻的完整快照，而非文件间的差异。每个开发者的本地仓库都是完整历史的镜像，支持完全离线工作。

## 分布式 vs 集中式

三种版本控制系统的演进：

1. **本地 VCS**：只在本机维护版本数据库，多人协作困难
2. **集中式 VCS**（CVS/SVN）：中央服务器存储所有历史，开发者只检出最新版本。致命缺陷是服务器宕机则全体停工
3. **分布式 VCS**（Git/Mercurial）：每人都有完整仓库镜像，即使服务器挂了也能继续提交后同步

### 快照 vs 差异

SVN 记录文件随时间积累的差异（delta）：`版本1 → 版本1+Δ1 → 版本1+Δ1+Δ2`。Git 记录完整快照，未变化的文件只存一个指向上一版本的链接。这使得分支切换是 O(1) 操作，任何版本可独立恢复。

## 三个区域与文件状态

Git 的核心工作模型围绕三个区域展开：

- **工作目录（Working Directory）**：实际编辑文件的地方
- **暂存区（Staging Area / Index）**：决定哪些修改纳入下次提交的「候车室」
- **本地仓库（Repository / .git）**：保存所有历史快照

文件在四种状态间流转：Untracked（未跟踪）→ Staged（已暂存）→ Unmodified（未修改）→ Modified（已修改）→ Staged。`git add` 的语义是「将内容精确放入下一次提交」，而非简单的「添加文件」。

## 分支策略

### 分支的本质

Git 分支本质上是一个指向某个提交的 40 字节 SHA 文件（引用），创建分支的代价几乎为零。HEAD 是特殊指针，始终指向当前所在的分支。

### 合并策略

| 合并方式 | 历史形状 | 何时使用 |
|---------|---------|---------|
| Fast-forward | 线性移动指针 | 目标分支无新提交 |
| 三方合并（3-way merge） | 产生合并提交，保留分叉历史 | 两个分支都有新提交 |
| squash merge | 一个干净的新提交 | 功能小且历史杂乱 |
| rebase 后 merge | 线性历史 | 个人工作流 |

### 常见工作流

- **GitHub Flow**：main 始终可部署，feature 分支 → PR → Code Review → merge。简单，适合持续部署
- **Git Flow**：main（生产）+ develop（开发主线）+ feature/release/hotfix 分支。结构化，适合版本发布
- **Trunk-Based Development**：只有主干，功能分支极短命（< 1天），未完成功能用 Feature Flag 隐藏。高频发布团队推荐

## 变基（rebase）与黄金法则

rebase 将功能分支的提交「移植」到主线最新提交之后，使历史变为线性。实际步骤：找共同祖先 → 暂存提交 → 移动起点 → 依次重新应用（生成新 SHA）。

交互式 rebase（`git rebase -i`）支持 6 种操作指令：pick（保留）、reword（修改信息）、squash（合并保留信息）、fixup（合并丢弃信息）、drop（删除）、edit（暂停修改）。

**黄金法则**：绝对不要 rebase 已经推送到公共仓库的提交。rebase 会改写 SHA，导致他人的本地仓库与你的不兼容。安全边界：只 rebase 本地未推送的提交，或自己独享的功能分支。

## 内部原理

### 四种对象

Git 的整个版本控制体系建立在四种对象之上：

- **blob**：文件内容（不含文件名和权限），通过 SHA-1 哈希寻址
- **tree**：目录结构，记录 blob 和子 tree 的映射
- **commit**：指向根 tree + 父提交 + 作者/时间/提交信息的快照
- **tag**：附注标签对象（指向某个 commit + 标签信息）

对象关系：commit → tree → blob/tree（递归），形成完整的目录快照链。

### 引用系统

引用（ref）是给 SHA 哈希的人类可读别名。分支存储在 `.git/refs/heads/`（本地分支）、`.git/refs/remotes/`（远程跟踪分支）、`.git/refs/tags/`（标签）。HEAD 指向当前分支（正常状态）或某个提交（detached HEAD 状态）。

特殊引用：ORIG_HEAD（危险操作前的 HEAD 位置，用于快速回退）、MERGE_HEAD（合并进行中的对端 SHA）、FETCH_HEAD（上次 fetch 结果）。

### packfile 压缩

随着提交增多，loose 对象通过 packfile 打包并使用 delta 压缩：只存最新完整版本 + 每次版本间的 diff，大幅节省空间。`git gc` 自动触发打包。

## 重写历史

- **`--amend`**：修改最新提交（实际是替换，生成新 SHA）
- **`rebase -i`**：交互式整理多个提交（合并/拆分/修改/重排/删除）
- **`filter-repo`**：永久清除大文件/敏感信息（破坏性极强，需备份 + 通知所有协作者重新 clone）

## Git 钩子（Hooks）

钩子是特定 Git 操作时自动触发的脚本，存放在 `.git/hooks/`。退出码 0 = 通过继续，非 0 = 中止操作。

| 钩子 | 触发时机 | 典型用途 |
|------|---------|---------|
| pre-commit | commit 前 | 运行 lint 和格式检查 |
| commit-msg | 写入提交信息后 | 验证 Conventional Commits 格式 |
| pre-push | push 前 | 运行单元测试 |
| prepare-commit-msg | 打开编辑器前 | 自动填入分支名/Jira 票号 |

Husky 解决团队共享钩子问题（`.git/hooks/` 不在版本控制中）。Python 项目推荐 pre-commit 框架。服务端钩子（pre-receive/update）无法被开发者绕过，适合强制执行代码质量门禁。

## 与其他概念的关系

- [[concepts/Docker容器化]]：Git 管理代码版本，Docker 管理运行环境，CI/CD 流水线将两者串联
- [[concepts/OAuth2授权框架]]：OAuth2 保护的 Git 服务（GitHub/GitLab）实现安全的代码协作
- [[concepts/网络安全]]：Git Hook 可作为代码安全守卫（检测私钥泄露、检查依赖漏洞）
