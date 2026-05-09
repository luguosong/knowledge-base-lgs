---
name: wiki-delete
description: 删除 Wiki 中的源资料及其关联页面，级联清理索引、引用和元数据。触发词包括：删除、delete、移除、remove、清理 wiki、清理摄入。当用户想删除某个已摄入的资料或清理错误摄入的内容时使用。不用于摄入新资料、查询或健康检查。
---

# Wiki Delete（级联删除）

删除 Wiki 中的源资料及关联页面，自动清理索引、引用和元数据。

## 边界

只做删除和清理。不处理摄入（`/ingest`）、查询（`/query`）和健康检查（`/lint`）。

**不删除 raw/ 文件**——raw/ 由用户管理。本 skill 只清理 wiki/ 下的内容和元数据。

## 前置检查

确认删除目标。用户必须明确指定要删除的内容：

| 用户输入 | 行为 |
|----------|------|
| `/delete raw/路径/文件.md` | 删除该 raw 文件对应的 wiki 内容 |
| `/delete sources/页面名` | 通过 source 摘要页名删除 |
| 用户描述删除意图 | 询问确认具体目标 |

## 删除流程

### 步骤 1：定位目标

从 `wiki/.status.json` 中找到目标 raw 文件对应的条目：

```python
# 在 .status.json 中查找
entry = status.json["processed"]["raw/路径/文件.md"]
# 获取: source_page, created_pages, page_hashes
```

如果 .status.json 中没有对应条目，用 Grep 搜索 wiki/ 目录中的 `sources:` frontmatter 字段来定位。

### 步骤 2：确认删除范围

向用户展示将要删除的内容清单，**必须获得确认后才能执行**：

```
即将删除以下内容：
- wiki/sources/对应摘要页.md（来源摘要）
- wiki/entities/实体X.md（仅被此来源引用）
- wiki/concepts/概念Y.md（仅被此来源引用）

以下页面将被修改（移除来源引用，不删除）：
- wiki/entities/实体Z.md（还有其他来源支撑）
- wiki/concepts/概念W.md（还有其他来源支撑）

确认删除？(y/n)
```

### 步骤 3：3-method 关联页面匹配

使用三种方法找到所有关联的 wiki 页面：

**方法 1：frontmatter sources[] 匹配**
```bash
# 搜索 frontmatter 中引用了该 source 摘要页的页面
grep -rl "sources/对应摘要页" wiki/ --include="*.md"
```

**方法 2：status.json created_pages 匹配**
从 .status.json 的 `created_pages` 列表直接获取。

**方法 3：wikilink 引用匹配**
```bash
# 搜索通过 [[wikilinks]] 引用了该 source 的页面
grep -rl "\\[\\[sources/对应摘要页\\]\\]" wiki/ --include="*.md"
```

### 步骤 4：执行级联清理

**删除仅被此来源引用的页面**：
- 检查每个关联页面的 `sources:` frontmatter
- 如果移除当前来源后 `sources:` 为空 → 删除该页面
- 如果仍有其他来源 → 只从 `sources:` 中移除当前来源

**修改保留的页面**：
- 从 frontmatter `sources:` 中移除被删除来源
- 移除指向已删除页面的 `[[wikilinks]]`
- 移除"与现有知识的关联"章节中引用已删除页面的条目

**清理索引**：
- 从 `wiki/index.md` 移除已删除页面的条目

**清理元数据**：
- 从 `wiki/.status.json` 移除对应条目

### 步骤 5：追加日志

在 `wiki/log.md` 末尾追加：
```markdown
## [YYYY-MM-DD] delete | 资料标题
- 删除了 [[sources/资料标题]]
- 删除了 [[entities/实体X]]（无其他来源）
- 更新了 [[entities/实体Z]]（移除来源引用）
- 清理了 index.md 和 .status.json
```

### 步骤 6：更新搜索索引

```bash
qmd-node update && qmd-node embed
```

## 安全机制

- **必须确认**：步骤 2 展示删除范围后等待用户确认
- **不删 raw/**：只清理 wiki/ 下的内容和元数据
- **保留有支撑的页面**：有多个来源的 entity/concept 页面不会被删除，只移除被删除来源的引用
- **可追溯**：log.md 记录完整的删除操作历史
