---
name: doc-translate
description: 翻译 Markdown 文档为中文，并格式化为 Obsidian 兼容的 Markdown。用户指定文件或目录路径，翻译 front matter（title 简化翻译、description 翻译）和正文内容，使用 Obsidian Callout 等语法美化输出。触发词：翻译文档、translate、翻译 markdown、doc translate、翻译文件、translate doc。即使用户只说"翻译这个文件"或"把这个翻译一下"也应该触发此 skill。
---

# 文档翻译 Skill

将英文 Markdown 文档翻译为中文，同时将输出格式化为 Obsidian 兼容的 Markdown 文档。

## 边界说明

这个 skill 做且只做一件事：**原地翻译指定的 Markdown 文件**。

- 直接用翻译后的内容覆盖源文件（除非用户指定了其他输出位置）
- 不会在 wiki/ 目录下创建任何新页面
- 不会触发 Ingest、Query、Lint 等 Wiki 操作
- 不会更新 index.md、log.md、.status.json
- 即使文件位于 raw/ 目录下，也只是原地翻译，不做知识库摄入

## 前置确认

1. 用户必须指定要翻译的文件或目录路径。如果用户没有指定，用 `AskUserQuestion` 主动询问。
2. 确认路径存在后再开始翻译。如果路径不存在，提示用户检查。
3. 如果用户指定的是目录，找出该目录下所有 `.md` 文件，逐个翻译。

## 大文件处理策略

**文件大小 > 30KB 时，必须使用 `general-purpose` subagent 执行翻译。**

原因：大文件翻译需要多次分段读取和多次 edit，容易填满主会话 context；会话压缩后需要重建翻译状态，效率低且容易出错。

操作方式：
1. 检查文件大小（`Get-Item <path> | Select-Object -ExpandProperty Length`）
2. 若 > 30KB，使用 task 工具启动 `general-purpose` subagent，将完整翻译任务（含文件路径、翻译规范、术语约定）作为 prompt 传入
3. Subagent 在独立 context 中完成全部翻译，主会话只做最终验收
4. 文件 ≤ 30KB 时，在主会话中直接按以下步骤执行

## 翻译流程

### 步骤 1：读取原文

用 Read 工具读取源文件内容。

### 步骤 2：处理 Front Matter

分析文档顶部的 YAML front matter（`---` 包裹的部分）：

| 字段 | 处理规则 |
|------|----------|
| `title` | 简化并翻译为中文。如果原标题冗长，提取核心含义。如果不存在 `title` 字段，从文档第一个 H1 标题提取并创建 |
| `description` | 翻译为中文。如果不存在则忽略，不创建 |
| 其他字段 | 保留原样，不做修改 |

title 简化原则：去掉冗余修饰词，保留核心主题。例如 "Getting Started with Spring Security Authentication" → "Spring Security 认证入门"。

### 步骤 3：翻译正文

#### 翻译核心理念

目标是产出**自然流畅的中文**，读起来像是由母语工程师撰写的——而非机器翻译的逐字对应。

- 准确性优先：保留所有技术含义，不遗漏或扭曲
- 自然性次之：产出资深中文工程师会撰写的文章
- 不解释、不说明、不总结——仅进行翻译

#### 术语处理（关键）

术语处理是翻译质量的核心分界线。分四种情况：

**情况 1：行业通用英文术语——保持英文，不加注解**

在中文技术写作中广泛使用的术语应保持英文原样，不要强行翻译，也不需要附加中文注解：

`Spring Boot`、`Bean`、`Controller`、`Handler`、`Provider`、`Service`、`Repository`、`Promise`、`Hook`、`middleware`、`payload`、`token`、`socket`、`pipeline`、`callback`、`namespace`、`runtime`、`mock`、`stub`、`framework`、`plugin`、`schema`、`endpoint`、`request`、`response`、`session`、`cookie`、`header` 等。

正确示例：`Controller` 负责处理 HTTP 请求。
错误示例：`Controller`（控制器）负责处理 HTTP 请求。
错误示例：控制器负责处理 HTTP 请求。

**情况 2：英文术语+首次出现附中文注解**

当保留英文术语有助于精确性或符合标准实践时，保留英文，首次出现时在括号中附加简短中文注解：

`Interceptor`（拦截器）、`Circuit Breaker`（熔断器）、`Service Mesh`（服务网格）、`Dead Letter Queue`（死信队列）

