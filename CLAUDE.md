# MoviesList

This project uses specialized iOS agents (`.claude/agents/`). Claude Code auto-delegates to the right one based on the task:

- **ios-lead**: coordinator for multi-concern tasks and architecture decisions
- **ios-architect**: modules, dependencies, where code belongs (View / ViewModel / Interactor / Coordinator / domain)
- **swiftui-expert**: SwiftUI views, state, navigation, accessibility, previews
- **swift-concurrency-expert**: async/await, actors, Sendable, isolation, Swift 6 diagnostics
- **swift-testing-expert**: Swift Testing, fakes, parameterized and async tests
- **ios-reviewer**: cross-cutting review after any change

Subagents run with context forking enabled (`CLAUDE_CODE_FORK_SUBAGENT=1` in `.claude/settings.json`). The orchestrator reads and explores once; specialists inherit that context and focus on their domain. Without the env var they start fresh and re-read files themselves.

### Project conventions for agents

- SwiftUI app. App target iOS 26.5; local packages under `Modules/` keep an iOS 17 floor.
- Swift 6 language mode with complete data-race checking. Default isolation: the app and `Experiences` are `MainActor`; `Interfaces` and `Cores` are nonisolated.
- Use `@Observable` (not `ObservableObject`) for new code. `@unchecked Sendable`, `nonisolated(unsafe)` and `@preconcurrency` need a comment stating the safety invariant.
- MVVM + Coordinators + Interactors (see `docs/architecture.md`): View renders state; ViewModel (`@Observable`, `@MainActor`) talks only to an interactor protocol; Interactor (internal, `Sendable`) calls domain interfaces; Coordinator owns navigation inside the feature; `<Feature>Entry` / `Dependencies` / `Outputs` is the feature's only public API; `AppCoordinator` is the composition root.
- Features import only `*Interface` modules, never other features or concrete cores. Name modules by convention (`<Name>Interface`, `<Name>Feature`, `<Name>Domain`).
- Tests must use Swift Testing (`import Testing`), not XCTest.
- Liquid Glass only when explicitly requested.
- Build and test (prefix with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` if `xcode-select` points at CommandLineTools):
  ```bash
  xcodebuild -project MoviesList.xcodeproj -scheme MoviesList -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
  (cd Modules/Experiences && xcodebuild test -scheme Experiences -destination 'platform=iOS Simulator,name=iPhone 17 Pro')  # same for Interfaces
  (cd Modules/Cores && xcodebuild test -scheme Cores-Package -destination 'platform=iOS Simulator,name=iPhone 17 Pro')  # packages with several products use <Package>-Package
  sh tools/architecture/check.sh
  ```
- Done means: the app builds and its tests pass, every touched package's tests pass, and `check.sh` reports 0 errors.

### Skills

Skills in `.claude/skills/` provide reference material that agents preload. Each skill has a `SKILL.md` and a `references/` directory with detailed guidance. Do not modify skill files — they are upstream dependencies; sources and versions are in `.claude/skills/UPSTREAM.md`. `ios-modularization` is a maintainer-local skill (`~/.claude/skills`), deliberately not vendored: agents use it when it is installed, and `check.sh` skips without it.
