---
name: standup
description: Build a daily standup report, ready to paste into Slack, from the user's own git commits across their local repos. Use when the user says /standup, asks for a standup report, or asks what they worked on today, yesterday, or on a given date.
---

# Standup report

Build a standup report from the user's own commits, in the format below, ready to paste into Slack.

## Arguments

- none: today
- `yesterday`: the previous day
- a date (`2026-10-14`, `Oct 14`): that day

## Steps

1. Resolve the target day as `YYYY-MM-DD` in local time.

2. Collect the commits by running the script that ships with this skill. It sits in `scripts/` under this skill's base directory:

   ```bash
   bash "<skill base directory>/scripts/collect.sh" 2026-10-15
   ```

   The script matches the user's `git config --global user.name` and `user.email`. It scans repos one level under `~/Sites`, `~/Projects`, `~/code`, `~/dev`, `~/src` and `~/work`, whichever exist. For each repo it prints the commits, the PRs merged that day and the current branch.

   Two environment variables change what it scans:
   - `STANDUP_DIRS`: colon-separated folders to scan instead of the defaults.
   - `STANDUP_AUTHORS`: colon-separated extra author names or emails, for commits made under another identity.

   If the script prints an error, show it to the user and tell them which variable to set.

3. Turn commits into report lines:
   - Write one line per piece of work, not per commit. Fold follow-up fixes into the line for the feature.
   - Drop commits that cancel each other out (e.g. `add: base url` then `removed: base url`). Drop WIP, typo and merge-only commits too.
   - Start each line with a conventional prefix: `feat:`, `fix:`, `chore:`, `refactor:`, `perf:`, `docs:`.
   - Name the project when the subject doesn't make it clear.
   - Keep each line short and lowercase after the prefix. End it with a period.
   - Add ` - live` when the work is deployed to production, and ` - hotfix` for an urgent production fix. Add them only when the user said so or a commit or PR shows it. Never guess.

4. Output the report in exactly this format, inside a code block:

   ```
   Date: Oct 15, 2026

   feat: migrate the web app to Nuxt 4 / Vue 3.
   fix: settings page shows the wrong plan after an upgrade - hotfix
   chore: move the frontend onto the main server - live
   ```

   The date format is `Mon D, YYYY`. Write the report lines in English.

5. Under the block, in the language the user is writing in, say in one or two lines:
   - which repos the commits came from,
   - which commits were left out and why,
   - which work is still on an unmerged branch.

   Then ask whether to add work that left no commit: server setup, migrations, deploys, reviews, meetings. Much of the work worth reporting never shows up in git.

6. When the user adds items, print the whole block again with the new lines in it. Don't print only the new lines.

## Notes

- If no commits are found, say so and ask what they worked on. Never invent items.
- Only local commits are visible. Work pushed from another machine shows up only after a `git fetch` in that repo.
