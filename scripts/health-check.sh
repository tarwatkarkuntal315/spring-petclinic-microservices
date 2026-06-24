#!/usr/bin/env bash
# health-check.sh — Layer 2 health checks for Spring PetClinic Microservices
# Hits each service's Spring Boot Actuator /actuator/health endpoint.
# Usage: ./scripts/health-check.sh
# Exit code 0 if all healthy, 1 if any service is not 200.

set -uo pipefail

# service_name:port pairs
SERVICES=(
  "config-server:8888"
  "discovery-server:8761"
  "api-gateway:8080"
  "customers-service:8081"
  "vets-service:8083"
  "visits-service:8082"
  "genai-service:8084"
)

HOST="${HOST:-localhost}"
fail=0

echo "=== PetClinic Health Checks (host: $HOST) ==="
for entry in "${SERVICES[@]}"; do
  name="${entry%%:*}"
  port="${entry##*:}"
  code=$(curl -s -o /dev/null -w "%{http_code}" "http://${HOST}:${port}/actuator/health" || echo "000")
  if [ "$code" = "200" ]; then
    printf "  [PASS] %-20s (%s) -> %s\n" "$name" "$port" "$code"
  else
    printf "  [FAIL] %-20s (%s) -> %s\n" "$name" "$port" "$code"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "All services healthy."
else
  echo "One or more services unhealthy."
fi
exit "$fail"
