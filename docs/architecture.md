# MoviesList architecture

The app is split into local Swift packages under `Modules/`. The app target is the composition root.

## Setup

Movies come from [TMDB](https://developer.themoviedb.org/docs/getting-started). The API key is never committed:

```bash
cp Config/Secrets.example.xcconfig Config/Secrets.xcconfig   # gitignored
# then set TMDB_API_KEY in Config/Secrets.xcconfig
```

`Config/MoviesList.xcconfig` includes the secrets file, and `Config/Info.plist` exposes the value as `TMDBAPIKey`, which `AppCoordinator` reads. Without the file the app still builds and shows an "API key missing" state. A key shipped in an app binary can be extracted, so treat it as a public client key.

| Package | Modules | Type | Who may import it |
|---|---|---|---|
| `Modules/Interfaces` | `MoviesDomainInterface` | interface (protocols + models) | everyone |
| `Modules/Cores` | `MoviesDomain` | core · domain (concrete) | the app and tests only |
| `Modules/Cores` | `MoviesData` | core · data source (TMDB `MovieRepository`) | the app and tests only |
| `Modules/Experiences` | `MovieListFeature` | experience (a user flow) | the app only |

Features depend on interfaces, never on concrete cores or on other features. `sh tools/architecture/check.sh` enforces the rules, classifying modules by their names and folders. It runs the validator of the maintainer-local ios-modularization skill (`~/.claude/skills`, not part of this repo) and is skipped when that skill isn't installed.

There is no `modules.json` catalog or CODEOWNERS yet: with one app and one owner, naming conventions carry all the information. Add a catalog (the ios-modularization skill's `catalog.py init`) when a second app needs scopes, a rule exception has to be recorded, a module's name can't reveal its category, or several teams own modules (then generate CODEOWNERS from it).

## Presentation pattern: MVVM + Coordinators + Interactors

```
AppCoordinator (app)  ──builds──▶  <Feature>FeatureEntry(dependencies, outputs)
                                         │
                                  <Feature>Coordinator   in-feature navigation (Route, path)
                                         │ builds
                     View ──▶ ViewModel ──▶ Interactor ──▶ <Domain>Service (interface) ──▶ Repository (interface) ◀── data module
```

- **View** (SwiftUI): renders `ViewModel.state`, forwards user intents. No logic.
- **ViewModel** (`@Observable`, `@MainActor`): presentation state and intent handling. Depends on an interactor protocol only.
- **Interactor** (`<Scene>Interacting` + `<Scene>Interactor`, internal to the feature): the scene's logic — what to load, filtering, sorting, combining domain calls. Talks to the domain through its interface.
- **Coordinator** (one per feature, internal): builds interactors and view models, owns navigation between the feature's screens.
- **Entry / Dependencies / Outputs** (public): the feature's only API. `Dependencies` are protocols supplied by the app; `Outputs` are closures for leaving the feature.
- **AppCoordinator** (app target): creates concrete implementations, builds each feature's entry and handles navigation between features.

Business rules shared by several features belong in the domain (`MoviesDomain`), not in an interactor.

### Folder layout inside a feature

```
Sources/MovieListFeature/
  MovieListFeatureEntry.swift   public API (Entry / Dependencies / Outputs)
  MovieListCoordinator.swift    navigation across the feature's flows
  List/                         the list flow: view, view model, interactor, row model
    Components/                 the list's subviews, one per file
  Detail/                       the detail flow (kept free of List/ types, so it can become its own module)
  Shared/                       views and helpers used by more than one flow
  TestDoubles/                  #if DEBUG SpyingStubs for the feature's internal protocols
```

Tests mirror it: `Tests/MovieListFeatureTests/List/`, `Detail/`, and feature-level tests (coordinator) at the root.

## Adding a feature

With the maintainer-local ios-modularization skill installed:

```bash
python3 ~/.claude/skills/ios-modularization/scripts/scaffold_module.py \
  --root . --package-dir Modules/Experiences --name MovieDetail --type experience \
  --scope app:MoviesList --owner @gustavochx
```

Then add the printed product to `Modules/Experiences/Package.swift`, add a `MovieDetailInteractor`, and wire the entry in `AppCoordinator`. Without the skill, copy the shape of `MovieListFeature` (Entry / Dependencies / Outputs, coordinator, interactor, view model, view, tests).

Coding standards and the skills that define them: see [CLAUDE.md](../CLAUDE.md).
