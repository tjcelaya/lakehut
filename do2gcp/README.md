# do2gcp

Seed for migrating a medallion-architecture data lake from DigitalOcean
(Spaces + droplets) to GCP. Self-contained on purpose — lift this directory into
its own repo when the project gets one. **Read [PLAN.md](./PLAN.md) first**; this
file is just the runbook for what exists so far: bucket provisioning and the
per-bucket data pull (Phase 1).

## Prerequisites

- terraform >= 1.5
- rclone
- GCP credentials: `gcloud auth application-default login`
  (or `GOOGLE_APPLICATION_CREDENTIALS=/path/to/sa.json`)
- Spaces credentials exported as the AWS-style pair rclone's S3 backend reads:

  ```bash
  export AWS_ACCESS_KEY_ID=<spaces access key>
  export AWS_SECRET_ACCESS_KEY=<spaces secret key>
  ```

## 1. Create the GCS buckets

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # edit: project + DO→GCS bucket map
terraform init
terraform apply
```

One GCS bucket per Spaces bucket, same name unless GCS's global namespace forces
a prefix. Versioning is on by default as a guard while these hold the only GCP
copy.

## 2. Pull a bucket

```bash
cd sync
cp rclone.conf.example rclone.conf   # edit: your Spaces region endpoint

./pull-bucket.sh -n myproj-bronze    # dry run first
./pull-bucket.sh myproj-bronze       # real pull
./pull-bucket.sh -v myproj-bronze    # verify: rclone check + size on both sides
```

Repeat per bucket. Re-running is the refresh mechanism: `rclone sync` is
idempotent and moves only deltas, so run it manually whenever GCS should catch
up to Spaces. If the terraform map gave a bucket a different GCS name, pass it
as the second argument (or set `GCS_BUCKET_PREFIX`).

## Notes and caveats

- **Mirror semantics.** `rclone sync` also deletes objects that disappeared
  upstream — that's what keeps the consumer-facing data model identical on both
  sides, and it's why bucket versioning stays on during migration. Use `-n` when
  unsure.
- **Where to run it.** Data flows DO → wherever this runs → GCS. A small GCE VM
  gives the fastest write side and free GCS ingress; DO egress is billed the
  same either way.
- **Throughput.** Defaults (32 transfers / 64 checkers) are a reasonable start;
  tune with `TRANSFERS`/`CHECKERS`. Buckets full of small objects are limited by
  request rate, not bandwidth.
- **Verification depth.** `-v` compares listings by size (Spaces multipart ETags
  aren't plain MD5, so checksum comparison false-alarms). For a deeper audit of
  a sensitive prefix: `rclone check do:bucket/prefix gcs:bucket/prefix --download`.
- **Metadata.** rclone preserves Content-Type and custom object metadata; if any
  job depends on object metadata, spot-check it on the GCS side early.
