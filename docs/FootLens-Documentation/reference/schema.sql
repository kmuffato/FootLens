-- FootLens PostgreSQL table proposal, not an EF migration.

-- Apply only to a disposable empty database for design validation.

BEGIN;

CREATE SCHEMA IF NOT EXISTS catalog;

CREATE SCHEMA IF NOT EXISTS ingest;

CREATE SCHEMA IF NOT EXISTS model;

CREATE SCHEMA IF NOT EXISTS forecast;

CREATE SCHEMA IF NOT EXISTS markets;

CREATE SCHEMA IF NOT EXISTS backtest;

CREATE SCHEMA IF NOT EXISTS governance;

CREATE SCHEMA IF NOT EXISTS ops;

CREATE TABLE catalog.league (
  id uuid PRIMARY KEY,
  code text NOT NULL UNIQUE, name text NOT NULL, active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL, updated_at timestamptz NOT NULL DEFAULT now(), updated_by text NOT NULL, version bigint NOT NULL DEFAULT 1 CHECK(version>=1)
);

CREATE TABLE catalog.season (
  id uuid PRIMARY KEY,
  league_id uuid NOT NULL REFERENCES catalog.league(id), code text NOT NULL, starts_on date NOT NULL, ends_on date NOT NULL, UNIQUE(league_id,code), CHECK(ends_on>=starts_on),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE catalog.team (
  id uuid PRIMARY KEY,
  name text NOT NULL, country_code text NOT NULL, active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL, updated_at timestamptz NOT NULL DEFAULT now(), updated_by text NOT NULL, version bigint NOT NULL DEFAULT 1 CHECK(version>=1)
);

CREATE TABLE catalog.season_team (
  id uuid PRIMARY KEY,
  season_id uuid NOT NULL REFERENCES catalog.season(id), team_id uuid NOT NULL REFERENCES catalog.team(id), UNIQUE(season_id,team_id),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE catalog.source (
  id uuid PRIMARY KEY,
  code text NOT NULL UNIQUE, name text NOT NULL, terms_hash text NOT NULL, automation_allowed boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL, updated_at timestamptz NOT NULL DEFAULT now(), updated_by text NOT NULL, version bigint NOT NULL DEFAULT 1 CHECK(version>=1)
);

CREATE TABLE catalog.bookmaker (
  id uuid PRIMARY KEY,
  code text NOT NULL UNIQUE, name text NOT NULL, active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL, updated_at timestamptz NOT NULL DEFAULT now(), updated_by text NOT NULL, version bigint NOT NULL DEFAULT 1 CHECK(version>=1)
);

CREATE TABLE catalog.referee (
  id uuid PRIMARY KEY,
  name text NOT NULL, country_code text NOT NULL, active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL, updated_at timestamptz NOT NULL DEFAULT now(), updated_by text NOT NULL, version bigint NOT NULL DEFAULT 1 CHECK(version>=1)
);

CREATE TABLE catalog.fixture (
  id uuid PRIMARY KEY,
  season_id uuid NOT NULL REFERENCES catalog.season(id), home_team_id uuid NOT NULL REFERENCES catalog.team(id), away_team_id uuid NOT NULL REFERENCES catalog.team(id), source_id uuid NOT NULL REFERENCES catalog.source(id), external_key text NOT NULL, UNIQUE(source_id,external_key), CHECK(home_team_id<>away_team_id),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE catalog.fixture_revision (
  id uuid PRIMARY KEY,
  fixture_id uuid NOT NULL REFERENCES catalog.fixture(id), revision integer NOT NULL CHECK(revision>0), kickoff_utc timestamptz NOT NULL, finished_at timestamptz, known_at timestamptz NOT NULL, availability_mode text NOT NULL CHECK(availability_mode IN ('Strict','Assumed')), status text NOT NULL CHECK(status IN ('Scheduled','Postponed','Completed','Abandoned','Cancelled')), referee_id uuid REFERENCES catalog.referee(id), UNIQUE(fixture_id,revision), CHECK(finished_at IS NULL OR finished_at>=kickoff_utc),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE catalog.entity_alias (
  id uuid PRIMARY KEY,
  source_id uuid NOT NULL REFERENCES catalog.source(id), entity_kind text NOT NULL CHECK(entity_kind IN ('Team','League','Referee','Bookmaker','Market')), context_key text NOT NULL, normalized_text text NOT NULL, revision integer NOT NULL CHECK(revision>0), target_id uuid NOT NULL, known_at timestamptz NOT NULL, reviewer text NOT NULL, mapping_hash text NOT NULL, UNIQUE(source_id,entity_kind,context_key,normalized_text,revision),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE catalog.market (
  id uuid PRIMARY KEY,
  family text NOT NULL, period text NOT NULL, selection text NOT NULL, line_quarter integer NOT NULL DEFAULT 0, rules_version text NOT NULL, has_line boolean NOT NULL, UNIQUE(family,period,selection,line_quarter,rules_version), CHECK(has_line OR line_quarter=0),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE ingest.batch (
  id uuid PRIMARY KEY,
  source_id uuid NOT NULL REFERENCES catalog.source(id), payload_hash text NOT NULL, mapping_hash text NOT NULL, availability_policy_hash text NOT NULL, artifact_path text NOT NULL, status text NOT NULL CHECK(status IN ('Pending','Parsing','Completed','Failed','Quarantined')), retrieved_at timestamptz NOT NULL, UNIQUE(source_id,payload_hash,mapping_hash,availability_policy_hash),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL, updated_at timestamptz NOT NULL DEFAULT now(), updated_by text NOT NULL, version bigint NOT NULL DEFAULT 1 CHECK(version>=1)
);

CREATE TABLE ingest.observation (
  id uuid PRIMARY KEY,
  batch_id uuid NOT NULL REFERENCES ingest.batch(id), fixture_id uuid NOT NULL REFERENCES catalog.fixture(id), source_id uuid NOT NULL REFERENCES catalog.source(id), metric text NOT NULL, subject text NOT NULL CHECK(subject IN ('Home','Away','Match')), period text NOT NULL, revision integer NOT NULL CHECK(revision>0), numeric_value numeric(20,8) NOT NULL CHECK(numeric_value>=0 AND numeric_value<'Infinity'::numeric), occurred_at timestamptz NOT NULL, available_at timestamptz, eligible_at timestamptz NOT NULL, availability_mode text NOT NULL CHECK(availability_mode IN ('Strict','Assumed')), availability_evidence_hash text NOT NULL, definition_hash text NOT NULL, UNIQUE(source_id,fixture_id,metric,subject,period,revision), CHECK(availability_mode<>'Strict' OR (available_at IS NOT NULL AND eligible_at=available_at)),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE ingest.quality_issue (
  id uuid PRIMARY KEY,
  batch_id uuid NOT NULL REFERENCES ingest.batch(id), observation_id uuid REFERENCES ingest.observation(id), row_number integer, field_name text, code text NOT NULL, severity text NOT NULL CHECK(severity IN ('Warning','Error')), details jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE ingest.snapshot (
  id uuid PRIMARY KEY,
  as_of_utc timestamptz NOT NULL, availability_mode text NOT NULL CHECK(availability_mode IN ('Strict','Assumed')), manifest jsonb NOT NULL, content_hash text NOT NULL UNIQUE, schema_version integer NOT NULL CHECK(schema_version>0),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE ingest.snapshot_observation (
  id uuid PRIMARY KEY,
  snapshot_id uuid NOT NULL REFERENCES ingest.snapshot(id), observation_id uuid NOT NULL REFERENCES ingest.observation(id), UNIQUE(snapshot_id,observation_id),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE model.config_version (
  id uuid PRIMARY KEY,
  profile_key text NOT NULL, revision integer NOT NULL CHECK(revision>0), payload jsonb NOT NULL, content_hash text NOT NULL UNIQUE, UNIQUE(profile_key,revision),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE model.model_version (
  id uuid PRIMARY KEY,
  league_id uuid NOT NULL REFERENCES catalog.league(id), training_snapshot_id uuid NOT NULL REFERENCES ingest.snapshot(id), config_version_id uuid NOT NULL REFERENCES model.config_version(id), family text NOT NULL, training_cutoff timestamptz NOT NULL, artifact_path text NOT NULL, content_hash text NOT NULL UNIQUE, code_commit text NOT NULL, diagnostics jsonb NOT NULL, schema_version integer NOT NULL CHECK(schema_version>0),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE model.calibration_version (
  id uuid PRIMARY KEY,
  model_version_id uuid NOT NULL REFERENCES model.model_version(id), snapshot_id uuid NOT NULL REFERENCES ingest.snapshot(id), method text NOT NULL, training_cutoff timestamptz NOT NULL, payload jsonb NOT NULL, content_hash text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE forecast.distribution (
  id uuid PRIMARY KEY,
  model_version_id uuid NOT NULL REFERENCES model.model_version(id), calibration_version_id uuid REFERENCES model.calibration_version(id), payload jsonb NOT NULL, content_hash text NOT NULL UNIQUE, omitted_mass_bound double precision NOT NULL CHECK(omitted_mass_bound>=0 AND omitted_mass_bound<=1e-9), schema_version integer NOT NULL CHECK(schema_version>0),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE forecast.prediction (
  id uuid PRIMARY KEY,
  fixture_id uuid NOT NULL REFERENCES catalog.fixture(id), fixture_revision_id uuid NOT NULL REFERENCES catalog.fixture_revision(id), snapshot_id uuid NOT NULL REFERENCES ingest.snapshot(id), config_version_id uuid NOT NULL REFERENCES model.config_version(id), distribution_id uuid NOT NULL REFERENCES forecast.distribution(id), as_of_utc timestamptz NOT NULL, request_key text NOT NULL UNIQUE, request_hash text NOT NULL, mode text NOT NULL CHECK(mode IN ('Live','Replay','Legacy','Scenario')), diagnostics jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE forecast.market_probability (
  id uuid PRIMARY KEY,
  prediction_id uuid NOT NULL REFERENCES forecast.prediction(id), market_id uuid NOT NULL REFERENCES catalog.market(id), p_win double precision NOT NULL, p_half_win double precision NOT NULL DEFAULT 0, p_push double precision NOT NULL DEFAULT 0, p_half_loss double precision NOT NULL DEFAULT 0, p_loss double precision NOT NULL, p05 double precision, p95 double precision, uncertainty_method text, UNIQUE(prediction_id,market_id), CHECK(p_win BETWEEN 0 AND 1 AND p_half_win BETWEEN 0 AND 1 AND p_push BETWEEN 0 AND 1 AND p_half_loss BETWEEN 0 AND 1 AND p_loss BETWEEN 0 AND 1), CHECK(abs(p_win+p_half_win+p_push+p_half_loss+p_loss-1)<1e-10), CHECK((p05 IS NULL AND p95 IS NULL) OR (p05 IS NOT NULL AND p95 IS NOT NULL AND p05 BETWEEN 0 AND 1 AND p95 BETWEEN p05 AND 1)),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE markets.odds_group (
  id uuid PRIMARY KEY,
  fixture_id uuid NOT NULL REFERENCES catalog.fixture(id), bookmaker_id uuid NOT NULL REFERENCES catalog.bookmaker(id), source_id uuid NOT NULL REFERENCES catalog.source(id), capture_key text NOT NULL, captured_at timestamptz NOT NULL, available_at timestamptz, availability_mode text NOT NULL CHECK(availability_mode IN ('Strict','Assumed')), contract_group_key text NOT NULL, cost_rules jsonb NOT NULL, UNIQUE(source_id,capture_key), CHECK(availability_mode<>'Strict' OR available_at IS NOT NULL),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE markets.quote (
  id uuid PRIMARY KEY,
  group_id uuid NOT NULL REFERENCES markets.odds_group(id), market_id uuid NOT NULL REFERENCES catalog.market(id), decimal_odds numeric(18,8) NOT NULL CHECK(decimal_odds>1 AND decimal_odds<'Infinity'::numeric), original_text text NOT NULL, original_format text NOT NULL CHECK(original_format IN ('Decimal','Fractional','American')), quoted_at timestamptz NOT NULL, stake_limit numeric(20,8) CHECK(stake_limit>0 AND stake_limit<'Infinity'::numeric), UNIQUE(group_id,market_id),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE backtest.run (
  id uuid PRIMARY KEY,
  spec jsonb NOT NULL, spec_hash text NOT NULL UNIQUE, code_commit text NOT NULL, seed bigint NOT NULL, status text NOT NULL CHECK(status IN ('Pending','Running','Failed','Cancelled','Completed')), report_path text,
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL, updated_at timestamptz NOT NULL DEFAULT now(), updated_by text NOT NULL, version bigint NOT NULL DEFAULT 1 CHECK(version>=1)
);

CREATE TABLE backtest.fold (
  id uuid PRIMARY KEY,
  run_id uuid NOT NULL REFERENCES backtest.run(id), ordinal integer NOT NULL CHECK(ordinal>=0), train_start timestamptz NOT NULL, train_end timestamptz NOT NULL, validation_end timestamptz NOT NULL, test_end timestamptz NOT NULL, UNIQUE(run_id,ordinal), CHECK(train_start<train_end AND train_end<validation_end AND validation_end<test_end),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE backtest.position (
  id uuid PRIMARY KEY,
  run_id uuid NOT NULL REFERENCES backtest.run(id), prediction_id uuid NOT NULL REFERENCES forecast.prediction(id), quote_id uuid NOT NULL REFERENCES markets.quote(id), decision_at timestamptz NOT NULL, stake numeric(20,8) NOT NULL CHECK(stake>0 AND stake<'Infinity'::numeric), currency char(3) NOT NULL, selection_key text NOT NULL, cost_assumptions jsonb NOT NULL, UNIQUE(run_id,selection_key),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE backtest.ledger_entry (
  id uuid PRIMARY KEY,
  run_id uuid NOT NULL REFERENCES backtest.run(id), position_id uuid REFERENCES backtest.position(id), entry_type text NOT NULL CHECK(entry_type IN ('Initial','Reserve','Release','Profit','Commission','Fee','Reversal')), cash_delta numeric(20,8) NOT NULL CHECK(cash_delta>'-Infinity'::numeric AND cash_delta<'Infinity'::numeric), reserve_delta numeric(20,8) NOT NULL CHECK(reserve_delta>'-Infinity'::numeric AND reserve_delta<'Infinity'::numeric), effective_at timestamptz NOT NULL, idempotency_key text NOT NULL UNIQUE, reverses_entry_id uuid REFERENCES backtest.ledger_entry(id), outcome_snapshot_id uuid REFERENCES ingest.snapshot(id),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE backtest.metric (
  id uuid PRIMARY KEY,
  run_id uuid NOT NULL REFERENCES backtest.run(id), cohort_key text NOT NULL, metric_name text NOT NULL, value double precision CHECK(value>'-Infinity'::double precision AND value<'Infinity'::double precision), sample_count integer NOT NULL CHECK(sample_count>=0), interval jsonb, UNIQUE(run_id,cohort_key,metric_name),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE governance.approval_event (
  id uuid PRIMARY KEY,
  artifact_kind text NOT NULL, artifact_id uuid NOT NULL, artifact_hash text NOT NULL, state text NOT NULL CHECK(state IN ('Draft','Approved','Deprecated','Rejected')), reason text NOT NULL, evidence_path text NOT NULL, actor_role text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE governance.readiness_event (
  id uuid PRIMARY KEY,
  league_id uuid NOT NULL REFERENCES catalog.league(id), market_id uuid NOT NULL REFERENCES catalog.market(id), model_version_id uuid NOT NULL REFERENCES model.model_version(id), state text NOT NULL CHECK(state IN ('Enabled','Degraded','Quarantined','Disabled')), reason text NOT NULL, evidence_path text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE governance.audit_event (
  id uuid PRIMARY KEY,
  event_type text NOT NULL, target_kind text NOT NULL, target_id uuid NOT NULL, before_hash text, after_hash text, reason text NOT NULL, details jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE ops.job (
  id uuid PRIMARY KEY,
  kind text NOT NULL, payload jsonb NOT NULL, payload_hash text NOT NULL, idempotency_key text NOT NULL UNIQUE, status text NOT NULL CHECK(status IN ('Pending','Running','Retry','Succeeded','Failed','Cancelled')), next_attempt_at timestamptz NOT NULL, lease_token uuid, lease_generation bigint NOT NULL DEFAULT 0, lease_until timestamptz, attempts integer NOT NULL DEFAULT 0 CHECK(attempts>=0), max_attempts integer NOT NULL DEFAULT 3 CHECK(max_attempts>=1), checkpoint jsonb, error_code text, CHECK(status<>'Running' OR (lease_token IS NOT NULL AND lease_until IS NOT NULL)),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL, updated_at timestamptz NOT NULL DEFAULT now(), updated_by text NOT NULL, version bigint NOT NULL DEFAULT 1 CHECK(version>=1)
);

CREATE TABLE ops.job_attempt (
  id uuid PRIMARY KEY,
  job_id uuid NOT NULL REFERENCES ops.job(id), attempt_number integer NOT NULL CHECK(attempt_number>0), lease_generation bigint NOT NULL, started_at timestamptz NOT NULL, ended_at timestamptz, outcome text, evidence_path text, UNIQUE(job_id,attempt_number),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL, updated_at timestamptz NOT NULL DEFAULT now(), updated_by text NOT NULL, version bigint NOT NULL DEFAULT 1 CHECK(version>=1)
);

CREATE TABLE ops.outbox (
  id uuid PRIMARY KEY,
  event_type text NOT NULL, payload jsonb NOT NULL, aggregate_key text NOT NULL, dispatched_at timestamptz, attempts integer NOT NULL DEFAULT 0 CHECK(attempts>=0),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL, updated_at timestamptz NOT NULL DEFAULT now(), updated_by text NOT NULL, version bigint NOT NULL DEFAULT 1 CHECK(version>=1)
);

CREATE TABLE ops.inbox (
  id uuid PRIMARY KEY,
  consumer_key text NOT NULL, event_id uuid NOT NULL REFERENCES ops.outbox(id), UNIQUE(consumer_key,event_id),
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL
);

CREATE TABLE ops.schedule (
  id uuid PRIMARY KEY,
  kind text NOT NULL, timezone_id text NOT NULL, schedule_expression text NOT NULL, enabled boolean NOT NULL DEFAULT false, last_due_at timestamptz, next_due_at timestamptz NOT NULL, payload jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL, updated_at timestamptz NOT NULL DEFAULT now(), updated_by text NOT NULL, version bigint NOT NULL DEFAULT 1 CHECK(version>=1)
);

CREATE TABLE ops.alert (
  id uuid PRIMARY KEY,
  code text NOT NULL, severity text NOT NULL CHECK(severity IN ('Info','Warning','Critical')), target_key text NOT NULL, dedupe_key text NOT NULL UNIQUE, details jsonb NOT NULL, acknowledged_at timestamptz, resolved_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(), created_by text NOT NULL, correlation_id uuid NOT NULL, updated_at timestamptz NOT NULL DEFAULT now(), updated_by text NOT NULL, version bigint NOT NULL DEFAULT 1 CHECK(version>=1)
);

CREATE INDEX ix_observation_asof ON ingest.observation(fixture_id,metric,subject,period,eligible_at DESC,revision DESC);

CREATE INDEX ix_fixture_revision_asof ON catalog.fixture_revision(fixture_id,known_at DESC);

CREATE INDEX ix_prediction_fixture_time ON forecast.prediction(fixture_id,as_of_utc DESC,id);

CREATE INDEX ix_odds_fixture_time ON markets.odds_group(bookmaker_id,fixture_id,captured_at DESC);

CREATE INDEX ix_job_ready ON ops.job(next_attempt_at,created_at) WHERE status IN ('Pending','Retry');

CREATE INDEX ix_job_expired ON ops.job(lease_until) WHERE status='Running';

CREATE INDEX ix_outbox_pending ON ops.outbox(created_at) WHERE dispatched_at IS NULL;

CREATE INDEX ix_audit_correlation ON governance.audit_event(correlation_id,created_at);

CREATE INDEX ix_alias_lookup ON catalog.entity_alias(source_id,entity_kind,context_key,normalized_text,known_at DESC);

CREATE INDEX ix_ledger_run_time ON backtest.ledger_entry(run_id,effective_at,id);

CREATE INDEX ix_readiness_latest ON governance.readiness_event(league_id,market_id,model_version_id,created_at DESC);

COMMIT;

-- GRANT policy is intentionally a separate operator step; roles are environment-owned.

-- Immutable tables: app SELECT/INSERT only, never UPDATE/DELETE/TRUNCATE.

-- Mutable tables: app SELECT/INSERT/UPDATE; retention uses a separate audited operator role.

-- Schema owner/migrator is never the runtime application identity.
