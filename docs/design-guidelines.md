# GitPulse iOS Design Guidelines

## Overview

GitPulse is a GitHub user browser for iOS. Design follows **Apple Human Interface Guidelines (HIG)** with a clean, professional aesthetic inspired by GitHub's brand identity. Built with **UIKit** (programmatic, no SwiftUI, no Storyboard).

---

## Color System

### Primary Palette

| Token | Light Mode | Dark Mode | Usage |
|-------|-----------|-----------|-------|
| `Colors/primary` | #0969DA | #58A6FF | Links, active states, tint color |
| `Colors/primaryLight` | #DDF4FF | #0D1117 | Primary backgrounds, selected states |
| `Colors/secondary` | #656D76 | #8B949E | Secondary text, subtitles |
| `Colors/accent` | #0550AE | #79C0FF | Accent highlights, badges |

### Semantic Colors

| Token | Light Mode | Dark Mode | Usage |
|-------|-----------|-----------|-------|
| `Colors/success` | #1A7F37 | #3FB950 | Success states, online indicators |
| `Colors/warning` | #9A6700 | #D29922 | Warning states |
| `Colors/error` | #CF222E | #F85149 | Error states, destructive actions |
| `Colors/info` | #0969DA | #58A6FF | Informational elements |

### Neutral Colors

| Token | Light Mode | Dark Mode | Usage |
|-------|-----------|-----------|-------|
| `Colors/background` | #FFFFFF | #0D1117 | Screen backgrounds |
| `Colors/backgroundSecondary` | #F6F8FA | #161B22 | Grouped table backgrounds |
| `Colors/surface` | #FFFFFF | #21262D | Cards, elevated surfaces |
| `Colors/surfaceBorder` | #D0D7DE | #30363D | Card borders, separators |
| `Colors/textPrimary` | #1F2328 | #E6EDF3 | Primary text (titles, body) |
| `Colors/textSecondary` | #656D76 | #8B949E | Secondary text (subtitles, metadata) |
| `Colors/textTertiary` | #818B98 | #6E7681 | Placeholder text, disabled |
| `Colors/separator` | #D8DEE4 | #21262D | Table separators |

### Implementation (UIKit)

```swift
// Asset Catalog approach: Colors.xcassets
// Each color set has "Any Appearance" and "Dark" variants

// Usage in code
extension UIColor {
    static let gpPrimary = UIColor(named: "Colors/primary")!
    static let gpBackground = UIColor(named: "Colors/background")!
    static let gpTextPrimary = UIColor(named: "Colors/textPrimary")!
    static let gpTextSecondary = UIColor(named: "Colors/textSecondary")!
    static let gpSurface = UIColor(named: "Colors/surface")!
    static let gpSurfaceBorder = UIColor(named: "Colors/surfaceBorder")!
    static let gpSeparator = UIColor(named: "Colors/separator")!
    static let gpError = UIColor(named: "Colors/error")!
}
```

### Tint Color
- Navigation bar tint: `Colors/primary`
- Tab bar tint: `Colors/primary`
- UIRefreshControl tint: `Colors/primary`

---

## Typography

### SF Pro Type Scale

All text uses **SF Pro** via the system font API. Map to UIFont.TextStyle for Dynamic Type support.

| iOS TextStyle | Weight | Size (default) | Line Height | Usage |
|---------------|--------|----------------|-------------|-------|
| `.largeTitle` | Bold | 34pt | 41pt | Navigation large titles |
| `.title1` | Bold | 28pt | 34pt | Screen section headers |
| `.title2` | Bold | 22pt | 28pt | User detail name |
| `.title3` | Semibold | 20pt | 25pt | Card group headers |
| `.headline` | Semibold | 17pt | 22pt | Card title (username) |
| `.body` | Regular | 17pt | 22pt | Main body text |
| `.callout` | Regular | 16pt | 21pt | Stats values |
| `.subheadline` | Regular | 15pt | 20pt | GitHub URL in cards |
| `.footnote` | Regular | 13pt | 18pt | Metadata labels |
| `.caption1` | Regular | 12pt | 16pt | Timestamps, badges |
| `.caption2` | Regular | 11pt | 13pt | Tiny labels |

### Implementation

```swift
// Always use preferred font for Dynamic Type support
label.font = UIFont.preferredFont(forTextStyle: .headline)
label.adjustsFontForContentSizeCategory = true

// Bold variant
label.font = UIFont.preferredFont(forTextStyle: .title2)

// Monospaced digits for stats
let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .callout)
label.font = UIFont.monospacedDigitSystemFont(ofSize: descriptor.pointSize, weight: .semibold)
```

### Typography Usage Map

