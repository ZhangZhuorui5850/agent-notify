# Agent Notify v0.2 开发文档

## 1. 目标

v0.2 将 Windows 通知升级为具有独立品牌身份的原生应用通知：

- 通知顶部显示 `Agent Notify` 和项目图标。
- 通知进入 Windows 通知中心并保留历史记录。
- Codex、Claude Code、通用事件和命令包装器继续共用一个 CLI。
- 安装、重复安装、诊断和卸载覆盖 Windows 应用身份的完整生命周期。
- 继续使用 Python 标准库、Windows PowerShell 5.1 和 Windows 原生 API。

## 2. 调研结论

### 2.1 当前行为

v0.1 通过 `System.Windows.Forms.NotifyIcon` 发送气泡。Windows 将发送进程识别为 `powershell.exe`，因此归属区域显示 `Windows PowerShell`。`BalloonTipTitle` 和 `BalloonTipText` 分别控制任务标题与正文，系统信息图标控制左侧蓝色图形。

### 2.2 Windows 原生通知身份

Windows 11 的通知归属区域由 Shell 根据应用身份绘制，包含应用名称和图标；Toast XML 负责正文区域。未打包桌面应用使用唯一 AUMID 标识自身。Windows App SDK 的注册实现将 `DisplayName`、`IconUri` 和激活信息写入当前用户的 `Software\Classes\AppUserModelId\<AUMID>`。

本项目采用：

- AUMID：`ZhangZhuorui.AgentNotify`
- 显示名称：`Agent Notify`
- 注册范围：当前 Windows 用户（HKCU）
- 图标目录：`%LOCALAPPDATA%\Agent Notify\agent-notify.png`
- 通知 API：`Windows.UI.Notifications.ToastNotificationManager`
- 内容模板：`ToastGeneric`

当前 Windows 11 + PowerShell 5.1 环境原型验证结果：AUMID 注册成功、Toast 发送成功、Windows 创建独立通知设置条目。

### 2.3 内容设计

Windows 原生通知支持三段主要文本。v0.2 使用以下结构：

| 区域 | 内容 | 负责人 |
| --- | --- | --- |
| 归属区域 | Agent Notify + 品牌图标 | Windows Shell + AUMID 注册 |
| 第一段 | `Codex · project` 等任务标题 | Agent Notify |
| 第二段 | Agent 返回内容或任务结果 | Agent Notify |
| 归属文本 | 警告或错误级别 | Agent Notify |

信息级通知保持两段正文。警告和错误增加简短的归属文本，提升扫描效率。Windows 负责显示时长、声音、焦点辅助和通知中心行为。

### 2.4 服务形态

本期采用按事件启动的轻量 Windows 进程：WSL Python 解析事件，隐藏启动 PowerShell，PowerShell 调用 WinRT Toast API 后退出。该路径保留零额外依赖和低资源占用。常驻服务适合后续的日志监控、远程 Webhook 接收和跨会话队列能力。

### 2.5 兼容策略

已注册身份的 Windows 10/11 使用原生 Toast。身份缺失或 WinRT 调用失败时，发送器使用现有 WinForms 气泡路径。`doctor` 明确展示 PowerShell、应用身份、品牌图标和 Agent 集成状态。

## 3. 架构

```text
Codex / Claude / shell / JSON
              |
              v
       WSL agent-notify
       - 解析与压缩内容
       - 记录事件和错误
              |
              v
  Windows PowerShell 5.1（隐藏窗口）
       - 读取 HKCU AUMID 身份
       - 构造 ToastGeneric XML
       - 调用 WinRT Toast API
              |
              v
 Windows Shell + Notification Center
```

安装流程：

```text
install.sh
  -> ~/.local/bin/agent-notify
  -> ~/.local/share/agent-notify/agent-notify.png

agent-notify setup all
  -> %LOCALAPPDATA%\Agent Notify\agent-notify.png
  -> HKCU\Software\Classes\AppUserModelId\ZhangZhuorui.AgentNotify
  -> Codex / Claude Code hooks
```

卸载流程按相反顺序清理项目拥有的文件、注册表项、通知历史和 Hook 条目。

## 4. 实现计划

1. 新增可缩放图标源文件和 Windows PNG 资产。
2. 新增 Windows 身份注册、状态检查和删除命令生成器。
3. 将通知主路径切换到 `ToastGeneric`，保留 WinForms 兼容路径。
4. 扩展 `setup`、`remove`、`doctor` 和命令帮助。
5. 更新 Shell 安装器与卸载器管理共享资产。
6. 扩充自检，覆盖 XML 转义、级别、注册命令和资产发现。
7. 在 Windows 实机执行安装、重复安装、通知、诊断和卸载恢复测试。

## 5. 验收标准

| 编号 | 标准 | 证据 |
| --- | --- | --- |
| A1 | 通知归属名称为 `Agent Notify` | HKCU 注册值 + 实机 Toast |
| A2 | 通知归属区域显示品牌图标 | `IconUri` 注册值 + 实机 Toast |
| A3 | 通知进入通知中心 | 独立通知设置项 + 实机通知历史 |
| A4 | 中英文及 XML 特殊字符安全显示 | 自检 + 实机 Toast |
| A5 | info、warning、error 均可发送 | 自检 + 三类发送命令 |
| A6 | `setup all` 可重复执行 | 连续执行两次成功 |
| A7 | `doctor` 检查 Windows 身份和图标 | 实机诊断输出 |
| A8 | `remove all` 清理身份和 Hook | 文件与注册表检查 |
| A9 | 原有 Codex、Claude、event、run 接口保持可用 | 自检 + CLI 冒烟测试 |
| A10 | Python 包依赖数量保持为零 | 源码导入审计 |

## 6. 版本与后续演进

本次发布版本为 `0.2.0`。后续版本可增加通知点击激活器、按项目分组、进度通知、日志监控和远程事件入口；这些能力以实际使用数据作为启动条件。

## 7. 参考资料

- [Windows App notifications overview](https://learn.microsoft.com/en-us/windows/apps/develop/notifications/app-notifications/)
- [App notification content](https://learn.microsoft.com/en-us/windows/apps/develop/notifications/app-notifications/app-notifications-content)
- [Unpackaged app notification registration](https://learn.microsoft.com/en-us/windows/apps/develop/notifications/app-notifications/send-local-toast-other-apps)
- [Desktop toast AppUserModelID](https://learn.microsoft.com/en-us/windows/win32/shell/enable-desktop-toast-with-appusermodelid)
- [Windows App SDK registration implementation](https://github.com/microsoft/WindowsAppSDK/blob/main/dev/AppNotifications/AppNotificationUtility.cpp)
