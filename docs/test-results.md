# Test Results — Spring PetClinic Microservices (Phase 2)

**Environment:** GitHub Codespaces (`zany-fortnight`), Docker Compose, full
11-container stack.
**Date of run:** Phase 2 validation session.
**LLM provider for genai-service:** OpenAI `gpt-4o-mini`.

Summary: **all executed tests passed.** Health 7/7, full API surface
functional, observability verified, IaC validated (Terraform config valid,
29/29 K8s manifests valid). Distributed tracing (Zipkin) captured across all
services including GenAI tool-call spans. Terraform `plan`/`apply` intentionally
not run (no AWS credentials, zero-budget).

---

## Layer 1 — Infrastructure Validation

| Test | Status | Notes |
|------|--------|-------|
| INF-01 Terraform validate | PASS | `terraform init -backend=false` + `validate` → "Success! The configuration is valid." (4 modules: vpc, iam, ecr, eks; AWS provider v5.100.0) |
| INF-02 Terraform plan | N/A (by design) | `plan` correctly stops at "No valid credential sources found" — AWS credentials intentionally not provided (zero-budget, no apply) |
| INF-03 K8s manifest YAML lint | PASS | 29/29 manifests parse via `yaml.safe_load_all` |
| INF-04 All services running | PASS | 11/11 containers Up (`docker compose ps`) |

## Layer 2 — Health Checks

All seven core services returned HTTP 200 on `/actuator/health`.

| Test | Service | Result | Status |
|------|---------|--------|--------|
| HLT-01 | config-server (8888) | 200 | PASS |
| HLT-02 | discovery-server (8761) | 200 | PASS |
| HLT-03 | api-gateway (8080) | 200 | PASS |
| HLT-04 | customers-service (8081) | 200 | PASS |
| HLT-05 | vets-service (8083) | 200 | PASS |
| HLT-06 | visits-service (8082) | 200 | PASS |
| HLT-07 | genai-service (8084) | 200 | PASS |

## Layer 3 — Functional / API Tests

| Test | Result | Status |
|------|--------|--------|
| API-01 Homepage loads | HTTP 200 | PASS |
| API-02 Owners list | HTTP 200, JSON (e.g. George Franklin → pet Leo) | PASS |
| API-03 Vets list | HTTP 200, JSON (e.g. James Carter; Helen Leary → radiology) | PASS |
| API-04 Visits endpoint | HTTP 200, `[]` (no visits for test pet — endpoint functional) | PASS |
| API-05 Add owner (browser) | New owners (Mangesh Patil, Tushar Bansal) appear in list | PASS |
| API-06 GenAI read | Chat returned live vet list with specialties | PASS |
| API-07 GenAI write | "Iggy" added for Pravin Gupta; reflected in owners list | PASS |

## Layer 4 — Observability Validation

| Test | Result | Status |
|------|--------|--------|
| OBS-01 Prometheus targets | All 5 targets UP (api-gateway, customers, vets, visits, prometheus) | PASS |
| OBS-02 Grafana dashboard | "Spring Petclinic Metrics" shows live HTTP latency + request activity | PASS |
| OBS-03 Zipkin distributed tracing | Traces captured across services (api-gateway, genai, customers, vets, visits); GenAI chat traced end-to-end with tool-call spans | PASS |

## Layer 5 — Resilience

| Test | Result | Status |
|------|--------|--------|
| RES-01 Service restart / re-register | Service deregistered on stop, re-registered in Eureka on start | PASS |

---

### Known limitations (documented honestly)

- **Distributed tracing (Zipkin):** enabled by adding
  `MANAGEMENT_ZIPKIN_TRACING_ENDPOINT` and `MANAGEMENT_TRACING_SAMPLING_PROBABILITY=1.0`
  to the application services. After restart and traffic generation, traces were
  captured across api-gateway, genai-service, customers-service, vets-service and
  visits-service, including Spring AI tool-call spans (listOwners,
  addOwnerToPetclinic, addPetToOwner, listVets).
- **No live AWS apply:** all AWS resources are defined and validated as IaC only.
  `terraform validate` passes cleanly; `terraform plan` correctly halts at AWS
  credential resolution (none provided, per the zero-budget constraint). The EKS
  topology is the documented deployment target and was exercised during the
  Phase 1 team build.
