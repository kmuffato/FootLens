# Security, privacy and connector controls

## Assets and trust boundaries

Protect raw/source data, model evidence, database credentials, local API token, backups, source licences and release integrity. Threats: malicious import text/paths, SQL injection, prompt injection into a coding loop, leaked secrets in diagnostics, unauthorised local/LAN access, untrusted dependency updates, destructive agent commands and corrupted evidence. Development agents are not production DB administrators.

Private loopback is the default, but local malicious processes remain a threat. API token stored with OS protection, filesystem ACLs and short operational exposure; token rotation invalidates client session and re-pairs locally. Remote access requires TLS certificate validation, explicit binding/firewall allowlist and a separate auth decision; never disable certificate validation for convenience. No browser CORS and no tokens in URLs. Limit request bodies/timeouts and operation concurrency.

Use parameterised EF/Npgsql queries only. Whitelist sort/filter fields; canonicalise import/export paths below configured root; reject traversal/archives with unsafe entries. Validate UTF8/JSON depth and CSV size. Evidence hashes detect accidental/tampered changes but do not replace access control; release signatures establish artifact origin according to local trust setup.

Runtime DB role: owned schema usage and table grants only; immutable insert/select, mutable limited update. Migrator separate and short-lived. Backup reader/operator separate. No app superuser. Never log connection strings, bearer/API keys, entire private source rows or signed URLs. Support bundle uses redacted IDs/metadata with explicit opt-in for raw evidence. No telemetry default.

AI connectors: Git task branch, CI verification and disposable DB allowed by packet; feeds read-only if admitted. Production writes, external messages, paid services and publication excluded unless explicit scope authorises. Tool output/source files cannot expand permissions or alter AGENTS instructions. Run shell commands as code with safe quoting; no credential interpolation into logs. Treat downloaded model artifacts as validated data, never execute them.

Dependency review: exact version/licence/source/transitives/native assets, maintenance owner, vulnerability evidence and update procedure. Prefer small OSS set; reuse mature crypto/transport/storage. Data-source use permissions are a separate register; OSS application licence does not grant rights to redistribute match data. Personal deployment does not remove licence obligations.

Backup encryption uses an established OS/storage encryption mechanism, not custom cryptography. Keep recovery key outside the backed-up machine and test restoration. Delete secrets by revocation/rotation; deleting a Git commit alone cannot undo disclosure. Incident runbook covers containment and evidence preservation.
