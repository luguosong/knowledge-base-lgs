---
title: HTML 基础学习
date: 2025-07-10
type: note
tags: [前端, HTML, Web, 语义化]
related_concepts: [[concepts/HTML]]
---

HTML 基础学习笔记，涵盖超文本标记语言的完整体系：文档基本结构（DOCTYPE/head/body）、超链接、语义化结构元素（header/main/article/section）、表格、表单（input/select/textarea）、文本内容标签、嵌入与脚本（iframe/script）、字符实体、媒体元素（img/video/audio）以及列表。共 11 个主题模块，内容丰富，配有实战示例。

## 核心要点

- **HTML 职责**：定义网页内容的**结构**，不负责样式（CSS）和行为（JavaScript）；HTML 不是编程语言
- **文档基本结构**：`<!DOCTYPE html>` 声明 HTML5 → `<html lang="zh">` → `<head>`（元数据）+ `<body>`（可见内容）
- **语义化元素**：`<header>`、`<nav>`、`<main>`、`<article>`、`<section>`、`<aside>`、`<footer>` 替代无意义的 `<div>`，改善可访问性和 SEO
- **超链接**：`<a href="...">` 是 HTML 的核心；`target="_blank"` 新标签页；`href="#id"` 页内锚点；`href="mailto:"` 邮件链接
- **表单**：`<form action method>` 包裹；`<input type>` 支持 text/password/radio/checkbox/email/file/date 等；`<label for>` 关联标签增强可用性
- **表格**：`<table>`→`<thead>`/`<tbody>`/`<tfoot>`→`<tr>`→`<th>`/`<td>`；`colspan`/`rowspan` 合并单元格
- **媒体元素**：`<img src alt>` 图片；`<video controls>` 视频；`<audio controls>` 音频；响应式图片用 `srcset`
- **字符实体**：`&lt;`（<）、`&gt;`（>）、`&amp;`（&）、`&nbsp;`（不换行空格）
- **嵌入**：`<iframe>` 嵌入外部页面；`<script src defer>` 引入脚本；`defer` 避免阻塞渲染

## 详细摘要

### HTML 文档模板

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>页面标题</title>
</head>
<body>
  <header>
    <nav>...</nav>
  </header>
  <main>
    <article>...</article>
  </main>
  <footer>...</footer>
</body>
</html>
```

### 语义化 vs 非语义化

```html
<!-- 非语义化（不推荐） -->
<div class="header"><div class="nav">...</div></div>

<!-- 语义化（推荐） -->
<header><nav>...</nav></header>
```

### 常用 input 类型

| type 值 | 用途 | 特殊行为 |
|---------|------|---------|
| text | 单行文本 | 默认 |
| password | 密码 | 隐藏字符 |
| email | 邮箱 | 内置格式验证 |
| number | 数字 | 支持 min/max/step |
| file | 文件上传 | multiple 多选 |
| checkbox | 复选框 | — |
| radio | 单选框 | 同 name 互斥 |
| date | 日期选择 | 浏览器原生日期控件 |

## 与现有知识的关联

- [[concepts/HTML]]：本资料是 HTML 概念页的主要来源
