#!/usr/bin/env bash
#
# Repeatable, manually triggered pull of one DO Spaces bucket into its GCS
# counterpart. Mirror semantics: after a run, the GCS bucket matches the Spaces
# bucket exactly (objects deleted upstream are deleted here too), so consumers
# see the same data model on either side. Idempotent — re-runs move only deltas.
#
# Usage:
#   pull-bucket.sh [-n] [-v] <do-bucket> [gcs-bucket]
#
#   -n  dry run (show what would transfer/delete, change nothing)
#   -v  verify instead of pull (rclone check + size comparison)
#
# gcs-bucket defaults to GCS_BUCKET_PREFIX + do-bucket (prefix empty by default,
# i.e. same name — matching the 1:1 map in terraform/).
#
# Expects rclone remotes named "do" and "gcs" — see rclone.conf.example.
# Tuning via env: TRANSFERS (default 32), CHECKERS (default 64).

set -euo pipefail

usage() { awk 'NR>1 && /^#/ { sub(/^# ?/, ""); print; next } NR>1 { exit }' "$0"; exit 1; }

DRY_RUN=0
VERIFY=0
while getopts ":nv" opt; do
  case "$opt" in
    n) DRY_RUN=1 ;;
    v) VERIFY=1 ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))

[ $# -ge 1 ] || usage
DO_BUCKET="$1"
GCS_BUCKET="${2:-${GCS_BUCKET_PREFIX:-}${DO_BUCKET}}"

# Prefer the conf next to this script unless the caller already set one.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -z "${RCLONE_CONFIG:-}" ] && [ -f "$SCRIPT_DIR/rclone.conf" ]; then
  export RCLONE_CONFIG="$SCRIPT_DIR/rclone.conf"
fi

SRC="do:${DO_BUCKET}"
DST="gcs:${GCS_BUCKET}"

COMMON_FLAGS=(
  --fast-list
  --transfers "${TRANSFERS:-32}"
  --checkers "${CHECKERS:-64}"
  --retries 5
  --low-level-retries 20
  --stats 30s
  --stats-one-line
)

if [ "$VERIFY" -eq 1 ]; then
  echo "== size: $SRC"
  rclone size "$SRC" --fast-list
  echo "== size: $DST"
  rclone size "$DST" --fast-list
  echo "== check (size-only; Spaces multipart ETags are not plain MD5)"
  rclone check "$SRC" "$DST" --size-only --fast-list
  echo "OK: $DST matches $SRC"
  exit 0
fi

FLAGS=("${COMMON_FLAGS[@]}")
[ "$DRY_RUN" -eq 1 ] && FLAGS+=(--dry-run)

echo "== pull: $SRC -> $DST"
rclone sync "$SRC" "$DST" "${FLAGS[@]}"
echo "== done: $SRC -> $DST (run with -v to verify)"