注解只在术语**首次出现时**添加，后续出现保持纯英文。

**情况 3：中文术语+附英文原文**

对于翻译成中文的术语，在括号中附加英文原文：`依赖注入 (Dependency Injection)`、`消息队列 (Message Queue)`、`反向代理 (Reverse Proxy)`。

**情况 4：纯中文通用术语**

如果术语本身已经是中文技术写作中的通用表达（如"数据库"、"服务器"、"线程"、"接口"），直接使用中文，不需要附加英文。

#### 翻译风格

- 使用领域适当的中文术语（软件工程、Java/Spring 生态、分布式系统、密码学、网络安全等）
- 倾向于简洁、主动的措辞而非冗长的字面翻译
- 匹配源文本的语体：技术文档保持正式；注释保持简洁
- 当源文本存在歧义时，选择与软件工程背景最一致的解释
- 不自行扩展、补充或删减原文内容

#### 代码块处理

- 代码块内容不翻译
- 代码块中的注释可翻译为中文
- 代码块上方的说明文字正常翻译

#### 其他处理

- **链接**：保留所有超链接地址不变，链接文字翻译为中文
- **图片**：图片地址和格式保持不变，图注（caption）翻译为中文
- **代码中的标识符**：保持所有变量名、类名、方法名、包路径不变

### 步骤 4：Obsidian 格式化

将翻译后的内容按照 Obsidian 兼容的 Markdown 语法进行格式化。

#### Callouts（提示框）

根据原文内容语义，适当添加 Obsidian Callout 提升可读性：

```markdown
> [!note] 标题
> 内容

> [!tip] 标题
> 内容

> [!warning] 标题
> 警告内容

> [!info] 标题
> 补充说明
```

适用场景：
- `note`：一般性备注
- `info`：补充说明、背景知识
- `tip`：实用技巧、最佳实践
- `warning`：注意事项、潜在问题
- `danger`：严重警告、可能导致数据丢失等
- `example`：示例说明
- `abstract`：摘要、总结
- `question`：常见问题
- `bug`：已知问题

Callout 语法规则：
- 使用 `>` 引用块语法，`[!type]` 后跟标题
- 多行内容每行都以 `>` 开头
- 可嵌套：在 `>` 前加 `>` 表示嵌套层级
- 不要过度使用，只在原文有明确提示/警告/备注语义时添加

#### 代码块

使用标准 Markdown 代码块，Obsidian 原生支持语言标识符高亮：

````markdown
```java
// 代码内容
```
````

如果需要标注代码来源文件，在代码块**上方**用普通文本说明，不使用特殊属性语法。

#### Wikilinks（双链）

翻译过程中遇到原文的交叉引用时：
- 如果引用的是已有 Wiki 页面，使用 Obsidian 的 `[[页面名]]` 双链语法
- 如果是普通文档（非 Wiki 环境），保留原始 Markdown 链接格式

#### 表格、列表等

保留原有的 Markdown 表格和列表格式，内容翻译为中文。

#### 行内格式

- 用反引号包裹关键技术术语：`依赖注入 (Dependency Injection)`
- 不用 `**` 加粗正文文本
- 不用反引号包裹标题文本

### 步骤 5：输出结果

1. 用 Write 或 Edit 工具将翻译后的内容写回源文件，原地覆盖
2. 如果用户指定了输出目录，则写入到指定目录
3. 完成后告知用户翻译了哪些文件
4. 不要执行任何额外操作（不创建 wiki 页面、不更新索引、不运行搜索命令）

## 翻译质量自检

完成翻译后，对照以下清单自检：

- [ ] title 已简化翻译为中文
- [ ] description 已翻译（如果存在）
- [ ] 正文无遗漏段落
- [ ] 行业通用术语保持英文，无冗余中文注解
- [ ] 非通用英文术语首次出现时附中文注解
- [ ] 中文术语附英文原文
- [ ] 代码块、变量名、类名未被翻译
- [ ] 链接地址完整保留
- [ ] Callout 格式正确（`> [!type] 标题` + `>` 前缀内容）
- [ ] 没有自行添加原文没有的内容
- [ ] 译文读起来自然流畅，不像机器翻译
- [ ] 没有触发任何 Wiki 操作（未创建 wiki 页面、未更新索引）
