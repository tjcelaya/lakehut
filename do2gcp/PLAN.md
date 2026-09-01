# DO → GCP medallion migration

Source of truth for current infra is the existing DO Terraform (Spaces +
droplets + Python tier-promotion jobs + Superset; end users read-only). Not in
this repo — `do2gcp/` is the seed for the GCP side, liftable into its own repo.

Constraints: data before jobs · buckets map 1:1 with object keys verbatim ·
pulls are manual + repeatable for now · both stacks run in parallel before
cutover · networking/firewalls out of scope.

## What moves where

| DigitalOcean                      | GCP                                        | Phase |
| --------------------------------- | ------------------------------------------ | ----- |
| Spaces bucket per tier            | GCS bucket 1:1 (`terraform/`)              | 1     |
| Python jobs on droplets           | GCE lift **or** Cloud Run Jobs (TBD)       | 2     |
| Job triggers (cron?)              | manual now → Cloud Scheduler               | 2     |
| Superset metadata Postgres        | Cloud SQL                                  | 3     |
| Superset                          | like-for-like compose on GCE first         | 3     |
| End-user read path (DNS/LB/CDN)   | decided at cutover                         | 4     |
| DO Terraform stack                | destroy after retention window             | 4     |

## Phases

### 0 — Inventory
- [ ] Bucket list + regions; `rclone size` per bucket
- [ ] Flag any public/CDN-fronted bucket (GCS side enforces private)
- [ ] Job list: tier in/out + trigger mechanism per job
- [ ] Egress estimate (DO overage ~$0.01/GiB; GCS ingress free)

### 1 — Data copy (this directory)
- [ ] `terraform.tfvars` bucket map → `terraform apply`
- [ ] Creds: Spaces keypair + GCP ADC
- [ ] `pull-bucket.sh` per bucket; `-v` to verify
- [ ] Manual re-pull cadence until cutover (sync is idempotent, deltas only)

**Gate:** every bucket verified + repeatably refreshed before Phase 2.

### 2 — Jobs
- [ ] IO port — A: S3-interop endpoint swap (HMAC, `storage.googleapis.com`;
      test multipart) · B: `gcsfs`/`fsspec`
- [ ] Hosting: GCE lift-and-shift vs Cloud Run Jobs + Scheduler
- [ ] Parallel run; stop mirroring tiers GCP jobs now produce (mirror and job
      would fight over the bucket)
- [ ] Gold parity checked logically (counts/aggregates), not byte-wise

### 3 — Superset (config details pending)
- [ ] Route: `pg_dump` → Cloud SQL (full fidelity, same version) vs
      `superset export-dashboards` bundles (selective, loses users/roles)
- [ ] `SUPERSET_SECRET_KEY` must travel with the metadata DB, else
      `superset re-encrypt-secrets`
- [ ] Remap DB connections to the GCP serving layer
- [ ] Like-for-like deploy; diff dashboards against DO while both run

### 4 — Cutover
- [ ] Freeze DO writers → final delta pull → verify
- [ ] Flip readers to GCP; observation window (rollback = flip back)
- [ ] Retention window → `terraform destroy` DO stack

## Tooling (existing, don't build)

- **rclone** — the answer; what `sync/` wraps (`sync`/`check`/`size`)
- **GCP Storage Transfer Service** — managed alternative; S3-compatible sources
  need self-hosted agents; worth it only for scale or managed scheduling
- **mc mirror** — fine, redundant next to rclone
- Skip: s5cmd (S3-only) · Skyplane (dormant) · Airbyte/Sling/dlt (ELT-shaped,
  not object mirrors)
- Phase 2: fsspec/smart_open; parity via rclone check + datacompy/soda-core
- Phase 3: Superset CLI + pg_dump; nothing third-party

## Open questions

- Superset: version, metadata DB location, SECRET_KEY handling, what its
  connections point at (Trino? Postgres? direct gold reads?)
- Bucket inventory: names, regions, sizes, counts
- Any Spaces bucket public/CDN-fronted?
- Job trigger mechanism on DO today
- GCP job hosting: GCE vs Cloud Run Jobs
- DO bucket names free in GCS global namespace, or prefix needed?
  (changes consumer URIs — decide early)
- Terraform state backend before this stack grows
