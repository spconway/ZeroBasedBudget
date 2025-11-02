# User Testing Guide - Post-MVP Enhancements

**Version**: 1.1.0
**Date**: November 2, 2025
**Purpose**: Comprehensive testing guide for all post-MVP enhancements (Priorities 1-3)

## Overview

This guide provides step-by-step test scenarios to verify all new features work correctly with real budget data. Complete all test scenarios in order to ensure full functionality.

---

## Pre-Testing Setup

### Test Data Preparation

Before testing, prepare the following test data:

1. **Annual Salary**: $75,000
2. **Other Income**: $5,000
3. **Current Available Funds**: $3,500
4. **Budget Categories** (with due dates):
   - Rent: $1,200 (Due: 1st of month)
   - Utilities: $150 (Due: 15th of month)
   - Groceries: $400 (No due date)
   - Car Payment: $350 (Due: 5th of month)
   - Insurance: $200 (Due: 10th of month)
   - Entertainment: $100 (No due date)

5. **Sample Transactions**:
   - Income: Paycheck $3,000 (1st of current month)
   - Expense: Rent $1,200 (2nd of current month)
   - Expense: Groceries $85.50 (3rd of current month)
   - Expense: Gas $45.00 (5th of current month)

---

## Enhancement 1.1: Yearly Income Display

### Test Scenario 1.1.1: Verify Section Header
**Steps:**
1. Open app and navigate to Budget Planning tab
2. Locate the income section

**Expected Results:**
- ✅ Section header reads "Yearly Income" (not "Monthly Income")
- ✅ Section appears after "Current Available" section

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 1.1.2: Verify Field Labels
**Steps:**
1. In the Yearly Income section, observe field labels

**Expected Results:**
- ✅ First field labeled "Annual Salary" (not "Salary")
- ✅ Second field labeled "Other Income"
- ✅ Third field labeled "Total Income" (read-only)

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 1.1.3: Verify Footer Text
**Steps:**
1. Scroll to view the footer text below Yearly Income section

**Expected Results:**
- ✅ Footer displays: "Enter your annual salary for reference and planning purposes."
- ✅ Text appears in caption font, secondary color

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 1.1.4: Test Data Entry
**Steps:**
1. Tap "Annual Salary" field
2. Enter: $75,000
3. Tap "Other Income" field
4. Enter: $5,000
5. Observe "Total Income" field

**Expected Results:**
- ✅ Annual Salary displays: $75,000.00
- ✅ Other Income displays: $5,000.00
- ✅ Total Income displays: $80,000.00 (calculated automatically)
- ✅ Total Income is bold/semibold weight

**Status:** [ ] Pass  [ ] Fail

---

## Enhancement 1.2: Current Available Section

### Test Scenario 1.2.1: Verify Section Position
**Steps:**
1. Navigate to Budget Planning tab
2. Observe section order

**Expected Results:**
- ✅ "Current Available" section appears FIRST (top of form)
- ✅ Section appears before "Yearly Income" section

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 1.2.2: Verify Section Content
**Steps:**
1. Locate Current Available section
2. Observe fields

**Expected Results:**
- ✅ Header reads: "Current Available"
- ✅ First field labeled "Accounts" (editable)
- ✅ Second field labeled "Total" (read-only, bold)
- ✅ Footer displays explanatory text about available money

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 1.2.3: Test Calculation Accuracy
**Steps:**
1. Tap "Accounts" field
2. Enter: $3,500
3. Observe "Total" field

**Expected Results:**
- ✅ Total displays: $3,500.00 (matches Accounts input)
- ✅ Amount formatted as currency with $ and 2 decimals
- ✅ Total is bold/semibold weight

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 1.2.4: Test Currency Formatting
**Steps:**
1. Clear Accounts field
2. Enter various amounts:
   - 1234.5 → should display $1,234.50
   - 999 → should display $999.00
   - 10000.99 → should display $10,000.99

**Expected Results:**
- ✅ All amounts display with $ prefix
- ✅ All amounts show 2 decimal places
- ✅ Amounts over $999 include comma separators

**Status:** [ ] Pass  [ ] Fail

---

## Enhancement 2.1: Month Indicator with Navigation

