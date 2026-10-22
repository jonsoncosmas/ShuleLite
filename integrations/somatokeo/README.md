# SomaTokeo academic exchange boundary

Shule Lite and SomaTokeo remain separate products. This folder defines a versioned data contract for a future, explicitly authorized academic-results exchange. It does not contain a transport, endpoint, credential, or automatic synchronization job.

## Contract

`academic-results-v1.schema.json` describes a minimized export of already-published school results. An integration must provide an institution reference and stable learner references from an approved mapping; local database IDs are not external identifiers. The payload includes academic year, term, subject, assessment, exam, score, and maximum score. It excludes names, admission numbers, comments, guardian details, attendance, fees, and unpublished results.

## Before enabling an exchange

- Obtain the school's and authorized data controller's approval and define the lawful purpose, recipient, retention, and correction process.
- Map each Shule Lite school and pupil to opaque, stable external references. Reject missing or ambiguous mappings.
- Authorize access for the exact school and period on the server. Export only rows whose examination status is `results_published` at the time of export.
- Use authenticated transport, scoped credentials, replay protection, audit events, and a documented deletion/revocation process.
- Agree with SomaTokeo on contract versioning and validation before implementing a transport adapter.

No exchange is active until those decisions and controls exist. Do not add SomaTokeo tables or logic to the Shule Lite academic engine.
