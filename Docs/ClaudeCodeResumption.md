# Claude Code Mid-Execution Resumption Guide

**Use this guide when Claude Code reaches its context limit or stops mid-execution.**

## ⚠️ When Claude Code Stops Mid-Task

Follow these steps in order to safely resume work without losing progress or context.

---

## Step 1: DON'T PANIC - Assess Current State

Before doing anything, understand where things stand:

### 1.1 Check Git Status
```bash
git status
```
- **Red files (modified)** = changes not committed
- **Green files (staged)** = ready to commit but not committed yet
- **Clean working tree** = everything committed ✅

### 1.2 Check Recent Commits
```bash
git log --oneline -10
```
- Review the last 10 commits
- Note the most recent commit message
- This tells you what was last completed

### 1.3 Verify Build Status
```bash
# In Xcode, press Cmd+B to build
# OR from terminal:
xcodebuild -project ZeroBasedBudget.xcodeproj -scheme ZeroBasedBudget build
```
- **Build succeeds** = code is in working state ✅
- **Build fails** = incomplete/broken code ⚠️

### 1.4 Review CLAUDE.md
Open `CLAUDE.md` and check:
- Which phase is marked as current?
- Which tasks are checked off [x]?
- What's the last entry in "Git Commits"?
- Are there any "Session Notes"?

---

## Step 2: Secure Current Work

### 2.1 If Build is SUCCESSFUL (Working Code)

**Commit immediately to preserve working state:**
```bash
# If you have uncommitted changes
git add .
git commit -m "wip: save progress on [describe what was being worked on]"
```

Example:
```bash
git commit -m "wip: partial implementation of BudgetPlanningView form structure"
```

### 2.2 If Build is BROKEN (Non-Working Code)

**Option A - Discard broken changes:**
```bash
# WARNING: This deletes all uncommitted changes!
git restore .
git clean -fd
```

**Option B - Stash changes for later:**
```bash
git stash save "incomplete work on [describe]"
# You can retrieve later with: git stash pop
```

**Option C - Commit anyway with clear WIP message:**
```bash
git add .
git commit -m "wip: BROKEN - incomplete [feature name] - do not use"
```

---

## Step 3: Update CLAUDE.md

Open `CLAUDE.md` and manually update it to reflect accurate current state:

### 3.1 Update Task Checklist

In the current phase section, mark tasks as complete [x] or incomplete [ ]:
```markdown
**Detailed Tasks**:
- [x] Create CLAUDE.md with full roadmap
- [x] Read and understand Docs/TechnicalSpec.md
- [x] Create Models/ folder and SwiftData model files
- [x] BudgetCategory.swift created
- [x] Transaction.swift created  
- [x] MonthlyBudget.swift created
- [x] Update ZeroBasedBudgetApp.swift with ModelContainer
- [ ] Create Views/ folder and stub view files  ← STOPPED HERE
- [ ] BudgetPlanningView.swift
- [ ] TransactionLogView.swift
- [ ] BudgetAnalysisView.swift
```

### 3.2 Update "Git Commits" Section

Add any commits made since last update:
```markdown
**Git Commits**:
- [2024-11-01 14:23] feat: add SwiftData models (BudgetCategory, Transaction, MonthlyBudget)
- [2024-11-01 14:35] feat: configure SwiftData with local-only storage
- [2024-11-01 14:47] wip: partial implementation of stub views  ← JUST ADDED
```

### 3.3 Add Session Notes

