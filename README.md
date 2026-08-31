# Agent Notify

Send Codex, Claude Code, and shell task completion events from WSL to the Windows notification area.

发送 Codex、Claude Code 和后台命令的完成事件到 Windows 右下角通知区域。

## Features

- Windows notification balloons with info, warning, and error levels
- Codex `Stop` hook integration for CLI and the VS Code extension
- Claude Code `Stop` hook integration
- Generic JSON event input for other agents and scripts
- Command wrapper that preserves the original exit code
- Zero Python package dependencies
- Hidden PowerShell execution, diagnostics, error logs, and configuration backups

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

The Codex integration uses the official `Stop` lifecycle hook in `~/.codex/hooks.json`. Codex sends the hook event as JSON on standard input after each completed turn. The hook returns immediately after launching the hidden Windows notification process.

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
```

Successful Agent hook calls are recorded at `~/.local/state/agent-notify/events.log`. Hook errors are recorded at `~/.local/state/agent-notify/errors.log`.

## Uninstall

```bash
./uninstall.sh
```

The uninstaller removes the Codex and Claude Code integration entries together with the installed command.

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

## Roadmap

- Native Windows Toast registration and notification-center history
- Log-file and process monitors
- Feishu and generic remote webhooks

## References

- [Codex Hooks](https://learn.chatgpt.com/docs/hooks)
- [Microsoft NotifyIcon documentation](https://learn.microsoft.com/en-us/dotnet/desktop/winforms/controls/notifyicon-component-overview-windows-forms)
- [Microsoft desktop toast requirements](https://learn.microsoft.com/en-us/windows/win32/shell/enable-desktop-toast-with-appusermodelid)

## License

MIT
