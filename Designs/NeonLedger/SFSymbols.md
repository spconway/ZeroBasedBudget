# Neon Ledger SF Symbols

## Tab Bar Icons

| Tab | Symbol | Weight | Notes |
|-----|--------|--------|-------|
| Accounts | `circle.fill` | medium | Filled circle for active state |
| Budget | `square.grid.2x2.fill` | medium | Grid for budget allocation |
| Transactions | `list.bullet` | medium | List icon for transaction log |
| Analysis | `chart.pie.fill` | medium | Pie chart for spending analysis |
| Settings | `gearshape.fill` | medium | Standard settings icon |

## Action Buttons

| Action | Symbol | Weight | Notes |
|--------|--------|--------|-------|
| Add Transaction | `plus` | bold | Plus icon in FAB |
| Add Account | `plus.circle.fill` | medium | Add new account |
| Add Category | `plus.square.fill` | medium | Add budget category |
| Edit | `pencil` | medium | Edit mode |
| Delete | `trash.fill` | medium | Delete action (warning color) |
| Search | `magnifyingglass` | medium | Search transactions |
| Filter | `line.3.horizontal.decrease.circle` | medium | Filter options |
| Export | `square.and.arrow.up` | medium | Export data |

## Status Indicators

| Status | Symbol | Weight | Color | Notes |
|--------|--------|--------|-------|-------|
| Success/Income | `checkmark.circle.fill` | medium | #00FF88 | Positive state |
| Warning | `exclamationmark.triangle.fill` | medium | #FFB800 | Warning state |
| Error | `xmark.circle.fill` | medium | #FF006E | Error state |
| Info | `info.circle.fill` | medium | #00E5CC | Information |

## Transaction Type Badges

| Type | Symbol | Weight | Color | Notes |
|------|--------|--------|-------|-------|
| Income | `arrow.down.circle.fill` | medium | #00FF88 | Money in |
| Expense | `arrow.up.circle.fill` | medium | #FF006E | Money out |
| Transfer | `arrow.left.arrow.right.circle.fill` | medium | #00E5CC | Between accounts |

## Category Icons (Optional Suggestions)

| Category Type | Symbol | Notes |
|---------------|--------|-------|
| Housing | `house.fill` | Rent, mortgage |
| Groceries | `cart.fill` | Food shopping |
| Transportation | `car.fill` | Gas, transit |
| Utilities | `bolt.fill` | Electric, water, etc. |
| Dining | `fork.knife` | Restaurants |
| Entertainment | `tv.fill` | Streaming, movies |
| Health | `heart.fill` | Medical, fitness |
| Savings | `banknote.fill` | Savings goals |
| Debt | `creditcard.fill` | Debt payments |
| Shopping | `bag.fill` | General purchases |
| Subscriptions | `repeat.circle.fill` | Recurring bills |

## Navigation Elements

| Element | Symbol | Weight | Notes |
|---------|--------|--------|-------|
| Back | `chevron.left` | semibold | Navigation back |
| Forward | `chevron.right` | semibold | Navigation forward |
| Month Previous | `chevron.left` | semibold | Previous month |
| Month Next | `chevron.right` | semibold | Next month |
| Close/Dismiss | `xmark` | medium | Close modal |
| Done | `checkmark` | semibold | Confirm action |

## Account Type Icons

| Type | Symbol | Notes |
|------|--------|-------|
| Checking | `dollarsign.circle.fill` | Default checking |
| Savings | `banknote.fill` | Savings account |
| Cash | `creditcard.fill` | Cash on hand |
| Credit Card | `creditcard.fill` | Credit accounts |

## Implementation Notes

- **Size**: Use `.system(size: X)` for custom sizing
- **Weight**: Prefer `.medium` for body icons, `.semibold` for emphasis, `.bold` for primary actions
- **Rendering Mode**: Use `.renderingMode(.template)` for color customization
- **Accessibility**: Always provide accessibility labels for icon-only buttons
- **Dynamic Type**: SF Symbols scale automatically with Dynamic Type

## Example Usage

```swift
// Tab bar icon
Image(systemName: "chart.pie.fill")
    .symbolRenderingMode(.monochrome)
    .foregroundColor(NeonLedgerTheme.Colors.primary)

// Action button with icon
Button(action: addTransaction) {
    Image(systemName: "plus")
        .font(.system(size: 20, weight: .bold))
        .foregroundColor(NeonLedgerTheme.Colors.onPrimary)
}

// Status badge with icon
HStack {
    Image(systemName: "checkmark.circle.fill")
        .foregroundColor(NeonLedgerTheme.Colors.success)
    Text("Paid")
}
```

## Resources

- [SF Symbols App](https://developer.apple.com/sf-symbols/) - Browse all available symbols
- [Apple HIG - SF Symbols](https://developer.apple.com/design/human-interface-guidelines/sf-symbols) - Design guidelines