| Element | TextStyle | Weight | Color |
|---------|-----------|--------|-------|
| Navigation large title | `.largeTitle` | Bold | textPrimary |
| Navigation inline title | `.headline` | Semibold | textPrimary |
| Username in card | `.headline` | Semibold | textPrimary |
| GitHub URL in card | `.subheadline` | Regular | primary (link) |
| User detail name | `.title2` | Bold | textPrimary |
| Stats number | `.title3` | Semibold | textPrimary |
| Stats label | `.footnote` | Regular | textSecondary |
| Location text | `.body` | Regular | textPrimary |
| Blog link | `.body` | Regular | primary |
| Error title | `.headline` | Semibold | textPrimary |
| Error message | `.body` | Regular | textSecondary |
| Retry button | `.headline` | Semibold | white on primary |

---

## Spacing System

### Base Grid: 4pt

| Token | Value | Usage |
|-------|-------|-------|
| `space-1` | 4pt | Minimal gaps, icon-label spacing |
| `space-2` | 8pt | Compact component padding |
| `space-3` | 12pt | List cell vertical padding |
| `space-4` | 16pt | Standard screen margins, card padding |
| `space-5` | 20pt | Section spacing |
| `space-6` | 24pt | Large section gaps |
| `space-8` | 32pt | Screen top/bottom padding |
| `space-10` | 40pt | Hero section spacing |
| `space-12` | 48pt | Large separator areas |

### Screen Margins
- iPhone: 16pt horizontal
- iPad: 20pt horizontal (or readable content guide)

### Implementation

```swift
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
}
```

---

## Iconography (SF Symbols)

### Required Icons

| Purpose | SF Symbol Name | Rendering | Weight |
|---------|---------------|-----------|--------|
| Followers | `person.2.fill` | Hierarchical | Medium |
| Following | `person.badge.plus` | Hierarchical | Medium |
| Location | `mappin.and.ellipse` | Monochrome | Medium |
| Blog/Link | `link` | Monochrome | Medium |
| Back | `chevron.left` | Monochrome | Medium |
| Error | `exclamationmark.triangle.fill` | Multicolor | Medium |
| Empty state | `person.crop.circle.badge.questionmark` | Hierarchical | Medium |
| Retry | `arrow.clockwise` | Monochrome | Medium |
| External link | `arrow.up.right.square` | Monochrome | Medium |
| Loading more | `ellipsis.circle` | Monochrome | Medium |
| GitHub | `link.circle.fill` | Hierarchical | Medium |
| Network error | `wifi.slash` | Monochrome | Medium |

### Icon Sizing

| Context | Point Size | Usage |
|---------|-----------|-------|
| Navigation bar | 17pt | Bar button items |
| Cell accessory | 13pt | Disclosure indicators |
| Inline with text | 15pt | Stats row icons |
| Empty state | 48pt | Centered illustrations |
| Error state | 40pt | Error view icon |

### Implementation

```swift
let image = UIImage(systemName: "person.2.fill")?
    .withConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .medium))
```

---

## Component Specifications

### UserCard (UITableViewCell)

```
+--[16pt margin]------------------------------------------+
|  +------+  [12pt]  +----------------------------+       |
|  |      |           | Username (.headline)       |       |
|  | 48pt |           | [4pt gap]                  |       |
|  |avatar|           | github.com/user (.subhead)  |       |
|  |      |           | tint: primary, underline    |       |
|  +------+           +----------------------------+       |
+--[16pt margin]------------------------------------------+
```

| Property | Value |
|----------|-------|
| Cell height | Auto (estimated ~72pt) |
| Avatar size | 48 x 48pt |
| Avatar corner radius | 24pt (circle) |
| Avatar border | 0.5pt, Colors/surfaceBorder |
| Content padding | 16pt horizontal, 12pt vertical |
| Avatar-to-text gap | 12pt |
| Username-to-URL gap | 4pt |
| Separator inset | 76pt left (aligns with text) |
| Selection style | `.default` (gray highlight) |
| Accessory | `disclosureIndicator` |

### UserDetailsHeader

```
+--------------------------------------------+
|              [32pt top padding]             |
|          +------------------+               |
|          |                  |               |
|          |     96 x 96      |               |
|          |     avatar       |               |
|          |                  |               |
|          +------------------+               |
|              [16pt gap]                     |
|         Username (.title2, bold)            |
|              [4pt gap]                      |
|        @login (.subheadline, secondary)     |
|              [24pt gap]                     |
|  +------ Stats Row (centered) -------+     |
|  | [icon] 120    |    [icon] 45      |     |
|  | Followers     |    Following      |     |
|  +-----------------------------------+     |
|              [24pt gap]                     |
|  [pin icon]  San Francisco, CA              |
|              [12pt gap]                     |
|  [link icon] https://blog.example.com       |
|              [24pt gap]                     |
|  [ View on GitHub ] (full-width button)     |
|              [16pt bottom]                  |
+--------------------------------------------+
```

