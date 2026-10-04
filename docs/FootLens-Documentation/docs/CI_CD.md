# CI/CD and integration policy

GitHub Actions is the default wiring choice; commands are portable to GitLab or local automation. No connector/account setup has been performed by this pack. Pin external actions by immutable commit and container images by digest; no untrusted PR gets deployment/source credentials. Branch main protected by required checks, review and no force push. One serial integration queue; rerun against actual merge commit.

| Lane | Trigger | Required jobs | Evidence |
|---|---|---|---|
| Fast PR | every change | documentation/schema/traceability; locked restore; core build; unit/oracle/architecture; secret/dependency scan | commands, discovery counts, reports |
| Integration PR | API/data/job changes and before merge | actual PostgreSQL fresh migration; constraints/API/lease/temporal/ledger suites | DB version, migration hash, traces |
| Windows | desktop/project changes and release | full solution build, presenter and keyboard/DPI smoke | test output and redacted screenshots |
| Scheduled quality | weekly and model changes | frozen replay corpus, drift candidate diagnostics, load sample | versioned metric comparison, no promotion |
| Release | candidate tag and deployment authority | all gates; publish; SBOM/manifest; clean install/upgrade/restore; artifact signing policy | tested hashes and release record |

Application tests cannot be path-filtered away when shared contracts, migrations, packages or numerics change. Documentation-only PR may run the documentation lane only with explicit no-code diff check. A green unit lane does not unblock a missing Windows or DB lane. Quarantined flaky tests need owner/expiry and cannot cover a release-critical invariant alone.

Secret injection uses environment/runner secret store; jobs print safe metadata only. PRs from untrusted branches use synthetic data/disposable DB; never auto-execute downloaded issue/CSV instructions. Cache by lockfile+SDK/platform; don't cache mutable database state as proof. Capture SBOM/licences and vulnerability assessment, not an unverified “zero vulnerabilities” badge.

Build once, test the built artifacts, hash/sign, then promote the same artifact. Migration bundle/code/model/config hashes form release manifest. Deployment step uses separate migrator credentials after backup verification; runtime credentials never gain DDL. Automatic local/staging deployment can operate inside recorded authority; external publishing/production credentials need explicit authority. Failed smoke triggers documented rollback decision and records outcome; do not overwrite the prior release evidence.
