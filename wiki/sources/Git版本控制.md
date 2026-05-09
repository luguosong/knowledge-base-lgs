---
title: Git 版本控制
date: 2026-05-08
type: note
tags: [git, 版本控制]
related_concepts: [[concepts/Git版本控制]]
---

从 VCS 演进史出发，系统讲解 Git 分布式版本控制系统。内容涵盖三区域模型（工作目录-暂存区-本地仓库）、文件状态流转、分支机制（轻量指针的本质）、合并与 rebase 策略、内部原理（blob/tree/commit/tag 四种对象）、Git Hooks 自动化守卫，以及 Conventional Commits 等最佳实践。从基础配置到高级工具（cherry-pick、bisect、reflog）形成完整的 Git 知识体系。

## 核心要点

- **VCS 演进**：本地 VCS → 集中式 VCS（CVS/SVN，中央服务器单点故障） → 分布式 VCS（Git/Mercurial，每人有完整仓库）
- Git 是分布式版本控制系统，每台机器都有完整历史，采用快照（snapshot）而非差异（delta）存储
- 核心三区域：工作目录 → 暂存区（Staging Area） → 本地仓库（.git）
- 文件四种状态流转：Untracked → Staged → Unmodified → Modified → Staged
- 分支本质是轻量指针（40 字节的 SHA 文件），创建/删除代价几乎为零
- 合并策略：Fast-forward（快进）、三方合并（3-way merge）、squash merge
- rebase 将分叉历史变为线性，但黄金法则是「已推送的历史不要重写」
- 内部原理：四种对象（blob/tree/commit/tag）+ 引用系统 + packfile 压缩
- Git 钩子（Hooks）实现自动化守卫，Husky 解决团队共享钩子配置
- **安装配置**：三级配置系统（system/global/local），必配 user.name 和 user.email

## 详细摘要

### VCS 演进史

版本控制系统经历了三代演进：本地 VCS（只在本机）→ 集中式 VCS（CVS/Subversion，依赖中央服务器，宕机则全体停工）→ 分布式 VCS（Git/Mercurial，每台机器都是完整仓库镜像）。集中式的致命缺陷是单点故障——服务器硬盘损坏则历史全丢。

### 安装与初始配置

三级配置系统，更细的范围优先级更高：
- `--system`（/etc/gitconfig）：系统所有用户
- `--global`（~/.gitconfig）：当前用户所有仓库
- `--local`（.git/config）：当前仓库（默认）

必做配置：`user.name`、`user.email`、`init.defaultBranch main`。常用技巧包括命令别名（`alias.st status`）和换行符处理（`core.autocrlf`）。

### 核心哲学

Git 与 SVN 的根本区别在于存储模型：SVN 记录文件随时间积累的差异（delta），Git 记录项目在某个时刻的完整快照。快照的好处是切换分支极快、任何版本可独立恢复、离线工作无限制。

三个区域决定了文件在 Git 中的生命周期：
- **工作目录**：实际编辑文件的地方
- **暂存区（Staging Area/Index）**：决定哪些修改纳入下次提交的「候车室」
- **本地仓库（.git）**：保存所有历史快照的地方

文件在四种状态间流转：Untracked → Staged → Unmodified → Modified → Staged。

### 基础操作

- `git init`/`git clone`：获取仓库
- `git add`：暂存改动（语义是「将内容精确放入下一次提交」，而非「添加文件」）
- `git commit`：创建快照（推荐 Conventional Commits 格式）
- `git status`/`git diff`：观察仓库状态和具体改动
- `git rm`/`git mv`：从 Git 中删除/重命名文件
- `.gitignore`：排除不应进入版本控制的文件

### 分支机制

分支本质上只是一个指向某个提交的 40 字节 SHA 文件。HEAD 是特殊指针，始终指向当前分支。Git 2.23+ 推荐使用 `git switch`（切换分支）和 `git restore`（还原文件）替代 `git checkout`。

合并策略选择：
- **Fast-forward**：目标分支无新提交，直接移动指针
- **三方合并**：两个分支都有新提交，找共同祖先计算合并结果，可能产生冲突
- **squash merge**：将功能分支的所有提交压缩成一个，保持主线历史整洁

分支工作流：GitHub Flow（简单，持续部署）、Git Flow（结构化，版本发布）、Trunk-Based Development（高频发布，极低复杂度）。

### 变基（rebase）

rebase 将功能分支的提交「移植」到主线最新提交之后，使历史变为线性。与 merge 的核心区别是 rebase 会改写提交 SHA。

交互式 rebase（`git rebase -i`）支持 pick/reword/squash/fixup/drop/edit 操作，是整理杂乱提交历史的利器。

黄金法则：绝对不要 rebase 已经推送到公共仓库的提交。`--onto` 参数可精确控制变基目标。

### 高级工具

- **cherry-pick**：挑选特定提交应用到当前分支
- **bisect**：二分法定位引入 bug 的提交
- **reflog**：记录所有 HEAD 移动历史，是「最终后悔药」
- **tag**：版本发布标记（轻量标签 vs 附注标签）

### 重写历史

- `--amend`：修改最新提交（实际是生成新提交替换旧提交）
- `rebase -i`：交互式整理多个提交（合并、拆分、修改、重排、删除）
- `filter-repo`：永久清除大文件/敏感信息（破坏性极强，需备份+通知协作者）

### 内部原理

四种对象类型：
- **blob**：文件内容（不含文件名和权限）
- **tree**：目录结构（记录 blob 和子 tree）
- **commit**：快照 + 元数据（指向根 tree + 父提交 + 作者/时间/信息）
- **tag**：附注标签对象

引用（ref）是给 SHA 哈希的别名：分支（`.git/refs/heads/`）、远程跟踪分支（`.git/refs/remotes/`）、标签（`.git/refs/tags/`）。特殊引用：HEAD、ORIG_HEAD、MERGE_HEAD、FETCH_HEAD。

packfile 通过 delta 压缩节省空间：100 个历史版本只存最新完整版 + 每次版本间的 diff。

### Git 钩子（Hooks）

钩子是特定 Git 操作时自动触发的脚本，存放在 `.git/hooks/`。关键钩子：pre-commit（提交前 lint）、commit-msg（提交信息格式验证）、pre-push（推送前测试）。

Husky 解决团队共享钩子问题（`.git/hooks/` 不在版本控制中）。Python 项目推荐 pre-commit 框架。退出码 0 = 通过继续，非 0 = 中止操作。

### 最佳实践

- Conventional Commits 格式：`<type>(<scope>): <subject>`
- 原子性提交：每个提交只做一件事
- `git switch -c` 创建并切换分支
- PR 前标准流程：fetch → rebase → rebase -i 整理 → push --force-with-lease

## 引用的实体与概念

- 相关工具：Git CLI、GitHub、GitLab、Husky、pre-commit 框架
- 相关概念：[[concepts/Git版本控制]]

## 与现有知识的关联

- Git 工作流与 [[concepts/Git版本控制]] 概念页对应
- Git CI/CD 集成（GitHub Actions/Jenkins）与 [[sources/Docker容器化]] 的流水线配置相关
- Git Hook 机制与代码质量守卫紧密关联
