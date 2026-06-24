#!/usr/bin/env bash
# api-tests.sh — Layer 3 functional/API tests for Spring PetClinic Microservices
# All requests route through the API gateway (port 8080).
# Usage: ./scripts/api-tests.sh
# Exit code 0 if all pass, 1 otherwise.

set -uo pipefail

HOST="${HOST:-localhost}"
GW="http://${HOST}:8080"
fail=0

check_code() {
  # $1 = label, $2 = url, $3 = expected code
  local label="$1" url="$2" expected="$3"
  local code
  code=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "000")
  if [ "$code" = "$expected" ]; then
    printf "  [PASS] %-28s -> %s\n" "$label" "$code"
  else
    printf "  [FAIL] %-28s -> %s (expected %s)\n" "$label" "$code" "$expected"
    fail=1
  fi
}

check_json_nonempty() {
  # $1 = label, $2 = url  (passes if HTTP 200 and body starts with '[' or '{')
  local label="$1" url="$2"
  local body
  body=$(curl -s "$url" || echo "")
  if [[ "$body" == \[* || "$body" == \{* ]]; then
    printf "  [PASS] %-28s -> JSON returned\n" "$label"
  else
    printf "  [FAIL] %-28s -> no JSON\n" "$label"
    fail=1
  fi
}

echo "=== PetClinic API Tests (gateway: $GW) ==="
check_code        "API-01 homepage"        "$GW/"                                   "200"
check_json_nonempty "API-02 owners list"   "$GW/api/customer/owners"
check_json_nonempty "API-03 vets list"     "$GW/api/vet/vets"
check_code        "API-04 visits endpoint" "$GW/api/visit/owners/1/pets/1/visits"   "200"

if [ "$fail" -eq 0 ]; then
  echo "All API tests passed."
else
  echo "One or more API tests failed."
fi
exit "$fail"
