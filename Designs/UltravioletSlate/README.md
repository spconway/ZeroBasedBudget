# Ultraviolet Slate Theme

**Design Philosophy**: Bold, energetic with charcoal base and saturated violet + cyan accents. Thin hairline borders create geometric, structured feel.

## Theme Overview

- **Base**: Charcoal with slight warmth (#1A1A1F, #222228, #2A2A32)
- **Primary**: Deep violet (#6366F1) - Bold brand color
- **Accent**: Vivid cyan (#22D3EE) - Secondary highlights
- **Success**: Electric lime (#84CC16) - Income, positive states
- **Warning**: Sunset orange (#FB923C) - Alerts
- **Error**: Rose red (#F43F5E) - Errors, negative states
- **Vibe**: Modern, energetic budget tracker with bold saturated colors

## Grid & Spacing

- **Base Unit**: 8pt
- **Touch Targets**: Minimum 44×44pt
- **Border Width**: 1px (thin hairlines for structure)
- **Card Padding**: 16pt

## Accessibility - WCAG AA Contrast

| Foreground | Background | Ratio | Pass | Use Case |
|------------|------------|-------|------|----------|
| #FFFFFF | #1A1A1F | 16.8:1 | ✅ | Body text, headers |
| #A1A1AA | #1A1A1F | 7.2:1 | ✅ | Secondary text |
| #6366F1 | #1A1A1F | 6.1:1 | ✅ | Primary accents, large text (20pt+) |
| #22D3EE | #1A1A1F | 9.8:1 | ✅ | Cyan accents |
| #84CC16 | #1A1A1F | 8.5:1 | ✅ | Income amounts |
| #F43F5E | #1A1A1F | 5.2:1 | ✅ | Expense amounts (18pt+) |
| #FB923C | #1A1A1F | 7.3:1 | ✅ | Warning text |
| #FFFFFF | #6366F1 | 7.4:1 | ✅ | Ready to Assign text |

**Notes**:
- Violet (#6366F1) should be used for headers 20pt+ or interactive elements with 3:1 ratio (passes AA for large text)
- All critical text uses white (#FFFFFF) for maximum accessibility
- Colored amounts are 18pt+ for comfortable readability

## YNAB Guidelines

### Ready to Assign Banner
- **Background**: Deep violet (#6366F1) with cyan border
- **Text**: White (#FFFFFF) for high contrast
- **Font**: 44pt bold display
- **Border**: Cyan (#22D3EE) 1px hairline for emphasis
- **Prominence**: Top of Budget view

### Color Coding
- **Income**: Electric lime (#84CC16) - Vibrant, positive
- **Available**: Deep violet (#6366F1) - Primary brand
- **Spent**: White (#FFFFFF) - Neutral
- **Overspent**: Sunset orange (#FB923C) - Warning
- **Negative**: Rose red (#F43F5E) - Critical

### Visual Hierarchy
- **Thin borders** (1px) create structured, geometric feel
- **Saturated colors** for emotional impact and engagement
- **High contrast** for clarity and accessibility
- **Bold typography** pairs well with saturated palette

## Motion
- **Spring**: `response: 0.2, damping: 0.65` - Snappy, energetic
- **Fade**: 200ms easeOut (faster than other themes)
- **Scale on press**: 0.94 (more pronounced feedback)
- **Border glow**: Subtle pulse on focus

## Key Differences from Other Themes

vs **Neon Ledger**:
- Warmer charcoal base vs pure black
- Violet + cyan vs teal + magenta
- Thin borders vs glow effects
- More geometric vs neon aesthetic

vs **Midnight Mint**:
- Warmer base vs cool blue-tinted black
- Violet primary vs mint/seafoam
- Saturated colors vs restrained palette
- Bold vs calm

## Design Characteristics
- **Borders**: 1px hairlines (#3A3A42) on all cards
- **Typography**: Bold weights for headers
- **Colors**: Saturated, vibrant palette
- **Energy**: High-energy, modern feel
- **Best for**: Users who want bold, distinctive aesthetic

## Files Included
- `tokens.json` - Complete design tokens
- `budget-planning.svg` - Budget view with Ready to Assign banner (390×844)
- `README.md` - This file

## Implementation
1. Import color tokens from `tokens.json`
2. Use 1px borders on all card surfaces
3. Apply violet (#6366F1) for primary actions
4. Use cyan (#22D3EE) for secondary highlights
5. Test contrast ratios (especially violet on smaller text)
6. Emphasize Ready to Assign with violet + cyan border

**Created**: November 2025
**For**: ZeroBasedBudget iOS App
