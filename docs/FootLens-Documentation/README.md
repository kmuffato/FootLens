# FootLens — AI-driven delivery documentation

Version 1.0 • 2 October 2026 • Status: implementation specification, application not implemented by this pack.

FootLens is a personal football analysis application with a Windows WinForms client, a C# modular-monolith service, PostgreSQL and Entity Framework Core. It imports football data, creates reproducible probability distributions, compares markets, records forecasts, and evaluates them through chronological backtests and paper betting. Agents execute small verified changes inside repeatable loops; the owner selects outcomes and audits evidence.

## Start here

1. Read [START_HERE](START_HERE.md), then [scope and assumptions](docs/PRODUCT_REQUIREMENTS.md).
2. Read [ARCHITECTURE](ARCHITECTURE.md), [data design](docs/DATA_MODEL.md), and the [decision index](docs/adr/README.md).
3. Initialise the repository using [BOOTSTRAP](docs/BOOTSTRAP.md). Copy [AGENTS.md](AGENTS.md) to the repository root. The supplied state is a starting template, not evidence of completed implementation.
4. Execute FL-001 in [TASK_BREAKDOWN](TASK_BREAKDOWN.md), using the [vertical-slice prompt](prompts/03-vertical-slice.md) and [coding playbook](VIBE_CODING_PLAYBOOK.md).
5. Move through [ROADMAP](ROADMAP.md) using [loop instructions](loops/README.md), [verification](docs/TEST_STRATEGY.md) and [DEFINITION OF DONE](DEFINITION_OF_DONE.md).
6. Release using [deployment](docs/DEPLOYMENT.md), operate using [maintenance](docs/OPERATIONS.md), and finish using [project closure](docs/PROJECT_CLOSURE.md).

## Navigation

| Concern | Authoritative document |
|---|---|
| Scope, requirements, assumptions | [Product](docs/PRODUCT_REQUIREMENTS.md) |
| Context, modules, dependency directions, loops | [Architecture](ARCHITECTURE.md) |
| Decisions and superseded design | [ADRs](docs/adr/README.md), [migration](docs/LEGACY_MIGRATION.md) |
| Tables, constraints, EF Core | [Data model](docs/DATA_MODEL.md), [SQL proposal](reference/schema.sql) |
| Source onboarding and point-in-time data | [Data ingestion](docs/DATA_INGESTION.md) |
| Probability, consistency, value, uncertainty | [Probability engine](PROBABILITY_ENGINE.md) |
| Fitting, calibration, research | [Model specification](docs/MODEL_SPECIFICATION.md), [ML experiments](docs/ML_EXPERIMENTS.md) |
| Dependencies among markets | [Market graph](docs/MARKET_DEPENDENCY_GRAPH.md) |
| Replay, simulated betting, evaluation | [Backtesting engine](BACKTESTING_ENGINE.md) |
| Contracts, errors, security | [API](docs/API_CONTRACTS.md), [security](docs/SECURITY.md) |
| Desktop interactions | [UX specification](docs/UX_SPECIFICATION.md) |
| Agent collaboration and instructions | [Playbook](VIBE_CODING_PLAYBOOK.md), [AGENTS](AGENTS.md), [prompts](prompts/README.md) |
| Work order, dependencies and acceptance | [Roadmap](ROADMAP.md), [tasks](TASK_BREAKDOWN.md), [machine backlog](reference/backlog.json) |
| Test gates and CI | [Tests](docs/TEST_STRATEGY.md), [CI/CD](docs/CI_CD.md), [DoD](DEFINITION_OF_DONE.md) |
| Operations and completion | [Operations](docs/OPERATIONS.md), [runbooks](docs/RUNBOOKS.md), [closure](docs/PROJECT_CLOSURE.md) |
| Risks, source basis and evidence | [Risks](docs/RISKS.md), [sources](docs/SOURCES.md), [pack validation](evidence/PACK_VALIDATION.md) |

Precedence: explicit user direction → accepted ADRs in this pack → domain/engine contracts → task acceptance criteria → task prompt. Earlier FootballLens/Football Analytics documents remain historical reference. This revision uses **FootLens** and supersedes SQLite, no-API and strictly manual processing choices. It does not claim to regenerate the original exhaustive spreadsheet formula inventory.

The SQL, JSON, C# contracts and fixtures are reference artifacts for implementation. SQL is a proposed relational design, not an EF migration. CI and loop commands are contracts to implement during bootstrap; no application test, deployment or model performance is claimed here.

## Additional implementation references

- [Configuration](docs/CONFIGURATION.md)
- [C# coding standards](docs/CODING_STANDARDS.md)
- [User guide](docs/USER_GUIDE.md)
- [Requirement traceability](docs/TRACEABILITY.md)
- [Analytic acceptance vectors](reference/golden-vectors.json)
- [Synthetic import sample](reference/synthetic-import.json)
- [Agent role and connector configuration](reference/agent-config.json)
- [Changelog](CHANGELOG.md)
