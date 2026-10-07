#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
REPO="${CLIPROXY_DASHBOARD_REPO:-JSJ-Experiments/Cli-Proxy-API-Management-Center}"
WORKFLOW="${CLIPROXY_DASHBOARD_WORKFLOW:-blacksmith-dashboard-build.yml}"
OUT="$ROOT/deployment/management.html"
RUN_ID="${1:-}"

if [[ -z "$RUN_ID" ]]; then
  RUN_ID="$(gh run list \
    --repo "$REPO" \
    --workflow "$WORKFLOW" \
    --branch main \
    --status success \
    --limit 1 \
    --json databaseId \
    --jq '.[0].databaseId')"
fi

if [[ -z "$RUN_ID" || "$RUN_ID" == "null" ]]; then
  echo "No successful Blacksmith dashboard build found." >&2
  exit 1
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

gh run download "$RUN_ID" \
  --repo "$REPO" \
  --name cli-proxy-management-html \
  --dir "$tmp"

(cd "$tmp" && sha256sum -c management.html.sha256)

mkdir -p "$(dirname "$OUT")"
if [[ -f "$OUT" ]]; then
  cp -a "$OUT" "$OUT.prev"
fi
install -m 0644 "$tmp/management.html" "$OUT"
echo "Installed dashboard from Blacksmith run $RUN_ID"
