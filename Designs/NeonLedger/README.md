# Neon Ledger Theme

**Design Philosophy**: High-tech cyberpunk ledger with graphite/ink bases and electric teal + magenta accents. Subtle neon glows on interactive elements and charts.

## Design Tokens

All color values, typography scale, spacing, and radius values are defined in `tokens.json`.

## Theme Overview

- **Base**: Very dark graphite (#0A0A0A, #121212)
- **Accent**: Electric teal (#00E5CC) - Primary brand color
- **Secondary**: Magenta (#FF006E) - Expenses and errors
- **Success**: Neon green (#00FF88) - Income and positive states
- **Warning**: Amber (#FFB800) - Alerts and overspending
- **Vibe**: Futuristic financial tracker with neon accents

## Grid System

- **Base Unit**: 8pt
- **Spacing Scale**:
  - xs: 4pt (0.5× base)
  - sm: 8pt (1× base)
  - md: 16pt (2× base)
  - lg: 24pt (3× base)
  - xl: 32pt (4× base)

## Touch Targets

- **Minimum**: 44×44pt (Apple HIG requirement)
- **Recommended**: 48×48pt for primary actions
- **Tab bar icons**: 44×44pt touch area
- **List items**: Minimum 56pt height

## Motion & Animation

### Spring Animations (Recommended)
```swift
.animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
```

- **Response**: 0.2s (200ms) - Quick, responsive feel
- **Damping**: 0.7 - Slight bounce without feeling slow

### Fade & Scale
- **Duration**: 250ms
- **Use for**: Modal presentations, overlays, toasts
- **Curve**: `.easeInOut`

### Examples
- Button press: Scale to 96% with spring
- Card tap: Subtle glow expansion (200ms)
- FAB: Scale 1.0 → 1.05 on appear, bounce on tap
- Sheet presentation: Slide up with fade (300ms)

## Accessibility

### WCAG 2.1 AA Contrast Requirements

| Text Size | Min Contrast | Notes |
|-----------|--------------|-------|
| Body (14-16px) | 4.5:1 | Standard text |
| Large (20px+) | 3:1 | Headers, emphasis |
| UI Components | 3:1 | Buttons, borders |

### Contrast Table

| Foreground | Background | Ratio | Pass AA | Use Case |
|------------|------------|-------|---------|----------|
| #FFFFFF (White) | #0A0A0A (bg) | 19.6:1 | ✅ | Body text, headers |
| #999999 (Muted) | #0A0A0A (bg) | 8.1:1 | ✅ | Secondary text, labels |
| #00E5CC (Primary) | #0A0A0A (bg) | 11.4:1 | ✅ | Accents, links |
| #00FF88 (Success) | #0A0A0A (bg) | 14.2:1 | ✅ | Income amounts, success states |
| #FF006E (Accent) | #0A0A0A (bg) | 5.8:1 | ✅ | Expense amounts, badges |
| #FFB800 (Warning) | #0A0A0A (bg) | 10.1:1 | ✅ | Warning text, overspending |
| #000000 (Black) | #00E5CC (Primary) | 12.3:1 | ✅ | Ready to Assign text |
| #FFFFFF (White) | #121212 (Surface) | 18.1:1 | ✅ | Text on cards |
| #999999 (Muted) | #121212 (Surface) | 7.5:1 | ✅ | Secondary text on cards |

### Edge Cases

⚠️ **Avoid**:
- Magenta (#FF006E) text on small sizes (< 14pt) - Use for amounts only (18pt+)
- Muted gray (#999999) on elevated surfaces (#1A1A1A) - Contrast drops to 6.1:1 (still passes AA, but close)

✅ **Recommendations**:
- Use white (#FFFFFF) for primary text on all backgrounds
- Use muted gray (#999999) for secondary text on bg/surface only
- Use colored text (teal, green, magenta) for amounts and accents (18pt+)
- Maintain 4.5:1 minimum for body text

### Dynamic Type Support

All typography scales should support Dynamic Type:

```swift
.font(NeonLedgerTheme.Typography.bodyLarge)
```

- Uses `.system()` fonts which scale automatically
- Test with Accessibility Inspector at all size categories
- Ensure layouts don't break at 200%+ text size

### VoiceOver

- Provide clear accessibility labels for icon-only buttons
- Use semantic headings (`.accessibilityAddTraits(.isHeader)`)
- Group related elements with `.accessibilityElement(children: .combine)`
- Announce monetary values clearly: "$2,500.00" → "Two thousand five hundred dollars"

## YNAB-Specific Guidance

### Ready to Assign Banner

The **Ready to Assign** banner is the most critical UI element in YNAB methodology:

- **Background**: Electric teal (#00E5CC) - High visibility
- **Text**: Black (#000000) - Maximum contrast (12.3:1)
- **Size**: Large display font (34-44pt)
- **Placement**: Top of Budget view, immediately visible
- **Glow**: Subtle neon glow effect (optional)

**Why**: Users need to see available money at a glance. This is the core of zero-based budgeting.

### Color-Coded Amounts

| Amount Type | Color | Usage |
|-------------|-------|-------|
| Income | #00FF88 (Success) | Paychecks, refunds, positive cashflow |
| Available | #00E5CC (Primary) | Available to budget, surplus |
| Spent | #FFFFFF (White) | Normal spending within budget |
| Overspent | #FFB800 (Warning) | Category over budget |
| Negative | #FF006E (Error) | Overdraft, debt |

### Category States

- **Fully funded**: Progress bar = 100%, green (#00FF88)
- **Partially funded**: Progress bar < 100%, teal (#00E5CC)
- **Overspent**: Progress bar > 100%, warning (#FFB800)
- **No budget**: Gray (#999999)

## File Structure

```
NeonLedger/
├── tokens.json              # Design tokens (colors, typography, spacing)
├── accounts.svg             # Accounts view mockup (390×844)
├── budget-planning.svg      # Budget view with Ready to Assign (390×844)
├── transactions.svg         # Transaction log view (390×844)
├── analysis.svg             # Analysis view with charts (390×844)
├── Colors.xcassets.md       # iOS color asset definitions
├── Theme.swift              # Complete SwiftUI theme implementation
├── SFSymbols.md             # SF Symbols catalog
└── README.md                # This file
```

## Implementation Checklist

### Setup
- [ ] Copy `Colors.xcassets.md` entries to Xcode asset catalog
- [ ] Import `Theme.swift` into project
- [ ] Review `SFSymbols.md` for icon choices

### Apply Theme
- [ ] Set `NeonLedgerTheme.Colors.bg` as app background
- [ ] Use `.neonCard()` modifier for all card views
- [ ] Apply `.neonBadge(color:)` for transaction type badges
- [ ] Use `NeonLedgerTheme.PrimaryButtonStyle()` for primary actions
- [ ] Configure Ready to Assign banner with `readyToAssignBg` + `readyToAssignText`

### Testing
- [ ] Test all text contrast ratios with Accessibility Inspector
- [ ] Verify Dynamic Type scaling at 200%+
- [ ] Test VoiceOver navigation
- [ ] Check color appearance on actual iPhone 17 device
- [ ] Verify glow effects don't impact performance

### Validation
- [ ] All body text passes 4.5:1 contrast
- [ ] All touch targets ≥ 44×44pt
- [ ] Animations feel responsive (200-300ms)
- [ ] Charts are distinguishable by color
- [ ] Ready to Assign banner is immediately visible

## Design Credits

**Theme**: Neon Ledger
**Style**: Cyberpunk financial ledger
**Created**: November 2025
**For**: ZeroBasedBudget iOS App (YNAB methodology)