| Property | Value |
|----------|-------|
| Avatar size | 96 x 96pt |
| Avatar corner radius | 48pt (circle) |
| Avatar shadow | 0, 2, 8, rgba(0,0,0,0.1) |
| Avatar border | 2pt, Colors/surfaceBorder |
| Name font | .title2, bold |
| Login font | .subheadline, textSecondary |
| Stats number | .title3, semibold |
| Stats label | .footnote, textSecondary |
| Stats divider | 1pt vertical line, separator color, 20pt height |
| Info row icon size | 15pt |
| Info row icon color | textSecondary |
| Info row gap | icon-to-text 8pt, row-to-row 12pt |
| Blog link color | primary, underlined |

### StatsRow

```
+----[40pt]----+--[1pt divider]--+----[40pt]----+
|   [icon]     |                 |    [icon]    |
|    120       |                 |      45      |
|  Followers   |                 |   Following  |
+--------------+-----------------+--------------+
```

| Property | Value |
|----------|-------|
| Total min width | 200pt |
| Each stat column | Center-aligned |
| Icon size | 15pt, textSecondary |
| Number font | .title3, semibold, textPrimary |
| Label font | .footnote, textSecondary |
| Divider | 1pt wide, separator color, 20pt tall |
| Icon-to-number gap | 4pt |
| Number-to-label gap | 2pt |

### LoadingView

| Property | Value |
|----------|-------|
| Style | `UIActivityIndicatorView.Style.medium` |
| Color | Colors/primary |
| Full-screen | Centered in view |
| Footer | 44pt height, centered indicator |

### ErrorView

```
+--------------------------------------------+
|                                            |
|         [exclamationmark.triangle]         |
|              48pt, error color              |
|              [16pt gap]                     |
|         "Something went wrong"              |
|         (.headline, textPrimary)            |
|              [8pt gap]                      |
|      "Check your connection and try"        |
|      "again." (.body, textSecondary)        |
|              [24pt gap]                     |
|          [ Try Again ] button               |
|              primary bg, white text         |
|              height: 44pt                   |
|              corner radius: 10pt            |
|              width: 200pt                   |
+--------------------------------------------+
```

### EmptyStateView

```
+--------------------------------------------+
|                                            |
|    [person.crop.circle.badge.questionmark]  |
|              48pt, textTertiary             |
|              [16pt gap]                     |
|          "No Users Found"                   |
|         (.headline, textPrimary)            |
|              [8pt gap]                      |
|    "Pull down to refresh the list."         |
|       (.body, textSecondary)                |
+--------------------------------------------+
```

---

## Elevation & Shadows

### iOS Shadow System (lighter than Material)

| Level | Usage | offset | blur | color | opacity |
|-------|-------|--------|------|-------|---------|
| none | Flat surfaces | - | - | - | - |
| subtle | Cards in list | (0, 1) | 3 | black | 0.06 |
| medium | Avatar on detail | (0, 2) | 8 | black | 0.10 |
| high | Modals, popovers | (0, 4) | 12 | black | 0.15 |

### Implementation

```swift
// Subtle card shadow
view.layer.shadowColor = UIColor.black.cgColor
view.layer.shadowOffset = CGSize(width: 0, height: 1)
view.layer.shadowRadius = 3
view.layer.shadowOpacity = 0.06
view.layer.masksToBounds = false

// Use shadowPath for performance
view.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
```

### Corner Radii

| Element | Radius |
|---------|--------|
| Cards | 12pt |
| Avatar (list) | 24pt (half of 48) |
| Avatar (detail) | 48pt (half of 96) |
| Buttons | 10pt |
| Text fields | 8pt |
| Bottom sheets | 16pt (top corners) |

---

## Animation Specs

### Cell Appear Animation
- Duration: 0.3s
- Curve: `.easeOut`
- Transform: translateY(20pt) -> translateY(0), opacity 0 -> 1
- Staggered: 0.05s delay per cell

### Navigation Transitions
- Use default UINavigationController push/pop (0.35s)
- Interactive back gesture (standard iOS)

### Pull-to-Refresh
- Standard UIRefreshControl behavior
- Tint: Colors/primary

### Loading States
- Skeleton shimmer: 1.5s linear infinite, left-to-right gradient sweep
- Activity indicator: System default spin animation

