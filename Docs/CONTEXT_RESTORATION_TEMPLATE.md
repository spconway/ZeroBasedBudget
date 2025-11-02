CONTEXT RESTORATION:
You are Claude Code continuing work on the ZeroBasedBudget iOS app.

CURRENT STATE VERIFICATION:
1. Read CLAUDE.md to understand project status and current phase
2. Review recent git commits to see what was completed:
   - Run: git log --oneline -10
   - Note the most recent commit message
3. Check current file structure to verify what exists

LAST SESSION STATUS:
[Summarize what you know was completed or in progress]
- Example: "You were implementing Phase 1, Step 3 - creating stub views. 
  BudgetPlanningView.swift was created but TransactionLogView.swift and 
  BudgetAnalysisView.swift were not yet created."

YOUR TASK:
1. First, update CLAUDE.md if the previous session ended without updating it
2. Then continue from where you left off: [be specific about what remains]
3. Follow the same commit strategy and CLAUDE.md update pattern
4. Complete the remaining tasks for [current phase/step]

CRITICAL REMINDERS:
- Use Decimal type for all monetary values
- Ensure cloudKitDatabase: .none for local storage
- Commit after each logical unit
- Update CLAUDE.md after each commit

Confirm you've reviewed CLAUDE.md and git history, then proceed.
```

## 4. **Break Large Phases into Smaller Sub-Tasks**

If a phase is taking too long, break it down:

**Instead of:**
```
Complete Phase 2: Budget Planning View
```

**Do this:**
```
Phase 2.1: Create budget form structure with sections
THEN (next prompt if needed)
Phase 2.2: Add TextFields with currency formatting
THEN
Phase 2.3: Implement computed properties for totals
THEN
Phase 2.4: Add summary section with remaining balance
```

Update CLAUDE.md to reflect these sub-phases so Claude Code knows where it is.

## 5. **Ask for Status Update First**

When resuming, your first message can be:
```
Before continuing, please:
1. Read CLAUDE.md 
2. Check git log for recent commits
3. Verify which files exist in the project
4. Tell me exactly where we are in the implementation
5. List what remains to be done for the current phase

Then wait for my confirmation before proceeding.
```

This ensures you both agree on current state before continuing.

## 6. **Use Git Status Commands**

Have Claude Code verify state with git:
```
Run these commands and report findings:
- git status (shows uncommitted changes)
- git log --oneline -5 (shows recent commits)
- ls -R Models/ Views/ (shows created files)

Then update CLAUDE.md with current accurate status before continuing.