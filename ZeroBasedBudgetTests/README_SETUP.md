# ZeroBasedBudgetTests Setup Guide

## Current Status

✅ **Test Infrastructure Created**:
- Test directory structure created
- Base test class (`ZeroBasedBudgetTests.swift`) implemented
- Test data factory (`TestDataFactory.swift`) created
- Test helpers (`TestHelpers.swift`) created

⚠️ **Action Required**: Add test target to Xcode project (5 minutes)

---

## Step-by-Step: Add Test Target in Xcode

### 1. Open the Project in Xcode

```bash
open ZeroBasedBudget.xcodeproj
```

### 2. Add Unit Test Target

1. In Xcode, go to **File → New → Target**
2. In the template chooser:
   - Select **iOS** tab
   - Choose **Unit Testing Bundle**
   - Click **Next**

3. Configure the test target:
   - **Product Name**: `ZeroBasedBudgetTests`
   - **Team**: (your team)
   - **Organization Identifier**: (your org ID)
   - **Bundle Identifier**: (auto-generated, should be `com.yourorg.ZeroBasedBudgetTests`)
   - **Project**: `ZeroBasedBudget`
   - **Target to be Tested**: `ZeroBasedBudget`
   - Click **Finish**

4. Xcode will create a default test file (`ZeroBasedBudgetTests.swift`) - **DELETE IT** (we have our own)

### 3. Add Test Files to Target

1. In Project Navigator (left sidebar), locate the `ZeroBasedBudgetTests/` folder
2. Select all test files:
   - `ZeroBasedBudgetTests.swift`
   - `Helpers/TestDataFactory.swift`
   - `Helpers/TestHelpers.swift`
3. Right-click → **Add Files to "ZeroBasedBudget"...**
4. In the dialog:
   - ✅ Check **"Copy items if needed"** is UNCHECKED (files already in place)
   - ✅ Check **"Create folder references"** (not groups)
   - ✅ Under **"Add to targets"**, check **ZeroBasedBudgetTests**
   - ✅ UNCHECK **ZeroBasedBudget** (test files should only be in test target)
   - Click **Add**

### 4. Configure Test Target Settings

1. Select the **ZeroBasedBudget project** in Project Navigator
2. Select **ZeroBasedBudgetTests** target in center pane
3. Go to **Build Settings** tab
4. Search for "testability"
5. Verify:
   - **Enable Testability** is set to **Yes** (should be default)

### 5. Verify Main Target Exposes Code to Tests

1. Select **ZeroBasedBudget** target
2. Go to **Build Settings** tab
3. Search for "testability"
4. Ensure:
   - **Enable Testability** is set to **Yes** (Debug configuration)

### 6. Build and Verify

1. Select **Product → Test** (or press `Cmd+U`)
2. Xcode should:
   - Build the app target
   - Build the test target
   - Run tests (no tests yet, but infrastructure should compile)
3. Verify: Build succeeds with no errors

---

## Troubleshooting

### Build Error: "Cannot find 'Account' in scope"

**Solution**: Ensure test files use `@testable import ZeroBasedBudget` at the top.

### Build Error: "No such module 'ZeroBasedBudget'"

**Solution**:
1. Select ZeroBasedBudgetTests target
2. Go to **Build Phases** → **Dependencies**
3. Click **+** → Add **ZeroBasedBudget** target
4. Clean build folder (`Cmd+Shift+K`) and rebuild

### Test Files Not Visible in Test Navigator

**Solution**:
1. Ensure files are added to **ZeroBasedBudgetTests** target
2. Select test file → File Inspector → verify Target Membership includes ZeroBasedBudgetTests

---

## Alternative: Command-Line Verification

After adding test target in Xcode, verify from command line:

```bash
# List targets (should show ZeroBasedBudgetTests)
xcodebuild -list -project ZeroBasedBudget.xcodeproj

# Build test target
xcodebuild build-for-testing \
  -project ZeroBasedBudget.xcodeproj \
  -scheme ZeroBasedBudget \
  -destination 'platform=iOS Simulator,name=iPhone 17'

# Run tests
xcodebuild test \
  -project ZeroBasedBudget.xcodeproj \
  -scheme ZeroBasedBudget \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

---

## Next Steps

After successfully adding the test target:

1. ✅ Test infrastructure builds without errors
2. 📝 Ready to implement test suite (Enhancement 5.2)
3. 🚀 Begin writing 110 unit tests across 10 test files

---

## Questions?

If you encounter issues:
1. Check Xcode version (requires Xcode 26 for iOS 26 support)
2. Verify Swift version (should be Swift 6)
3. Clean build folder and rebuild
4. Restart Xcode if necessary

**Once complete, return to Claude Code and confirm:**
```
Test target added successfully. Build succeeds.
```