### Error State Transition
- Fade in: 0.25s, `.easeInOut`
- Button press: 0.1s scale to 0.97, spring back

---

## Layout Patterns

### Navigation Architecture
- `UINavigationController` with large titles
- User List: `.prefersLargeTitles = true`
- User Detail: `.largeTitleDisplayMode = .never` (inline title)

### User List Screen

```swift
// UITableView with diffable data source
tableView.style = .plain
tableView.separatorInset = UIEdgeInsets(top: 0, left: 76, bottom: 0, right: 0)
tableView.estimatedRowHeight = 72
tableView.rowHeight = UITableView.automaticDimension
tableView.refreshControl = UIRefreshControl()
```

### User Detail Screen

```swift
// UIScrollView with vertical stack
scrollView.alwaysBounceVertical = true
scrollView.contentInsetAdjustmentBehavior = .automatic
```

---

## Adaptive Layouts

### iPhone (Compact Width)
- Single column, full width
- Navigation push for details
- Standard margins (16pt)

### iPad (Regular Width)
- Split view controller: list left, detail right
- `UISplitViewController` with `preferredDisplayMode = .oneBesideSecondary`
- Primary width: 320-400pt
- Supplementary: remaining space
- Readable content guide for detail view

### Implementation

```swift
// Detect size class
override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    if traitCollection.horizontalSizeClass == .regular {
        // iPad layout
    } else {
        // iPhone layout
    }
}
```

---

## Dark Mode Support

### Automatic Adaptation
- Use semantic colors from Asset Catalog with "Any" and "Dark" appearances
- Use `.systemBackground`, `.secondarySystemBackground` as fallbacks
- All custom colors MUST have dark variants

### Testing
- Settings > Developer > Dark Appearance
- Xcode: Environment Overrides > Appearance

### Rules
- Never hard-code color literals in code
- Always use named colors or system colors
- Test all screens in both modes
- Ensure images have dark mode variants where needed

---

## Accessibility

### Dynamic Type
- All text uses `UIFont.preferredFont(forTextStyle:)`
- Set `adjustsFontForContentSizeCategory = true`
- Test with largest accessibility sizes
- Ensure layouts don't break at XXXL size

### VoiceOver
- All interactive elements have `accessibilityLabel`
- Avatar: "Avatar of {username}"
- Stats: "{count} followers", "{count} following"
- Links: "Blog: {url}" with `.link` trait
- Cards: Combine as single accessible element

### Minimum Touch Targets
- 44 x 44pt for all tappable elements
- Buttons: minimum 44pt height
- Table cells: minimum 44pt height

### Color Contrast
- WCAG 2.1 AA minimum (4.5:1 normal text, 3:1 large text)
- All color pairs verified:
  - textPrimary on background: 15.3:1 (light), 13.1:1 (dark)
  - textSecondary on background: 5.2:1 (light), 4.6:1 (dark)
  - primary on background: 4.6:1 (light), 5.8:1 (dark)

### Reduce Motion
```swift
if UIAccessibility.isReduceMotionEnabled {
    // Skip cell appear animations
    // Use crossfade instead of slide transitions
}
```

---

## Best Practices

### DO
- Use system colors and named asset colors
- Support Dynamic Type with preferred fonts
- Test with VoiceOver enabled
- Use diffable data sources for lists
- Respect safe area insets
- Use `layoutMarginsGuide` for content alignment
- Implement interactive back gesture (default with navigation controller)
- Use `UIRefreshControl` for pull-to-refresh
- Cache images with `NSCache` or library (Kingfisher/SDWebImage)

### DON'T
- Hard-code colors as hex literals
- Use fixed font sizes (breaks Dynamic Type)
- Skip dark mode testing
- Ignore safe area (notch, home indicator)
- Use small touch targets (< 44pt)
- Override standard navigation gestures
- Block main thread with network calls
- Use storyboards or XIBs (project uses programmatic UI)

---

## File Organization (Design Assets)

```
GitPulse/Assets.xcassets/
├── Colors/
│   ├── primary.colorset/
│   ├── primaryLight.colorset/
│   ├── secondary.colorset/
│   ├── accent.colorset/
│   ├── background.colorset/
│   ├── backgroundSecondary.colorset/
│   ├── surface.colorset/
│   ├── surfaceBorder.colorset/
│   ├── textPrimary.colorset/
│   ├── textSecondary.colorset/
│   ├── textTertiary.colorset/
│   ├── separator.colorset/
│   ├── success.colorset/
│   ├── warning.colorset/
│   ├── error.colorset/
│   └── info.colorset/
├── AppIcon.appiconset/
└── Images/
    └── placeholder-avatar.imageset/
```
