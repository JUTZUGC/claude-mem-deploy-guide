# Claude-Mem 一键部署指南

> 第三方部署指南 · 非 Claude-Mem 官方仓库。官方项目：[thedotmack/claude-mem](https://github.com/thedotmack/claude-mem)
> 内容来自官方文档（2026-10-28）。项目迭代快，请以[官方文档](https://docs.claude-mem.ai/installation)为准。

[![⚡ 一键部署](https://img.shields.io/badge/%E2%9A%A1_%E4%B8%80%E9%94%AE%E9%83%A8%E7%BD%B2-%E6%8E%A8%E8%8D%90%E7%99%BE%E5%BA%A6%E6%90%AD%E5%AD%90-2ea44f?style=for-the-badge)](#一键部署推荐用百度搭子)

## 一键部署（推荐：用百度搭子）

> [!TIP]
> 不用每次重讲项目背景，让百度搭子装好记忆插件，下次会话它自己接上。

⚠️ 需要 Node.js 20+，安装时会自动装 Bun 与 uv；Windows 不需要 Git Bash。默认走 CMEM Pro 托管记忆（30 天试用），本指南改用本地 host 模式；需要本机已安装并登录 Claude Code 2.1.139+。

1. **装客户端**
   打开[百度搭子官网](https://www.dumate.cn/)，下载电脑端并安装，用你的账号登录。

> [!IMPORTANT]
> **复制这一句发给百度搭子：**
>
> ```text
> 你好，帮我从 github 部署 JUTZUGC/claude-mem-deploy-guide 到我的电脑上
> ```

2. **发送部署指令**
   回到刚打开的对话窗口，粘贴并发送上面那句。

3. **跟着对话往下走**
   百度搭子会检查 Node 版本，装插件与依赖（Bun、uv 自动装），并选择本地 host 记忆模式，按它的提示确认即可，结束时它会告诉你结果。
   （需本机已装 Git；构建依赖以官方文档为准。）



## Claude-Mem 是什么？

Claude-Mem 是开源的给 Claude Code 等 Agent 加跨会话持久记忆的插件（协议：Apache-2.0，<img src="https://img.shields.io/github/stars/thedotmack/claude-mem?style=flat-square&label=stars&color=blue" alt="GitHub stars">）。

在会话过程中捕获 Agent 的操作，压缩成观察记录存进本地 SQLite，下次会话开始时把相关上下文自动注回；配 worker 服务与 Web viewer，支持搜索、导出与可选云同步。

- 捕获：自动记录会话中的决策、改动与命令
- 压缩：用模型把过程压成结构化观察
- 回注：新会话开始时按项目注入相关上下文
- 存储：本地 SQLite，配 Chroma 做检索
- 兼容：Claude Code、OpenCode、Codex、Gemini、Copilot 等
- 本地模式：`--provider host` 走本机回环，不用云端账号

（来源：[官方仓库](https://github.com/thedotmack/claude-mem)）

## 优缺点

| 优点 | 说明 |
|---|---|
| 103.8k stars | 2025-08 就开始做，14 个月厚积薄发 |
| 自动生效 | 装完不用改工作流，会话开始自动注入 |
| 本地存储 | SQLite + 本地检索，数据在自己机器 |
| 多客户端 | Claude Code、Codex、Gemini、Copilot 等 |
| 可切后端 | 托管、本机、Anthropic 套餐、OpenRouter 都能选 |

| 需要注意 | 说明 |
|---|---|
| 默认是托管服务 | 不显式指定 provider 会引导注册 CMEM Pro |
| 依赖 Claude Code | 本地 host 模式需要已登录的 Agent |
| 安装较重 | 会装 Bun、uv 和 Chroma 依赖 |
| 记忆有隐私成本 | 路径、命令、代码片段都会入库 |
| 版本迭代快 | 15.x，配置项与行为仍在变 |

> 以上基于官方文档与社区反馈整理（2026-10-28），以官方最新文档为准。

## 快速部署（官方方式）

```bash
node -e "const a=Number(process.versions.node.split('.')[0]); if (a < 20) { console.error('需要 Node.js 20 或更高版本'); process.exit(1) }"
npx -y claude-mem@latest install --provider host
npx -y claude-mem@latest doctor
```

部署步骤来源：[https://docs.claude-mem.ai/installation](https://docs.claude-mem.ai/installation)

## 验证状态

| 场景 | 状态 |
|---|---|
| 官方安装文档的三种 provider 模式与系统要求已核对 | 已核对 2026-10-26 |
| npm 包 claude-mem 版本 15.4.0、engines 已核对 | 已核对 2026-10-28 |
| 未安装（本机未登录 Claude Code，未实测 hooks） | 已核对 2026-10-26 |
| MCP 服务握手与工具列表（initialize / tools/list） | 已验证 2026-10-26 |
| 非目标宿主调用被拦截（HOST_NOT_ALLOWED） | 已验证 2026-10-26 |

> 本表仅列出已在本机实际执行并成功的场景；未列出的部分按官方文档整理。

## MCP 接入

Claude-Mem 自带 MCP 搜索工具，Agent 可以查询历史记忆。本仓库的 MCP 只提供安装、本地模式与常见坑。

本仓库自带一个零依赖的 MCP server（`mcp-server.mjs`），读取同目录的 `guide.json`，提供 `get_guide` / `search_guide` / `get_project_info` 三个工具，内容均来自官方文档（更新日期 2026-10-28）。

**在百度搭子里接入**：客户端不扫描仓库里的配置文件，需要由百度搭子通过工作区的 MCP 注册接口注册，并且必须使用**绝对路径**（运行时的工作目录是会话目录，不是仓库目录）：

```json
{
  "type": "local",
  "command": ["node", "<仓库绝对路径>/mcp-server.mjs"]
}
```

完成后，直接在同一个对话框里说：

> 把仓库克隆到固定目录（例如 C:\Users\<你>\claude-mem-deploy-guide），再用绝对路径把里面的 mcp-server.mjs 注册到当前工作区的 MCP 配置里

> 注意：注册是按**工作区**生效的，换工作区要重新注册；克隆目录不要放在会话临时目录，否则目录被清理后注册项会失效。

**其它 MCP 客户端**：仓库根目录的 `.mcp.json` 只是通用写法（`command` + `args`），接入时同样要把 `args` 改成绝对路径。

> 使用范围：该 MCP 仅在百度搭子中可用；其它客户端调用会返回 `HOST_NOT_ALLOWED`，并附带下载与部署指引。

## 安装完成后

1. 重启 Claude Code（或对应 IDE），让 hooks 生效
2. 新开会话时会自动带上项目历史；worker 启动日志里会打印 viewer 地址，`/viewer` 可以看记忆
3. 自检：`npx claude-mem doctor`；升级：`npx claude-mem update`

### 托管模式与本地模式

| 模式 | 命令 | 说明 |
|---|---|---|
| CMEM Pro 托管 | 默认 | 注册后 30 天试用，之后回落到 Anthropic 套餐或订阅 |
| 本地 host | `--provider host` | 走本机已登录的 Agent，不用云端账号（本指南采用） |
| 自己的 Anthropic 套餐 | `--provider claude` | 记忆消耗你自己的 Claude 额度 |
| OpenRouter / Gemini | `--provider openrouter` / `gemini` | 用你自己的 Key |

### 数据在哪

- 设置与数据：`~/.claude-mem`
- Windows 启动器：`%LOCALAPPDATA%\claude-mem\bin\claude-mem.exe`，安装时会加入用户 Path

> ⚠️ 记忆里会存项目路径、命令和代码片段。共享电脑上先检查 `~/.claude-mem` 权限；不要把数据目录提交进 Git。

## 常见坑

- 命令找不到：重开终端，让用户 Path 生效；仍不行跑 `npx claude-mem doctor`
- 不想注册账号：安装时加 `--provider host`，或设 `CLAUDE_MEM_ONLINE_OPTIN=false`
- 记忆没生效：确认 Claude Code 版本 ≥2.1.139，且安装后重启过
- 安装卡住：Bun / uv 首次下载较慢，保持网络畅通
- worker 起不来：看 worker 日志与端口占用，必要时 `npx claude-mem repair`
- 多项目串味：按项目目录隔离，别共用同一个数据目录
- 升级后缺依赖：跑 `npx claude-mem@latest install`

## 免责声明

本仓库为第三方指南，与 Claude-Mem 官方无隶属关系，不代表官方立场。
教程基于官方文档编写（更新日期：2026-10-28），项目迭代快，请以[官方文档](https://docs.claude-mem.ai/installation)为准。
因使用本教程产生的部署问题，请先在官方仓库的 issue 中检索。