### Test Scenario 2.1.1: Verify Month Display
**Steps:**
1. Navigate to Budget Planning tab
2. Locate month indicator at very top of form

**Expected Results:**
- ✅ Month indicator visible at top (above Current Available section)
- ✅ Text format: "Budgeting for: [Month Year]" (e.g., "Budgeting for: November 2025")
- ✅ Text is bold and larger (title2 font)
- ✅ Text is horizontally centered

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 2.1.2: Verify Navigation Arrows
**Steps:**
1. Observe month indicator section

**Expected Results:**
- ✅ Left chevron (◀) appears on left side (blue color)
- ✅ Right chevron (▶) appears on right side (blue color)
- ✅ Both chevrons are tap-able buttons
- ✅ Month text centered between arrows

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 2.1.3: Test Previous Month Navigation
**Steps:**
1. Note current month display (e.g., "November 2025")
2. Tap left chevron (◀)
3. Observe month display

**Expected Results:**
- ✅ Month changes to previous month (e.g., "October 2025")
- ✅ Change is instant (no delay)
- ✅ Year updates correctly when crossing year boundary (e.g., Jan → Dec of previous year)

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 2.1.4: Test Next Month Navigation
**Steps:**
1. From any month, tap right chevron (▶)
2. Observe month display

**Expected Results:**
- ✅ Month changes to next month
- ✅ Change is instant
- ✅ Year updates correctly when crossing year boundary (e.g., Dec → Jan of next year)

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 2.1.5: Test Multiple Navigation Clicks
**Steps:**
1. Tap left chevron 3 times
2. Note the month
3. Tap right chevron 3 times
4. Observe final month

**Expected Results:**
- ✅ Each click moves one month
- ✅ Returns to original month after 3 left + 3 right
- ✅ No glitches or skipped months

**Status:** [ ] Pass  [ ] Fail

---

## Enhancement 2.2: Due Date Field for Expenses

### Test Scenario 2.2.1: Add Category with Due Date
**Steps:**
1. Navigate to Budget Planning tab
2. Tap + button in Fixed Expenses section
3. Enter category details:
   - Name: "Rent"
   - Amount: $1,200
4. Observe "Due Date (Optional)" section
5. Toggle "Set Due Date" ON
6. Select date: 1st of current month
7. Tap Save

**Expected Results:**
- ✅ "Due Date (Optional)" section visible
- ✅ Toggle switch appears
- ✅ DatePicker appears when toggle is ON
- ✅ DatePicker hidden when toggle is OFF
- ✅ Category saves successfully

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 2.2.2: Verify Due Date Display in List
**Steps:**
1. After adding "Rent" category with due date
2. Locate "Rent" in Fixed Expenses list
3. Observe the category row

**Expected Results:**
- ✅ Category name "Rent" appears on top line
- ✅ Due date appears below name in smaller caption font (e.g., "Nov 1")
- ✅ Due date format is "MMM d" (e.g., "Nov 1", "Dec 15")
- ✅ Due date is secondary/gray color
- ✅ Amount still appears on right side

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 2.2.3: Add Category WITHOUT Due Date
**Steps:**
1. Add new category:
   - Name: "Groceries"
   - Amount: $400
2. Leave "Set Due Date" toggle OFF
3. Tap Save
4. Locate "Groceries" in list

**Expected Results:**
- ✅ Category name appears on single line
- ✅ NO due date shown below name
- ✅ Amount appears on right
- ✅ Row height is smaller (no extra line for date)

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 2.2.4: Edit Category to Add Due Date
**Steps:**
1. Tap existing "Groceries" category (no due date)
2. In edit sheet, toggle "Set Due Date" ON
3. Select date: 15th of current month
4. Tap Save
5. Observe category in list

**Expected Results:**
- ✅ Edit sheet shows toggle and DatePicker
- ✅ Due date now appears below category name
- ✅ Date displays correctly (e.g., "Nov 15")

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 2.2.5: Edit Category to Remove Due Date
**Steps:**
1. Tap category with due date (e.g., "Groceries")
2. Toggle "Set Due Date" OFF
3. Tap Save
4. Observe category in list

