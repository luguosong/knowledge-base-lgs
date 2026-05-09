---
title: "Obsidian Skills：Obsidian Agent 技能集"
source: "https://github.com/kepano/obsidian-skills"
description: "为 Obsidian 提供 Agent Skills，教会 Agent 使用 Markdown、Bases、JSON Canvas 及 CLI 工具。"
author:
---
字数：262

Obsidian Agent Skills。

这些 skill 遵循 [Agent Skills 规范](https://agentskills.io/specification)，可被任何兼容该规范的 Agent 使用，包括 Claude Code 和 Codex CLI。

## 安装

### 通过市场

```
/plugin marketplace add kepano/obsidian-skills
/plugin install obsidian@obsidian-skills
```

### 通过 npx skills

```
npx skills add git@github.com:kepano/obsidian-skills.git
```

如果不使用 SSH，也可以用 HTTPS：

```
npx skills add https://github.com/kepano/obsidian-skills
```

### 手动安装

#### Claude Code

将此仓库的内容添加到 Obsidian vault 根目录下的 `/.claude` 文件夹中（或你与 Claude Code 配合使用的其他文件夹）。详见 [Claude Skills 官方文档](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)。

#### Codex CLI

将 `skills/` 目录复制到你的 Codex skills 路径（通常为 `~/.codex/skills`）。参见 [Agent Skills 规范](https://agentskills.io/specification) 了解标准 skill 格式。

#### OpenCode

将整个仓库克隆到 OpenCode skills 目录（`~/.opencode/skills/`）：

```
git clone https://github.com/kepano/obsidian-skills.git ~/.opencode/skills/obsidian-skills
```

> [!warning] 不要只复制内部的 `skills/` 文件夹
> 必须克隆完整仓库，确保目录结构为 `~/.opencode/skills/obsidian-skills/skills/<skill-name>/SKILL.md`。

OpenCode 会自动发现 `~/.opencode/skills/` 下的所有 `SKILL.md` 文件。无需修改 `opencode.json` 或任何配置文件。重启 OpenCode 后 skill 即可生效。

## Skills 列表

| Skill | 描述 |
| --- | --- |
| [obsidian-markdown](https://github.com/kepano/obsidian-skills/blob/main/skills/obsidian-markdown) | 创建和编辑 [Obsidian Flavored Markdown](https://help.obsidian.md/obsidian-flavored-markdown)（`.md`），支持 wikilinks、嵌入、callout、properties 等 Obsidian 专属语法 |
| [obsidian-bases](https://github.com/kepano/obsidian-skills/blob/main/skills/obsidian-bases) | 创建和编辑 [Obsidian Bases](https://help.obsidian.md/bases/syntax)（`.base`），支持视图、过滤、公式和汇总 |
| [json-canvas](https://github.com/kepano/obsidian-skills/blob/main/skills/json-canvas) | 创建和编辑 [JSON Canvas](https://jsoncanvas.org/) 文件（`.canvas`），支持节点、边、分组和连接 |
| [obsidian-cli](https://github.com/kepano/obsidian-skills/blob/main/skills/obsidian-cli) | 通过 [Obsidian CLI](https://help.obsidian.md/cli) 与 Obsidian vault 交互，包括插件和主题开发 |
| [defuddle](https://github.com/kepano/obsidian-skills/blob/main/skills/defuddle) | 使用 [Defuddle](https://github.com/kepano/defuddle-cli) 从网页中提取干净的 Markdown，去除冗余内容以节省 Token |
