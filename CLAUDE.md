# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository: MoviesList, a SwiftUI app that lists, searches and details TMDB movies.

This project uses specialized iOS agents (`.claude/agents/`). Claude Code auto-delegates to the right one based on the task:

- **ios-lead**: coordinator for multi-concern tasks and architecture decisions
- **ios-architect**: modules, dependencies, where code belongs (View / ViewModel / Interactor / Coordinator / domain)
- **swiftui-expert**: SwiftUI views, state, navigation, accessibility, previews
- **swift-concurrency-expert**: async/await, actors, Sendable, isolation, Swift 6 diagnostics
- **swift-testing-expert**: Swift Testing, fakes, parameterized and async tests
- **ios-reviewer**: cross-cutting review after any change

Project commands (`.claude/commands/`), run only when you type them:

- **/ios-review [base]**: reviews the branch against `main` (or `base`) inside the `ios-reviewer` agent, on Opus
- **/branch-report [base ref]**: builds an `ios-change-report` for the branch's latest work, on Sonnet (needs the maintainer-local skill)

Subagents run with context forking enabled (`CLAUDE_CODE_FORK_SUBAGENT=1` in `.claude/settings.json`). The orchestrator reads and explores once; specialists inherit that context and focus on their domain. Without the env var they start fresh and re-read files themselves.

### Packages

Local Swift packages under `Modules/`, linked into the app as folder references:

- `Interfaces` → `MoviesDomainInterface`: models, the `MoviesService` and `MovieRepository` protocols, and `#if DEBUG` fixtures and SpyingStubs next to them.
- `Cores` → `MoviesDomain` (`LiveMoviesService`), `MoviesData` (TMDB repository, `HTTPClient`, DTOs and mappers) and `FoundationExtensions` (foundational Foundation extensions).
- `Experiences` → `MovieListFeature`, with `List/` and `Detail/` flows plus `Shared/` helpers.
- `UI` → `DesignSystem`.

`AppCoordinator` (app target) reads `TMDBAPIKey` from Info.plist and wires `LiveMoviesService(repository: TMDBMovieRepository(...))` into `MovieListFeatureEntry`.

### Project conventions for agents

- SwiftUI app. App target iOS 26.5; local packages under `Modules/` keep an iOS 17 floor.
- Swift 6 language mode with complete data-race checking. Default isolation: the app and `Experiences` are `MainActor`; `Interfaces` and `Cores` are nonisolated.
- Use `@Observable` (not `ObservableObject`) for new code. `@unchecked Sendable`, `nonisolated(unsafe)` and `@preconcurrency` need a comment stating the safety invariant.
- MVVM + Coordinators + Interactors (see `docs/architecture.md`): View renders state; ViewModel (`@Observable`, `@MainActor`) talks only to an interactor protocol; Interactor (internal, `Sendable`) calls domain interfaces; Coordinator owns navigation inside the feature; `<Feature>Entry` / `Dependencies` / `Outputs` is the feature's only public API; `AppCoordinator` is the composition root.
- Features import only `*Interface` modules and the `DesignSystem` UI module, never other features or concrete cores (foundational cores such as `FoundationExtensions` are the exception). Name modules by convention (`<Name>Interface`, `<Name>Feature`, `<Name>Domain`).
- Tests must use Swift Testing (`import Testing`), not XCTest.
- Liquid Glass only when explicitly requested.
- Styling goes through `DesignSystem` (`Modules/UI`); the token and component rules and their self-check are in `.claude/rules/design-system.md`. Keep domain types and app-specific texts out of it; it imports only SwiftUI.
- View files: `body` returns `content`, and the pieces live as computed properties in a `private extension <View>` under `// MARK: UI Building Blocks`. Anything that reads its own frequently changing state (e.g. a load-more footer) becomes its own `View` type instead, so SwiftUI re-evaluates only that piece. Each flow's subviews go in `<Flow>/Components/` (`List/Components/`, `Detail/Components/`), one type per file. A view model keeps its private helpers in a `private extension` under `// MARK: Private helpers`.
- Setup: copy `Config/Secrets.example.xcconfig` to `Config/Secrets.xcconfig` (gitignored) and set `TMDB_API_KEY`. Without it the app builds but shows "TMDB API key missing". Never open or print `Config/Secrets.xcconfig`. Once per clone, run `git config core.hooksPath tools/git-hooks`: the git hooks (and the Claude hooks in `.claude/hooks`) block commits and pushes that contain the TMDB key or the secrets file, and Claude's reads of the secrets file, `--no-verify`, and `gh pr create` without a filled `--body-file` PR template.
- Build and test (prefix with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` if `xcode-select` points at CommandLineTools):
  ```bash
  xcodebuild -project MoviesList.xcodeproj -scheme MoviesList -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test  # app + MoviesListTests (.integration)
  (cd Modules/Experiences && xcodebuild test -scheme Experiences -destination 'platform=iOS Simulator,name=iPhone 17 Pro')  # scheme = package name; same for Interfaces
  (cd Modules/UI && xcodebuild test -scheme UI -destination 'platform=iOS Simulator,name=iPhone 17 Pro')
  (cd Modules/Cores && xcodebuild test -scheme Cores-Package -destination 'platform=iOS Simulator,name=iPhone 17 Pro')  # several products: <Package>-Package runs them all
  # one suite: add -only-testing:<TestTarget>/<Suite>, e.g. -only-testing:MovieListFeatureTests/LoadFailureTests
  sh tools/architecture/check.sh
  sh tools/lint.sh   # SwiftLint, strict (brew install swiftlint)
  ```
- Done means: the app builds and its tests pass, every touched package's tests pass, `check.sh` reports 0 errors, and `tools/lint.sh` reports 0 violations.

### Skills

Skills in `.claude/skills/` provide reference material that agents preload. Each skill has a `SKILL.md` and a `references/` directory with detailed guidance. Do not modify skill files — they are upstream dependencies; sources and versions are in `.claude/skills/UPSTREAM.md`. `ios-modularization` is a maintainer-local skill (`~/.claude/skills`), deliberately not vendored: agents use it when it is installed, and `check.sh` skips without it.