**Expected Results:**
- ✅ Toggle removes DatePicker from edit sheet
- ✅ Due date disappears from list display
- ✅ Category row returns to single-line height

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 2.2.6: Verify Due Date Persistence
**Steps:**
1. Add multiple categories with due dates
2. Force quit the app (swipe up in app switcher)
3. Reopen the app
4. Navigate to Budget Planning tab
5. Observe categories

**Expected Results:**
- ✅ All due dates persist correctly
- ✅ Dates display in correct format
- ✅ No data loss

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 2.2.7: Test Due Date Across All Expense Types
**Steps:**
1. Add categories with due dates in:
   - Fixed Expenses (e.g., Rent - Nov 1)
   - Variable Expenses (e.g., Utilities - Nov 15)
   - Quarterly Expenses (e.g., Insurance - Nov 10)
2. Observe all sections

**Expected Results:**
- ✅ Due dates work in Fixed Expenses
- ✅ Due dates work in Variable Expenses
- ✅ Due dates work in Quarterly Expenses
- ✅ Format consistent across all types

**Status:** [ ] Pass  [ ] Fail

---

## Enhancement 3.1: Tap-to-Edit Transactions

### Test Scenario 3.1.1: Verify Tap Functionality
**Steps:**
1. Navigate to Transactions tab
2. Add a sample transaction if none exist
3. Tap anywhere on a transaction row

**Expected Results:**
- ✅ Edit sheet appears immediately
- ✅ Sheet shows transaction details
- ✅ All fields pre-populated with current values

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 3.1.2: Verify Swipe-to-Edit Removed
**Steps:**
1. In Transactions tab
2. Swipe left on any transaction

**Expected Results:**
- ✅ Only DELETE button appears (red, trash icon)
- ✅ NO EDIT button visible (blue pencil should not appear)
- ✅ Swipe action shows single button only

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 3.1.3: Verify Swipe-to-Delete Preserved
**Steps:**
1. Swipe left on a transaction
2. Tap Delete button
3. Confirm deletion if prompted

**Expected Results:**
- ✅ Delete button appears (red, trash icon)
- ✅ Transaction deletes successfully
- ✅ Transaction removed from list
- ✅ Running balance recalculates

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 3.1.4: Test Edit and Save
**Steps:**
1. Tap a transaction to open edit sheet
2. Modify amount (e.g., change $100 to $125)
3. Tap Save

**Expected Results:**
- ✅ Edit sheet dismisses
- ✅ Transaction shows updated amount
- ✅ Running balance recalculates correctly
- ✅ Changes persist

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 3.1.5: Test Edit and Cancel
**Steps:**
1. Tap a transaction to open edit sheet
2. Modify any field
3. Tap Cancel

**Expected Results:**
- ✅ Edit sheet dismisses
- ✅ Transaction unchanged
- ✅ No data modified

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario 3.1.6: Test Multiple Sequential Edits
**Steps:**
1. Tap transaction #1 → Edit → Save
2. Tap transaction #2 → Edit → Save
3. Tap transaction #3 → Edit → Cancel

**Expected Results:**
- ✅ Each tap opens correct transaction
- ✅ Edits save correctly
- ✅ Cancel works correctly
- ✅ No interaction conflicts

**Status:** [ ] Pass  [ ] Fail

---

## Integration Testing

### Test Scenario INT-1: End-to-End Budget Setup
**Steps:**
1. Start with fresh app (or clear existing data)
2. Set Current Available: $3,500
3. Set Annual Salary: $75,000
4. Set Other Income: $5,000
5. Navigate to November 2025 using month arrows
6. Add 5 budget categories with due dates
7. Add 4 transactions
8. Verify all Summary calculations

**Expected Results:**
- ✅ All data entry works smoothly
- ✅ Navigation responsive
- ✅ Calculations accurate
- ✅ No crashes or errors

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario INT-2: Data Persistence
**Steps:**
1. Complete end-to-end budget setup
2. Force quit app
3. Reopen app
4. Verify all data

**Expected Results:**
- ✅ Current Available amount persists
- ✅ Yearly income values persist
- ✅ Selected month persists (or resets to current month - acceptable)
- ✅ All categories with due dates persist
- ✅ All transactions persist

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario INT-3: Month Navigation with Data
**Steps:**
1. With budget data entered
2. Navigate backward 2 months
3. Navigate forward 3 months
4. Return to current month

