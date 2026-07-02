# OpenWolf

@.wolf/OPENWOLF.md

This project uses OpenWolf for context management. Read and follow .wolf/OPENWOLF.md every session. Check .wolf/cerebrum.md before generating code. Check .wolf/anatomy.md before reading files.

## Multi-agent workflow

Use a single-branch multi-agent workflow in this repo.

- Start every cross-stack task with one orchestrator agent that scopes the work, assigns file ownership, and sequences handoffs.
- Split implementation into four roles when relevant: orchestrator, backend, frontend, and security. Add a git/integration pass before commit or PR work.
- Parallelize only when file ownership is disjoint. Never let two agents edit the same file at the same time.
- For backend + Flutter tasks, backend defines API contract changes first, then frontend updates `lib/services/`, `lib/models/`, and related screens/widgets to match.
- Treat `.wolf/` files as shared operational state. Do not use them as scratchpads for feature-specific coordination, and never store secrets, tokens, or sensitive payloads there.
- Before any commit or PR preparation, run a git/integration review of claimed files, overlap risk, verification status, and working tree cleanliness.

## Recommended skill mapping

- Orchestrator: `agent-orchestrator`, `parallel-agents`, `concise-planning`
- Backend: `backend-architect`, `nodejs-backend-patterns`, `api-design-principles`, `backend-security-coder`
- Frontend: `frontend-dev-guidelines`, `frontend-mobile-development-component-scaffold`
- Git/integration: `git-pr-workflows-git-workflow`, `code-review-checklist`, `commit`
- Security: `security-review`, `api-security-best-practices`, `backend-security-coder`, `mobile-security-coder`

## Single-branch handoff rules

1. Claim file sets before editing.
2. Re-check git status before handoff, commit, or PR creation.
3. Keep commits limited to one coherent vertical slice.
4. Trigger a security review for auth, uploads, role checks, settings/config, and sensitive endpoints.
5. Prefer backend-driven data and dynamic backend URL/path handling over hardcoded local values.

## Verification expectations

- Verify backend changes with the existing `backend/package.json` scripts.
- Verify Flutter changes against the real backend contract, not placeholder data.
- For UI changes, test the feature in the app before reporting completion.
- When using shell commands, prefer `rtk` prefixes whenever supported by the command.
