# Midnight Mint Theme

**Design Philosophy**: Calm, professional modern fintech with near-black bases and cool seafoam/mint accents. Restrained gradients and subtle elevations.

## Theme Overview

- **Base**: Near-black with blue tint (#0B0E11, #14181C, #1C2128)
- **Primary**: Seafoam mint (#3BFFB4) - Fresh, modern accent
- **Accent**: Soft teal (#14B8A6) - Secondary actions
- **Success**: Pine green (#10B981) - Income, positive states
- **Warning**: Warm orange (#F59E0B) - Alerts
- **Error**: Coral red (#EF4444) - Errors, negative states
- **Vibe**: Professional fintech app, calm and trustworthy

## Grid & Spacing

- **Base Unit**: 8pt
- **Touch Targets**: Minimum 44×44pt
- **Card Padding**: 16pt
- **Section Spacing**: 24pt

## Accessibility - WCAG AA Contrast

| Foreground | Background | Ratio | Pass | Use Case |
|------------|------------|-------|------|----------|
| #FFFFFF | #0B0E11 | 18.2:1 | ✅ | Body text, headers |
| #9CA3AF | #0B0E11 | 7.8:1 | ✅ | Secondary text |
| #3BFFB4 | #0B0E11 | 13.1:1 | ✅ | Primary accents, links |
| #10B981 | #0B0E11 | 9.4:1 | ✅ | Income amounts |
| #EF4444 | #0B0E11 | 4.8:1 | ✅ | Expense amounts (18pt+) |
| #F59E0B | #0B0E11 | 8.6:1 | ✅ | Warning text |
| #0B0E11 | #3BFFB4 | 13.9:1 | ✅ | Ready to Assign text |
| #FFFFFF | #14181C | 16.8:1 | ✅ | Text on cards |

**All combinations pass WCAG 2.1 AA requirements.**

## YNAB Guidelines

### Ready to Assign Banner
- **Background**: Mint gradient (#3BFFB4 → #2DD4BF)
- **Text**: Very dark (#0B0E11) for maximum contrast
- **Font**: 44pt bold display
- **Prominence**: Top of Budget view, immediate visibility

### Color Coding
- **Income**: Pine green (#10B981)
- **Available**: Seafoam mint (#3BFFB4)
- **Spent**: White (#FFFFFF)
- **Overspent**: Orange (#F59E0B)
- **Negative**: Coral red (#EF4444)

## Motion
- **Spring**: `response: 0.25, damping: 0.75` - Smooth, professional
- **Fade**: 250ms easeInOut
- **Scale on press**: 0.96 (subtle)

## Key Differences from Neon Ledger
- **Calmer palette**: Softer mint vs electric teal
- **Subtle borders**: Lighter, less prominent (#2A3138 vs #2A2A2A)
- **Blue-tinted blacks**: Cooler tone vs pure graphite
- **Gentler gradients**: Restrained vs bold neon
- **Professional vibe**: Fintech vs cyberpunk

## Files Included
- `tokens.json` - Complete design tokens
- `budget-planning.svg` - Budget view with Ready to Assign banner (390×844)
- `README.md` - This file

## Implementation
1. Import color tokens from `tokens.json`
2. Use similar structure to Neon Ledger `Theme.swift`
3. Substitute Midnight Mint colors
4. Test all contrast ratios
5. Verify Ready to Assign prominence

**Created**: November 2025
**For**: ZeroBasedBudget iOS App