Add detailed notes about where things stopped:
```markdown
## Current Session Notes

### Session 2024-11-01 14:47 - INTERRUPTED MID-EXECUTION
**Status**: Claude Code hit context limit during Phase 1, Step 3

**Completed**:
- All three SwiftData models created and working
- ModelContainer configured in ZeroBasedBudgetApp.swift
- TabView structure added to ContentView.swift
- BudgetPlanningView.swift created with NavigationStack

**In Progress / Incomplete**:
- TransactionLogView.swift NOT YET CREATED
- BudgetAnalysisView.swift NOT YET CREATED
- Final verification not done

**Next Steps** (for resumption):
1. Create TransactionLogView.swift with NavigationStack and placeholder
2. Create BudgetAnalysisView.swift with NavigationStack and placeholder
3. Build and verify all three tabs work
4. Commit with message: "feat: implement TabView navigation with three stub views"
5. Mark Phase 1 complete in CLAUDE.md

**Important Context**:
- Build was successful before interruption
- No errors encountered
- Following TechnicalSpec.md Phase 1 guidance
```

### 3.4 Save CLAUDE.md
```bash
# Save the file in your editor, then:
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md with current state after interruption"
```

---

## Step 4: Prepare Resumption Prompt

Create a new chat with Claude Code using this template:
```markdown
RESUMING WORK - Claude Code reached session limit mid-execution.

═══════════════════════════════════════════════════════════════════════════════
CONTEXT RESTORATION
═══════════════════════════════════════════════════════════════════════════════

Project: ZeroBasedBudget iOS app (SwiftUI + SwiftData)
Technical Spec: Docs/TechnicalSpec.md
Project Status: Docs/CLAUDE.md

CRITICAL: Read CLAUDE.md thoroughly before proceeding - it contains the complete 
current state, what's done, what's in progress, and what's next.

═══════════════════════════════════════════════════════════════════════════════
VERIFICATION TASKS (Do these FIRST)
═══════════════════════════════════════════════════════════════════════════════

1. Read CLAUDE.md completely, especially:
   - Current phase status
   - "Detailed Tasks" checklist (what's checked [x] vs unchecked [ ])
   - "Current Session Notes" section (bottom of file)

2. Review recent git history:
```bash
git log --oneline -10
```
   
3. Verify project structure:
```bash
ls -la ZeroBasedBudget/Models/
ls -la ZeroBasedBudget/Views/
```

4. Check for uncommitted changes:
```bash
git status
```

5. Verify build status:
   - Build the project
   - Report if build succeeds or fails

6. Report back with summary:
   - What phase/step we're on
   - What's complete
   - What's incomplete
   - What needs to happen next

═══════════════════════════════════════════════════════════════════════════════
AFTER VERIFICATION - Resume Implementation
═══════════════════════════════════════════════════════════════════════════════

Based on CLAUDE.md "Current Session Notes" section, continue from where we left off.

CRITICAL REQUIREMENTS (from TechnicalSpec.md):
- Use Decimal type for all monetary values (never Double/Float)
- Ensure cloudKitDatabase: .none for local storage only
- Commit after each logical unit of work
- Update CLAUDE.md after each commit

Follow the same implementation pattern and commit strategy as before.

BEGIN VERIFICATION NOW.
```

---

## Step 5: Send Resumption Prompt

1. **Start a NEW Claude Code chat** (don't continue the old one - it's at limit)
2. **Paste the resumption prompt** from Step 4
3. **Wait for Claude Code's verification report** before confirming continuation
4. **Review the verification** - does it match what you see in CLAUDE.md?
5. **If verification is accurate**, reply: `Verified. Please continue with implementation.`
6. **If verification is wrong**, reply: `Incorrect. Here's the actual state: [explain]`

---

## Step 6: Monitor Progress

As Claude Code resumes work:

### ✅ Good Signs:
- References CLAUDE.md and git history
- Continues from exact stopping point
- Commits regularly with good messages
- Updates CLAUDE.md after commits
- Stays focused on remaining tasks

### ⚠️ Warning Signs:
- Wants to restart from beginning (STOP - remind it to continue from CLAUDE.md)
- Doesn't reference CLAUDE.md or git history
- Tries to redo already-completed work
- Ignoring the "Current Session Notes"

