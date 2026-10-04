# Start and keep moving

## First working session

Use an empty Git repository. Copy this pack into it, keeping AGENTS.md, ARCHITECTURE.md, ROADMAP.md, TASK_BREAKDOWN.md and the playbook at root. Keep docs/, reference/, prompts/, templates/ and loops/. Treat state/ as initial content and evidence/ as documentation evidence only. Do not copy another project's .git or credentials.

Read FL-001, approve its normal reversible development scope by starting the task, and give the agent prompts/03-vertical-slice.md with TaskId=FL-001. The expected first outcome is a buildable .NET solution, health endpoint, real PostgreSQL integration-test path and an honest verifier; it is not the whole platform in a single prompt.

Default roles are logical responsibilities, not a requirement to run many models. One agent can implement; a fresh reviewer session evaluates the exact resulting commit. Parallel coding is optional, only for tasks whose contracts are frozen and files/migrations do not overlap. Each concurrent task gets its own branch, worktree and test database. One integrator merges serially.

## First usable product

Milestone M1: import a small canonical CSV, resolve teams, list fixtures, run the independent-Poisson reference fixture, persist a prediction and display it in WinForms. No bookmaker or AI API key is required. Manual odds entry and CSV imports allow offline-after-import operation while the local service and database are available.

## Session routine

Read state/project.json and the selected task; inspect actual Git status and pending changes. Fill templates/task-packet.json; record commit and allowed paths. Implement one acceptance criterion at a time. Run focused tests, then the stage verifier. Save the exact command results, review findings and remaining limitations to evidence/<TaskId>/<run-id>/. Update task state only after comparing actual evidence. Commit code, tests and documentation together. End with a handoff using templates/handoff.md.

A failed test causes repair or a recorded blocker. An unavailable tool or missing dataset causes a Blocked/Unavailable result, not a fabricated pass. Two unsuccessful repair cycles trigger a smaller reproduction and a human-visible blocker, preserving all completed work.

## Practical defaults

Use .NET 10 LTS, matching EF Core/Npgsql 10 release lines and PostgreSQL 18. Resolve and pin exact supported patches in FL-001, with package locks and image digest. Use GitHub Actions as the default CI example, with equivalent commands usable in GitLab or a local harness. WinForms builds and UX smoke tests need Windows; numerical and API tests run cross-platform. No repository, account or deployment has been created by this pack.

The owner need not approve every test or code edit. Obtain explicit authority for production data deletion, publishing externally, paid service changes, real-money transactions or expanding external write permissions. Already-authorised deployment work follows its release checklist without repeatedly requesting the same approval. Real-money betting is outside the product scope.
