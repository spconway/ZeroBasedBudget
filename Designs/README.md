# ZeroBasedBudget - Design Themes

Three complete visual theme sets for the ZeroBasedBudget iOS app, each with distinct personality and aesthetic.

## 📁 Theme Overview

### 1. Neon Ledger 🌟
**Path**: `Designs/NeonLedger/`

**Vibe**: Cyberpunk financial ledger with neon accents and glows
- **Base Colors**: Graphite/ink (#0A0A0A, #121212)
- **Primary**: Electric teal (#00E5CC)
- **Accent**: Magenta (#FF006E)
- **Personality**: High-tech, futuristic, edgy
- **Best For**: Users who want a bold, distinctive aesthetic with neon energy

**Complete Files**:
- ✅ `tokens.json` - Full design system tokens
- ✅ `accounts.svg` - Accounts view mockup
- ✅ `budget-planning.svg` - Budget view with Ready to Assign
- ✅ `transactions.svg` - Transaction log
- ✅ `analysis.svg` - Analysis with charts
- ✅ `Colors.xcassets.md` - iOS color assets (ready-to-paste)
- ✅ `Theme.swift` - Complete SwiftUI implementation
- ✅ `SFSymbols.md` - SF Symbols catalog
- ✅ `README.md` - Full usage notes, contrast table, accessibility

---

### 2. Midnight Mint 🌊
**Path**: `Designs/MidnightMint/`

**Vibe**: Calm, professional modern fintech
- **Base Colors**: Near-black with blue tint (#0B0E11, #14181C)
- **Primary**: Seafoam mint (#3BFFB4)
- **Accent**: Soft teal (#14B8A6)
- **Personality**: Professional, trustworthy, restrained
- **Best For**: Users who want a polished, calming fintech aesthetic

**Files Included**:
- ✅ `tokens.json` - Full design system tokens
- ✅ `budget-planning.svg` - Budget view with Ready to Assign (key view)
- ✅ `README.md` - Condensed usage notes, contrast table

---

### 3. Ultraviolet Slate ⚡
**Path**: `Designs/UltravioletSlate/`

**Vibe**: Bold, energetic with saturated colors
- **Base Colors**: Charcoal with warmth (#1A1A1F, #222228)
- **Primary**: Deep violet (#6366F1)
- **Accent**: Vivid cyan (#22D3EE)
- **Personality**: Bold, modern, high-energy
- **Best For**: Users who want saturated colors and geometric structure

**Files Included**:
- ✅ `tokens.json` - Full design system tokens
- ✅ `budget-planning.svg` - Budget view with Ready to Assign (key view)
- ✅ `README.md` - Condensed usage notes, contrast table

---

## 🎨 Quick Comparison

| Feature | Neon Ledger | Midnight Mint | Ultraviolet Slate |
|---------|-------------|---------------|-------------------|
| **Darkness** | Pure black | Blue-tinted black | Warm charcoal |
| **Primary Color** | Electric teal | Seafoam mint | Deep violet |
| **Accent Color** | Magenta | Soft teal | Vivid cyan |
| **Borders** | Subtle + glow | Very subtle | Thin hairlines |
| **Energy Level** | High (neon) | Low (calm) | High (bold) |
| **Best For** | Edgy, cyberpunk | Professional, fintech | Modern, energetic |
| **WCAG AA** | ✅ All pass | ✅ All pass | ✅ All pass |

## 📊 All Themes Feature

### Common Elements
- **Platform**: iOS 26+, iPhone only (390×844)
- **Grid**: 8pt base unit
- **Touch Targets**: 44×44pt minimum
- **Typography**: SF Pro Display/Text with Dynamic Type
- **Icons**: SF Symbols throughout
- **Accessibility**: WCAG 2.1 AA compliant
- **YNAB Principle**: Prominent "Ready to Assign" banner

### Design Tokens
All themes include complete `tokens.json` with:
- Colors (bg, surface, primary, accent, semantic)
- Typography scale (12pt - 34pt)
- Spacing (xs through xl)
- Corner radius (8pt - 28pt)
- States (focus, pressed, disabled)
- YNAB-specific colors (readyToAssignBg, readyToAssignText)

## 🚀 Implementation Guide

### Quick Start
1. **Choose a theme** based on desired aesthetic
2. **Review the README.md** in that theme folder for specifics
3. **Import tokens.json** to understand the design system
4. **Reference SVG mockups** for implementation guidance
5. **Use provided assets**:
   - Neon Ledger has full iOS implementation (`Theme.swift`, `Colors.xcassets.md`)
   - Midnight Mint & Ultraviolet Slate use same structure, substitute colors

### Integration Steps
1. Copy color values from `tokens.json` to iOS asset catalog
2. Implement theme structure (use `Neon Ledger/Theme.swift` as template)
3. Apply to views following mockup guidelines
4. Test accessibility with Xcode Accessibility Inspector
5. Validate on physical iPhone 17 device

## 🎯 Choosing the Right Theme

### Choose Neon Ledger if:
- You want a distinctive, memorable aesthetic
- Your users appreciate bold, techy designs
- You want neon glows and cyberpunk vibes
- Target audience: Tech-savvy millennials/Gen Z

### Choose Midnight Mint if:
- You want a professional, trustworthy feel
- Your users prefer calm, restrained interfaces
- You need a fintech-like aesthetic
- Target audience: Professional users, minimalists

### Choose Ultraviolet Slate if:
- You want bold, saturated colors
- Your users want high-energy, modern design
- You like geometric structure with hairline borders
- Target audience: Design-conscious users

## ✅ Quality Assurance

All themes have been validated for:
- ✅ WCAG 2.1 AA contrast compliance
- ✅ Realistic budget data (no lorem ipsum)
- ✅ Ready to Assign banner prominence (YNAB principle)
- ✅ Self-contained SVGs (no external assets)
- ✅ Production-ready color values
- ✅ 44×44pt minimum touch targets
- ✅ 8pt grid system throughout

## 📝 Notes

- **Most Complete**: Neon Ledger has all 9 files including full SwiftUI implementation
- **Condensed**: Midnight Mint & Ultraviolet Slate focus on tokens and key mockup
- **Extensibility**: All themes use same structure; easy to create additional views
- **Customization**: Tokens are semantic, making customization straightforward

## 🔗 Resources

- **Apple HIG**: https://developer.apple.com/design/human-interface-guidelines/
- **SF Symbols App**: https://developer.apple.com/sf-symbols/
- **WCAG Guidelines**: https://www.w3.org/WAI/WCAG21/quickref/
- **SwiftUI Documentation**: https://developer.apple.com/documentation/swiftui

---

**Created**: November 2025
**Version**: 1.0
**For**: ZeroBasedBudget iOS App (YNAB methodology)

**Next Steps**: Choose your preferred theme and begin implementation!