If you see warning signs, immediately send:
```
STOP. You're redoing work that's already complete.

Please re-read CLAUDE.md section "Current Session Notes" which clearly states 
what's done and what remains. Continue ONLY with the incomplete tasks listed 
in "Next Steps".
```

---

## Step 7: Verify Completion

When Claude Code says it's finished:

1. **Build the project** - Does it compile?
2. **Run the app** - Does it work as expected?
3. **Check git log** - Are all commits properly recorded?
4. **Review CLAUDE.md** - Are all tasks marked complete?
5. **Verify file structure** - Do all expected files exist?

If everything checks out:
```
Phase [X] verified complete. Ready to proceed to Phase [Y] when you're ready.
```

---

## Quick Reference Cheat Sheet
```bash
# Check current state
git status                    # Uncommitted changes?
git log --oneline -10        # Recent commits
ls -la Models/ Views/        # What files exist?

# Secure work in progress
git add .
git commit -m "wip: [description]"

# Update documentation
# Edit CLAUDE.md with current state
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md after interruption"

# If build is broken and you want to start fresh
git restore .                 # Discard uncommitted changes
git clean -fd                # Remove untracked files

# If you want to save broken work for later
git stash save "incomplete [feature]"
```

---

## Common Scenarios

### Scenario A: Clean Stop (Last Commit Was Recent)

**Situation**: Build works, recent commit exists, close to checkpoint
**Action**: Just resume with basic prompt referencing CLAUDE.md
**Recovery Time**: ~2 minutes

### Scenario B: Mid-Task Stop (Uncommitted Changes, Build Works)

**Situation**: Was in middle of creating files, build succeeds
**Action**: Commit WIP, update CLAUDE.md with detailed notes, resume
**Recovery Time**: ~5 minutes

### Scenario C: Broken Stop (Uncommitted Changes, Build Fails)

**Situation**: Code is incomplete/broken, doesn't compile
**Action**: Either commit as WIP (broken) or discard changes, update CLAUDE.md, resume from last good commit
**Recovery Time**: ~10 minutes

### Scenario D: Confusion Stop (Not Sure What's Done)

**Situation**: Can't tell what's complete vs incomplete
**Action**: Use git log, git diff, and file listings to assess, update CLAUDE.md meticulously, then resume
**Recovery Time**: ~15 minutes

---

## Emergency Contacts

**If you're stuck:**
1. Check git history thoroughly: `git log --all --graph --decorate --oneline`
2. Review TechnicalSpec.md for implementation guidance
3. If needed, return to last known good commit: `git checkout [commit-hash]`
4. Start fresh from that commit with detailed CLAUDE.md notes

**Nuclear Option** (if everything is broken):
```bash
# Create safety branch first
git branch backup-before-reset

# Reset to last known good commit
git log --oneline -20  # Find last good commit
git reset --hard [good-commit-hash]

# Resume from there
```

---

## Prevention Tips

**To minimize interruptions:**

1. **Break large phases into smaller sub-phases** in your prompts
2. **Request status updates** every 10-15 minutes of work
3. **Ask Claude Code to commit frequently** (every logical unit)
4. **Have Claude Code update CLAUDE.md** after each commit
5. **Use shorter, focused prompts** rather than massive multi-step instructions

**Ideal prompt pattern:**
```
Complete Phase 2.1: [small specific task]
Commit when done.
Update CLAUDE.md.
Report completion.

(Then in next prompt)
Complete Phase 2.2: [next small specific task]
...
```

This gives you natural stopping points with clean state at each step.

---

## Appendix: File Locations
```
ZeroBasedBudget/
├── CLAUDE.md                      ← Primary state tracking document
├── Docs/
│   ├── TechnicalSpec.md          ← Complete implementation guide
│   └── ClaudeCodeResumption.md   ← This document
├── Models/                        ← SwiftData models
├── Views/                         ← SwiftUI views
└── ViewModels/                    ← ViewModels (future phases)
```
