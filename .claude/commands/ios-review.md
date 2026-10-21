---
description: Review the current branch against its base with the ios-reviewer standards (runs on Opus)
argument-hint: "[base branch, default main]"
model: opus
context: fork
agent: ios-reviewer
background: false
disable-model-invocation: true
---

Review the work on the current branch of MoviesList. Do not edit any file.

Base branch: if an argument was given (`$ARGUMENTS`), use it; otherwise use `main`.

1. Scope: run `git fetch -q origin`, then review `git diff <base>...HEAD` plus uncommitted and untracked changes (`git status`, `git diff HEAD`). Never open or print `Config/Secrets.xcconfig`.
2. Run the checks (commands in CLAUDE.md; prefix with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` if `xcode-select` points at CommandLineTools):
   - app tests (`-scheme MoviesList test`)
   - tests of every touched package (`Interfaces`, `Cores-Package`, `Experiences`)
   - `sh tools/architecture/check.sh`
3. Review against CLAUDE.md and the preloaded skills:
   - SwiftUI Correctness Checklist
   - concurrency: isolation per module, Sendable boundaries, invariant comments on escape hatches
   - architecture: View → ViewModel → Interactor → domain interface; features import only `*Interface` modules; `Detail/` doesn't depend on `List/`
   - tests: new behavior covered with Swift Testing through fixtures and SpyingStubs
   - the Verification section of `.github/pull_request_template.md`
4. Report, under 500 words:
   - findings most severe first, each with file:line, the rule it breaks, a concrete failure scenario and the smallest fix; say plainly when there are none
   - what you ran and the results (test counts, check.sh summary)
