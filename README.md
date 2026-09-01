# Agent Notify

<p align="center">
  <img src="assets/agent-notify.png" alt="Agent Notify logo" width="112" height="112">
</p>

Send Codex, Claude Code, and shell task completion events from WSL to the Windows notification area.

发送 Codex、Claude Code 和后台命令的完成事件到 Windows 右下角通知区域。

## Features

- Branded native Windows app notifications and notification-center history
- Independent `Agent Notify` app identity and icon
- Info, warning, and error levels
- Codex `Stop` hook integration for CLI and the VS Code extension
- Claude Code `Stop` hook integration
- Generic JSON event input for other agents and scripts
- Command wrapper that preserves the original exit code
- Zero Python package dependencies and zero resident processes
- Hidden PowerShell execution, legacy notification fallback, diagnostics, error logs, and configuration backups

## Requirements

- Windows 10 or Windows 11
- WSL with Python 3.9+
- Windows PowerShell 5.1, included with Windows

## Install

```bash
git clone https://github.com/ZhangZhuorui5850/agent-notify.git
cd agent-notify
./install.sh
~/.local/bin/agent-notify setup all
~/.local/bin/agent-notify test
```

`setup` updates the user-level Codex and Claude Code settings. Each original file is copied to an adjacent `*.agent-notify.backup` file. After setup, reload VS Code, enter `/hooks` in Codex, open the `Stop` hook, and press `t` to trust Agent Notify.

`setup all` also installs the logo under `%LOCALAPPDATA%\Agent Notify` and registers the per-user Windows application identity `ZhangZhuorui.AgentNotify`. Windows uses this identity for the notification header, icon, settings, and history.

The Codex integration uses the official `Stop` lifecycle hook in `~/.codex/hooks.json`. Codex sends the hook event as JSON on standard input after each completed turn. The hook returns immediately after launching the hidden Windows notification process.

## Upgrade

```bash
git pull
./install.sh
~/.local/bin/agent-notify setup all
~/.local/bin/agent-notify doctor
```

The setup operation is idempotent and refreshes the Windows icon and registration on every run.

## Usage

Send a notification:

```bash
agent-notify send "Build" "Release package is ready"
agent-notify send "Tests" "3 tests failed" error
```

Notify when a command finishes and preserve its exit code:

```bash
agent-notify run "Backend tests" -- npm test
```

Send a generic event:

```bash
printf '%s' '{"source":"Worker","project":"api","message":"Queue drained","level":"info"}' \
  | agent-notify event
```

Check the installation:

```bash
agent-notify doctor
agent-notify self-test
agent-notify version
```

Successful Agent hook calls are recorded at `~/.local/state/agent-notify/events.log`. Hook errors are recorded at `~/.local/state/agent-notify/errors.log`.

## Notification behavior and privacy

Agent notifications include up to 240 characters from the latest assistant message. Windows keeps delivered notifications in Notification Center, and the content may also appear on the lock screen according to the user's Windows privacy settings.

Windows manages banner duration, sound, Do Not Disturb, lock-screen visibility, and notification history. These controls are available under **Settings > System > Notifications > Agent Notify**. Banner duration is available under **Settings > Accessibility > Visual effects > Dismiss notifications after this amount of time**.

Run `agent-notify test` to send a real notification. The command confirms delivery to Windows in the terminal; press `Win+N` to inspect Notification Center when the banner is hidden by Windows focus settings.

## Uninstall

```bash
./uninstall.sh
```

The uninstaller removes the Codex and Claude Code integration entries, Windows app identity, notification history, installed logo, and CLI command.

Windows identity can also be managed separately:

```bash
agent-notify setup windows
agent-notify remove windows
```

## Event format

```json
{
  "source": "Worker",
  "project": "api",
  "title": "Optional custom title",
  "message": "Queue drained",
  "level": "info"
}
```

`level` accepts `info`, `warning`, or `error`.

## How Windows notifications work

Agent Notify parses events in WSL and starts a hidden Windows PowerShell 5.1 process. The Windows process uses the registered AUMID and `ToastGeneric` XML to send a native WinRT notification, then exits. Windows manages presentation time, sound, focus rules, and notification-center history.

The complete v0.2 research, architecture, implementation plan, and acceptance criteria are in [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).

## Roadmap

- Notification click activation and project grouping
- Log-file and process monitors
- Feishu and generic remote webhooks

## References

- [Codex Hooks](https://learn.chatgpt.com/docs/hooks)
- [Microsoft app notification content](https://learn.microsoft.com/en-us/windows/apps/develop/notifications/app-notifications/app-notifications-content)
- [Microsoft desktop toast requirements](https://learn.microsoft.com/en-us/windows/win32/shell/enable-desktop-toast-with-appusermodelid)

## License

MIT
