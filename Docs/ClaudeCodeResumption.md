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

Choose the appropriate template based on your situation:

### Template A: Mid-Task Interruption (Incomplete Work)

Use this when Claude Code stopped mid-execution with uncommitted changes or incomplete work.

```markdown
RESUMING WORK - Claude Code reached context limit mid-execution.

# Project Context
- **Project**: ZeroBasedBudget iOS app (SwiftUI + SwiftData, iOS 26+)
- **Platform**: iPhone only (no iPad support)
- **Methodology**: YNAB-style zero-based budgeting (CRITICAL - must follow)
- **Status Doc**: CLAUDE.md (contains complete current state)
- **Tech Spec**: Docs/TechnicalSpec.md (implementation patterns)

# Pre-Resumption Checklist

Before proceeding, complete ALL verification steps and report findings:

## 1. Read CLAUDE.md Key Sections
Focus on these critical sections (in order):
- [ ] **"Next Session Start Here"** - What was being worked on
- [ ] **"Active Development" → "Current Focus"** - Active task/bug/enhancement
- [ ] **"Active Development" → "Recent Significant Changes"** - Last 5 commits
- [ ] **"Active Issues & Enhancement Backlog"** - Current priority work
- [ ] **"YNAB-Style Budgeting Methodology"** - Core principles (MUST FOLLOW)

## 2. Verify Git State
```bash
# Check recent work
git log --oneline -10

# Check for uncommitted changes
git status

# Check branch status
git branch -v
```

## 3. Build Verification
```bash
# Build project (or use Cmd+B in Xcode)
xcodebuild -project ZeroBasedBudget.xcodeproj -scheme ZeroBasedBudget build
```
Report: Does build succeed or fail? If failed, what errors?

## 4. Report Current State
After completing steps 1-3, provide concise summary:
- **Current version**: (e.g., v1.5.0 complete, v1.6.0 planned)
- **Active work**: (what was being worked on when interrupted)
- **Build status**: (success/failure)
- **Uncommitted changes**: (yes/no - what files)
- **Next steps**: (what should happen next, from CLAUDE.md)

# Critical Implementation Reminders

When resuming implementation, ALWAYS follow these rules:

## YNAB Methodology (NON-NEGOTIABLE)
- ✅ Budget only money that exists TODAY (never future/expected income)
- ✅ Income tracked via transactions only (not pre-budgeted)
- ✅ "Ready to Assign" = starting balance + actual income - total budgeted
- ✅ Expenses reduce account balance (NOT Ready to Assign)
- ✅ Categories can have $0 budgeted (tracked but unfunded)

## Technical Requirements
- ✅ Use `Decimal` for ALL monetary values (never Double/Float)
- ✅ Use `cloudKitDatabase: .none` (local storage only)
- ✅ Use `.currency(code: "USD")` for all currency formatting
- ✅ Commit after each logical unit of work
- ✅ Update CLAUDE.md after significant commits
- ✅ Platform: iPhone only, iOS 26+ (no iPad)

# Action Required

**BEGIN VERIFICATION NOW** - Complete checklist above and report findings before resuming work.
```

---

### Template B: Clean Checkpoint Resumption (Work Complete)

Use this when resuming from a clean state with all work committed.

```markdown
RESUMING WORK - Continuing from clean checkpoint.

# Project Context
- **Project**: ZeroBasedBudget iOS app (SwiftUI + SwiftData, iOS 26+)
- **Platform**: iPhone only (no iPad support)
- **Methodology**: YNAB-style zero-based budgeting

# Quick Verification

## 1. Read Current State
Read CLAUDE.md sections:
- [ ] **"Next Session Start Here"** - Continuation point
- [ ] **"Active Development" → "Current Focus"** - What to work on
- [ ] **"Active Issues & Enhancement Backlog"** - Priority work

## 2. Verify Clean State
```bash
git status              # Should show clean working tree
git log --oneline -5    # Review recent commits
```

## 3. Report & Proceed
Provide brief summary:
- Current version and status
- What CLAUDE.md says to do next
- Any blockers or decisions needed

Then ask: **"Ready to proceed with [specific task from CLAUDE.md]?"**

# Critical Reminders
- ✅ Follow YNAB methodology (budget only existing money, income via transactions)
- ✅ Use Decimal for money, cloudKitDatabase: .none, iPhone-only (iOS 26+)
- ✅ Commit frequently with conventional commit messages (fix:/feat:/refactor:)

**BEGIN VERIFICATION NOW**
```

---

### Template C: Uncertain State Recovery

Use this when you're not sure what state the project is in.

```markdown
RECOVERY MODE - Uncertain project state, need full assessment.

# Project Context
- **Project**: ZeroBasedBudget iOS app (SwiftUI + SwiftData, iOS 26+)
- **Status**: Uncertain - need full verification

# Full State Assessment Required

## 1. Read Complete CLAUDE.md
Read the ENTIRE file, paying special attention to:
- [ ] YNAB-Style Budgeting Methodology (understand core principles)
- [ ] Critical Implementation Rules (must follow)
- [ ] Active Development section (current focus)
- [ ] Active Issues & Enhancement Backlog (priority work)
- [ ] Next Session Start Here (continuation point)

## 2. Git History Analysis
```bash
# Review recent commits
git log --oneline -20
git log --graph --oneline -10

# Check current state
git status
git diff

# Check branch information
git branch -av
```

## 3. Project Structure Verification
```bash
# Verify key directories exist
ls -la ZeroBasedBudget/Models/
ls -la ZeroBasedBudget/Views/
ls -la ZeroBasedBudget/Utilities/
ls -la Docs/
```

## 4. Build Status Check
```bash
xcodebuild -project ZeroBasedBudget.xcodeproj -scheme ZeroBasedBudget build
```

## 5. Comprehensive State Report
After completing steps 1-4, provide detailed report:

**Version & Status**:
- Current version: [from CLAUDE.md]
- Build status: [success/fail with errors if any]

**Git State**:
- Last 5 commit messages
- Uncommitted changes: [list files]
- Branch: [name and status]

**Active Work** (from CLAUDE.md):
- Current focus: [what was being worked on]
- Recent changes: [last significant work]
- Next steps: [what CLAUDE.md says to do next]

**Blockers/Issues**:
- Any build errors
- Any uncommitted changes that need decision
- Any unclear state that needs clarification

**Recommendation**:
- Should we continue from current state?
- Should we commit/discard uncommitted work?
- Should we return to last good commit?

# Critical Project Constraints
- **YNAB Methodology**: Budget only existing money, income via transactions only
- **Technical**: Decimal for money, local storage only, iPhone-only iOS 26+
- **Quality**: Build must succeed before commits, test features before committing

**BEGIN FULL ASSESSMENT NOW**
```

---

## Choosing the Right Template

| Situation | Use Template | Why |
|-----------|--------------|-----|
| Claude stopped mid-task, uncommitted changes exist | **Template A** | Need verification before continuing incomplete work |
| Resuming after clean commit, ready for next task | **Template B** | Quick context refresh, move to next item |
| Unsure what state project is in, confusion about progress | **Template C** | Full assessment needed to understand state |
| Coming back after several days/weeks | **Template C** | Full context restoration needed |
| Quick same-day continuation | **Template B** | Minimal verification needed |
| Build was failing when interrupted | **Template A** or **C** | Need to assess and fix before continuing |

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
