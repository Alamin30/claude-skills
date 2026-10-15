# claude-skills

Claude Code plugins by Alamin30.

## Install

```
/plugin marketplace add Alamin30/claude-skills
/plugin install standup@alamin-skills
```

## Plugins

### standup

Builds a daily standup report, ready to paste into Slack, from your own git commits.

```
/standup              # today
/standup yesterday
/standup 2026-10-14
```

It scans the repos one level under `~/Sites`, `~/Projects`, `~/projects`, `~/code`, `~/dev`, `~/src` and `~/work`, whichever exist. It keeps only commits whose author matches your `git config --global user.name` or `user.email`. It folds related commits into one line, drops ones that cancel each other out, and asks about work that left no commit.

```
Date: Oct 15, 2026

feat: migrate the web app to Nuxt 4 / Vue 3.
fix: settings page shows the wrong plan after an upgrade - hotfix
chore: move the frontend onto the main server - live
```

Configure it with environment variables, for example in `~/.zshrc` or in `env` of `~/.claude/settings.json`:

| Variable | Meaning |
|---|---|
| `STANDUP_DIRS` | Colon-separated folders to scan instead of the defaults, e.g. `~/Sites:~/work` |
| `STANDUP_AUTHORS` | Colon-separated extra author names or emails, e.g. a work email |

Works on macOS and Linux. Only local commits are visible, so run `git fetch` in a repo if you committed from another machine.

## License

MIT
