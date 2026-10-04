# Repository bootstrap

## Prerequisites and output

Windows11 x64 with .NET10 supported SDK, Git, an editor/harness and PostgreSQL18 locally/private; Linux CI for pure/API tests and Windows CI for Desktop. PowerShell7 for scripts. Python3 is only for the supplied documentation validator, not a production dependency. No paid AI API needed by FootLens runtime. AI harness credentials stay in the harness.

FL-001 must record `dotnet --info`, selected SDK feature-band/patch, runtime, PostgreSQL version, OS and package graph. Use official releases at execution time; pin exact versions in global.json, Directory.Packages.props, packages.lock.json and container digest. Never substitute runtime patch number for SDK version. Resolve compatible EF Core/Npgsql provider10.x with no floating/pre-release versions. Candidate test framework xUnit and Microsoft.NET.Test.Sdk are development dependencies; confirm exact supported combination before lock.

## Sequence from an empty folder

1. Initialise Git if absent; check for AGENTS instructions and existing user files first. Copy this pack without overwriting existing unrelated content.
2. Create FootLens.slnx and projects from ARCHITECTURE, using net10.0; Desktop/desktop tests target net10.0-windows with UseWindowsForms. Set nullable/implicit usings, warnings-as-errors and analyzers; centralise package versions and deterministic builds.
3. Add references only in the documented direction. Set internals visibility only for tests where justified. Add architecture tests for namespace/module ownership and production package restrictions.
4. Add health endpoint, token auth, correlation middleware and minimal configuration validation. Bind127.0.0.1:5188; use a randomly provisioned local token, never a fixed token in appsettings.
5. Provision separate footlens_dev and uniquely named footlens_test_<runid> stores with non-production credentials. Refuse reset/drop unless host/database prefix matches the explicit disposable-test allowlist. Only migrator creates schema; runtime role restricted.
6. Create EF initial migration based on reviewed schema proposal; do not execute reference/schema.sql and EF migrations in the same store. Add migration tests and pure unit fixtures.
7. Implement scripts/verify.ps1 and loop.ps1 contracts below; wire CI. Commit initial state and passing actual evidence; missing SDK/DB makes the affected check Blocked.
8. Start FL-002/003 using fresh packets. Do not build all product features during bootstrap.

## Automation commands to implement

`verify.ps1 -Stage Fast|Integration|Release -EvidenceDir <dir>` must stop on first command failure, preserve all results collected, fail if a required suite/project is absent, and emit verifier-result JSON. Fast: locked restore, build, unit/architecture/numerical tests and documentation checks. Integration adds disposable PostgreSQL migrations, API/jobs, leakage/ledger and boundary checks. Release adds Windows UX, load, dependency/security, restore/upgrade and registered model evidence. Tests run against the built commit/artifacts; no silent rebuild from changed source after recording hashes.

Typical underlying commands (after projects exist):

```powershell
dotnet restore FootLens.slnx --locked-mode
dotnet build FootLens.slnx -c Release --no-restore
dotnet test tests/FootLens.Tests.Unit -c Release --no-build
dotnet test tests/FootLens.Tests.Integration -c Release --no-build
dotnet test tests/FootLens.Tests.Architecture -c Release --no-build
python scripts/validate_pack.py
```

Linux jobs build only cross-platform project graph, not the full Windows solution. Windows job builds the entire solution. Integration harness requires an explicit test connection injected via secret environment and rejects production-looking targets. The runtime host uses configuration variable ConnectionStrings__FootLens and an OS-protected local API token source. No connection string belongs in commands printed to evidence.

`loop.ps1` validates packet/state revision and dispatches only registered handlers; it does not grant shell/network rights based on generated text. CLI handler verbs (import, forecast, replay, verify, backup) map to the same application services as API, with operator auth and exit codes. Runtime schedules enqueue jobs instead of invoking an LLM.

## Initial dependency allowlist

Production: Microsoft .NET runtime/ASP.NET/WinForms; Microsoft.EntityFrameworkCore; Npgsql.EntityFrameworkCore.PostgreSQL and required Npgsql/transitives in Infrastructure/Host. Tooling: EF Design/tools and xUnit/test SDK with PrivateAssets as appropriate. No production Math.NET/ML.NET, AutoMapper, mediator, workflow platform or UI toolkit initially. Admit one only with need/alternatives/licence/transitives/security/update owner and accepted ADR.
