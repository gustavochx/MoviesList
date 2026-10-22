---
paths:
  - "Modules/Experiences/**/*.swift"
  - "MoviesList/**/*.swift"
---

# Design system usage

Feature and app views style themselves only through `DesignSystem` (`Modules/UI`). The design system itself is out of scope here: it defines the tokens.

## Literals → tokens

| For | Use | Never |
|---|---|---|
| spacing, padding | `DSSpacing` | numbers in `.padding(…)` or `spacing:` |
| corner radii | `DSRadius` | numbers in `cornerRadius` |
| colors, shape styles | `DSColor` | `Color(…)`, `Color.x`, `.yellow`, `.primary`, `.secondary` |
| fonts | `DSFont` | `.font(.headline)`, `.font(Font.x)`, `.system(size:)` |

A bare `.padding()` or `.padding(.edge)` is a violation too: name the token, e.g. `.padding(.horizontal, DSSpacing.l)`.

Allowed: dimensions specific to one screen, such as `.frame(width: 88)` or a poster's 60×90, passed into components as values.

## System views → components

| Instead of | Use |
|---|---|
| a full-screen `ProgressView` | `LoadingStateView` |
| a custom `ContentUnavailableView { … }` | `EmptyStateView`, `ErrorStateView` or `LoadFailureView` |
| `AsyncImage` | `RemoteImage`, `ArtworkImage`, `AvatarImage` or `BannerImage` |
| a hand-built star rating | `RatingView` |
| a hand-built section header | `TitledSection` |

Allowed: an inline `ProgressView` (e.g. the load-more footer) and `ContentUnavailableView.search`.

## When the token or component doesn't exist

Add it to `Modules/UI`: generic, SwiftUI only, no domain types or app-specific text. Add a test in `DesignSystemTests` and, for a new component, a row to the design-system table in `docs/architecture.md`. Never fall back to a literal.

## Self-check

Before finishing a view change, run this from the repo root. It must print nothing:

```bash
grep -rnE '\.font\(\s*(\.|Font\.)|\.system\(size|\.(foregroundStyle|foregroundColor|tint|background|fill|stroke|overlay|border|listRowBackground)\(\s*(\.[a-z]|Color)|color:\s*\.[a-z]|\bColor[.(]|\.padding\(\s*(\.[a-zA-Z]+|\[[^]]*\])?\s*\)|\.padding\([^)]*[0-9][^)]*\)|spacing:\s*[0-9]|cornerRadius[:(]\s*[0-9]|\bAsyncImage\b' Modules/Experiences/Sources MoviesList --include='*.swift'
```

It works line by line, so check these by reading the change:
- full-screen `ProgressView`s and hand-built ratings or headers
- typed literals such as `let tint: Color = .yellow`
- calls split across lines, e.g. `.font(` with `.headline` on the next line
