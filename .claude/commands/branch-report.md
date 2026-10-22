---
description: Generate an ios-change-report for the latest work on the current branch (runs on Sonnet)
argument-hint: "[base ref, default: merge base with origin/main]"
model: sonnet
context: inline
disable-model-invocation: true
---

Generate a before/after change report for the current branch of MoviesList with the `ios-change-report` skill.

0. The skill is maintainer-local (`~/.claude/skills/ios-change-report`), not part of this repo. If `~/.claude/skills/ios-change-report/scripts/capture.py` doesn't exist, say so and stop.
1. Run `git fetch -q origin`. The "before" ref is the argument if one was given (`$ARGUMENTS`), otherwise `git merge-base HEAD origin/main`. If `git status --short` isn't empty, the "after" side includes uncommitted changes: say so in the report.
2. Pick the work dir `~/Library/Caches/ios-change-reports/MoviesList-<YYYY-MM-DD>-<branch name without the feature/ prefix>`. Each shell call starts fresh, so write that literal path wherever `$WORKDIR` appears below (or start each command with `WORKDIR=<path> &&`). Then run:
   - `python3 ~/.claude/skills/ios-change-report/scripts/capture.py before --repo . --workdir "$WORKDIR" --retroactive-ref <before ref>`
   - `python3 ~/.claude/skills/ios-change-report/scripts/capture.py after --repo . --workdir "$WORKDIR"`
3. Write `$WORKDIR/manifest.json` (format in the skill's SKILL.md) only from facts you checked:
   - `request` and `summary` from the commit messages (`git log --format='%s%n%b' <before ref>..HEAD`) and the diff
   - `changes` per area from `git diff --stat <before ref>` and reading the changed files
   - `verification` only for checks you actually ran: the package results that `capture.py after` printed, plus `sh tools/architecture/check.sh`
   - everything you didn't confirm goes in `not_verified`; never claim a check you didn't run
4. Run `python3 ~/.claude/skills/ios-change-report/scripts/build_report.py --workdir "$WORKDIR"`. Never display or print `Config/Secrets.xcconfig`. The only allowed check that the TMDB key doesn't appear in `report.html` is `sh tools/secrets/leak-count.sh "$WORKDIR/report.html"`, which prints just a count (expect 0; the script reads the key itself, so it never appears on screen).
5. Open `report.html` in the browser pane (or with `open` if that's unavailable) and reply with its path, the before/after refs, and what's in "not verified".
