---
title: React
tags: [前端, JavaScript, 组件化, UI框架]
sources: [[sources/React前端框架]]
---

React 是 Meta（Facebook）开源的 JavaScript UI 库，基于组件化和声明式编程范式构建用户界面。通过虚拟 DOM（Virtual DOM）高效更新真实 DOM，是目前最流行的前端框架之一。**注意：当前知识库中 React 相关笔记尚为占位阶段，内容待完善。**

## 定义

React 是一个用于构建用户界面的 JavaScript 库（不是完整的 MVC 框架），专注于 View 层。开发者通过编写组件（可复用的 UI 单元）来描述界面"应该是什么样子"，React 负责高效地将这个描述同步到真实 DOM。

## 关键要点（待完善）

- **组件**：React 的基本构建块；函数组件（推荐）通过 Hooks 管理状态和副作用
- **JSX**：JavaScript 语法扩展，允许在 JS 中写类 HTML 结构；需 Babel 转译
- **Hooks**：`useState`（状态）、`useEffect`（副作用）、`useContext`（跨组件状态共享）等
- **虚拟 DOM**：React 在内存中维护虚拟 DOM 树，通过 diffing 算法最小化真实 DOM 操作
- **React Router**：前端路由库，实现 SPA（单页应用）的页面跳转
- **状态管理**：小型项目用 Context + useReducer；大型项目用 Redux Toolkit 或 Zustand/MobX

## 与其他概念的关系

- [[concepts/HTML]]：React 组件最终渲染为 HTML 元素
