# Sources and evidence boundary

## Project source basis

The user request on 2 October 2026 explicitly selects FootLens, C#, modular monolith, Clean Architecture, PostgreSQL, EF Core and repeatable AI execution loops. It supersedes conflicting earlier platform choices. The prior `football_analytics_architecture_and_detailed_design.md` dated 30 September 2026 was consulted for scope, requirement IDs R-equivalents, temporal rules and model/numerical design. The architecture opening and statistical sections were read; this pack does not claim a new full formula-by-formula audit.

Earlier conversation supplies the comparison gaps and name change. The old architecture remains a source, not the current implementation contract. Legacy workbook audit claimed 253,278 formula-value cells and 620 Expected formulas; these are inherited counts pending immutable source inventory reconciliation in FL-011. Two explanatory text cells were previously distinguished from executable formulas. Do not call the inherited total an independently verified number here.

## Official technical references checked for this revision

- [.NET support policy](https://dotnet.microsoft.com/en-us/platform/support/policy): choose .NET 10 LTS; pin a supported SDK/runtime patch during bootstrap.
- [Npgsql EF Core 10 release notes](https://www.npgsql.org/efcore/release-notes/10.0.html): matching provider release line exists.
- [PostgreSQL versioning](https://www.postgresql.org/support/versioning/): PostgreSQL 18 supported major; pin patched build/digest.
- [EF Core DbContext lifetime](https://learn.microsoft.com/en-us/ef/core/dbcontext-configuration/): context scopes and concurrency restrictions.
- [EF production migrations](https://learn.microsoft.com/en-us/ef/core/managing-schemas/migrations/applying): reviewed scripts/bundles, separate deployment step.
- [PostgreSQL SELECT locking](https://www.postgresql.org/docs/18/sql-select.html): SKIP LOCKED used for queue claims, not analytical snapshot consistency.

The decisions and original text are our project specification. Version-specific APIs and packages must be verified again when FL-001 locks exact versions. Statistical equations below are standard probability identities or explicit FootLens design choices; model performance and published-code accuracy have not been experimentally established by this documentation exercise.