**Expected Results:**
- ✅ Navigation smooth at all times
- ✅ Data remains intact
- ✅ No performance degradation
- ✅ Month display always correct

**Status:** [ ] Pass  [ ] Fail

---

## Edge Case Testing

### Test Scenario EDGE-1: Large Numbers
**Steps:**
1. Enter Annual Salary: $999,999.99
2. Enter Current Available: $100,000.50
3. Add category with amount: $50,000

**Expected Results:**
- ✅ All amounts display correctly with commas
- ✅ No truncation or overflow
- ✅ Currency format maintained

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario EDGE-2: Small Numbers
**Steps:**
1. Enter amounts less than $1:
   - Current Available: $0.01
   - Category: $0.99

**Expected Results:**
- ✅ Amounts display as $0.01, $0.99
- ✅ Calculations accurate to cent
- ✅ No rounding errors

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario EDGE-3: Zero Values
**Steps:**
1. Try entering $0 in various fields

**Expected Results:**
- ✅ Category amounts reject $0 (validation)
- ✅ Transaction amounts reject $0 (validation)
- ✅ Income/Available can be $0 (allowed)

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario EDGE-4: Special Date Cases
**Steps:**
1. Add category due date: Feb 29 (leap year)
2. Add category due date: Dec 31
3. Navigate months across year boundary

**Expected Results:**
- ✅ Feb 29 handled correctly
- ✅ Month-end dates display correctly
- ✅ Year transitions smooth

**Status:** [ ] Pass  [ ] Fail

---

## Accessibility Testing

### Test Scenario ACC-1: VoiceOver Support
**Steps:**
1. Enable VoiceOver (Settings → Accessibility → VoiceOver)
2. Navigate through Budget Planning view
3. Test all new features

**Expected Results:**
- ✅ All fields have descriptive labels
- ✅ Month navigation arrows announce purpose
- ✅ Due dates announced clearly
- ✅ Currency amounts announced correctly

**Status:** [ ] Pass  [ ] Fail  [ ] N/A

---

### Test Scenario ACC-2: Dynamic Type
**Steps:**
1. Increase text size (Settings → Display & Brightness → Text Size)
2. Set to largest size
3. Navigate all views

**Expected Results:**
- ✅ All text scales appropriately
- ✅ No text truncation
- ✅ Layouts adapt to larger text
- ✅ Buttons remain tap-able

**Status:** [ ] Pass  [ ] Fail  [ ] N/A

---

## Performance Testing

### Test Scenario PERF-1: Large Dataset
**Steps:**
1. Add 20+ budget categories
2. Add 50+ transactions
3. Navigate through all views

**Expected Results:**
- ✅ No lag when scrolling
- ✅ Month navigation instant
- ✅ Calculations fast (<100ms)
- ✅ No memory warnings

**Status:** [ ] Pass  [ ] Fail

---

### Test Scenario PERF-2: Rapid Interactions
**Steps:**
1. Rapidly tap month navigation arrows (10+ times)
2. Quickly add/edit/delete categories
3. Rapidly tap transactions

**Expected Results:**
- ✅ App remains responsive
- ✅ No crashes or hangs
- ✅ All actions complete correctly
- ✅ No stuck states

**Status:** [ ] Pass  [ ] Fail

---

## Testing Summary

### Overall Results

**Total Test Scenarios**: 40
**Passed**: ___
**Failed**: ___
**N/A**: ___

### Critical Issues Found
<!-- List any blocking issues that prevent feature use -->

1.
2.
3.

### Minor Issues Found
<!-- List any non-blocking issues or UX improvements -->

1.
2.
3.

### Recommendations
<!-- Suggestions for improvements or next steps -->

1.
2.
3.

---

## Sign-Off

**Tester Name**: ________________________
**Date Completed**: ________________________
**Build Version**: 1.1.0
**Device/Simulator**: ________________________
**iOS Version**: ________________________

**Overall Assessment**: [ ] Approved for Release  [ ] Needs Fixes

---

**Notes:**
- Complete all test scenarios in order
- Mark each scenario as Pass/Fail
- Document any issues found in the Issues sections
- Take screenshots of any bugs or unexpected behavior
- Retest failed scenarios after fixes are applied
