---
title: HTML
tags: [前端, Web, 标记语言, 语义化]
sources: [[sources/HTML基础学习]]
---

HTML（HyperText Markup Language，超文本标记语言）是构建网页的标准语言，由浏览器解析并渲染为可见的页面结构。它是 Web 开发的基础层，负责定义内容的语义结构，与 CSS（样式）和 JavaScript（行为）共同构成网页三剑客。

## 定义

HTML 通过标签（tag）描述内容的结构和语义，浏览器读取 `.html` 文件并将其渲染为可见页面。HTML 本身只是带角度括号的纯文本，真正让它"变成网页"的是浏览器的解析和渲染引擎。当前标准版本为 HTML5（2014 年成为 W3C 推荐标准）。

## 关键要点

- **文档结构**：`<!DOCTYPE html>` → `<html>` → `<head>`（不可见元数据）+ `<body>`（可见内容）
- **语义化标签**（HTML5 新增）：
  - `<header>`、`<nav>`：页头和导航
  - `<main>`：主内容区（每页唯一）
  - `<article>`：独立可复用内容（文章/帖子）
  - `<section>`：主题性分组
  - `<aside>`：侧边栏/次要内容
  - `<footer>`：页脚
- **块级元素 vs 行内元素**：
  - 块级：`<div>`、`<p>`、`<h1>`-`<h6>`、`<ul>`/`<ol>`、`<table>` — 独占一行
  - 行内：`<span>`、`<a>`、`<img>`、`<strong>`、`<em>` — 不换行
- **表单验证**：HTML5 原生验证属性：`required`、`pattern`、`min`/`max`、`maxlength`；`novalidate` 禁用原生验证
- **可访问性**：`alt` 属性（图片描述）、`<label for>` 关联表单控件、ARIA 属性（`aria-label`、`role`）
- **SEO 相关**：`<meta name="description">`、语义化标签、合理使用 `<h1>`-`<h6>` 层次结构

## 与其他概念的关系

- 与 CSS 配合：HTML 提供结构，CSS 提供样式（通过 `class`/`id` 选择器关联）
- 与 JavaScript 配合：通过 DOM API 操作 HTML 元素，实现动态交互
