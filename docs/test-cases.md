# Test Cases — Spring PetClinic Microservices (Phase 2)

This document defines the test suite for the Phase 2 capstone. Tests are
organized into five layers, modeled on a professional QA structure (infra
validation, health, functional/API, observability, resilience).

**Target architecture:** AWS EKS (Terraform-provisioned, manifests in `k8s/`).
**This-demo runtime:** GitHub Codespaces with Docker Compose (zero-budget
constraint — no live AWS apply). Tests below are written for the Codespaces
runtime; the EKS-equivalent command is noted where it differs.

---

## Layer 1 — Infrastructure Validation (IaC)

| ID | Test | Method | Expected |
|----|------|--------|----------|
| INF-01 | Terraform syntax valid | `terraform validate` in infra dir | "Success! The configuration is valid." |
| INF-02 | Terraform plan resolves | `terraform plan` (never `apply` — zero budget) | Plan computes with no errors |
| INF-03 | K8s manifests parse | Python `yaml.safe_load` over `k8s/**/*.yaml` | All files parse, no YAML errors |
| INF-04 | All services running | `docker compose ps` (EKS: `kubectl get pods -n spring-petclinic`) | All containers Up (EKS: all pods Running) |

## Layer 2 — Health Checks

Each service exposes Spring Boot Actuator at `/actuator/health`.

| ID | Service | Endpoint | Expected |
|----|---------|----------|----------|
| HLT-01 | config-server | `:8888/actuator/health` | 200 |
| HLT-02 | discovery-server | `:8761/actuator/health` | 200 |
| HLT-03 | api-gateway | `:8080/actuator/health` | 200 |
| HLT-04 | customers-service | `:8081/actuator/health` | 200 |
| HLT-05 | vets-service | `:8083/actuator/health` | 200 |
| HLT-06 | visits-service | `:8082/actuator/health` | 200 |
| HLT-07 | genai-service | `:8084/actuator/health` | 200 |

## Layer 3 — Functional / API Tests (through the gateway)

All requests routed via the API gateway on port 8080.

| ID | Test | Endpoint | Expected |
|----|------|----------|----------|
| API-01 | Homepage loads | `GET /` | 200, HTML |
| API-02 | Owners list | `GET /api/customer/owners` | 200, JSON array of owners |
| API-03 | Vets list | `GET /api/vet/vets` | 200, JSON array of vets |
| API-04 | Visits endpoint | `GET /api/visit/owners/1/pets/1/visits` | 200, JSON array (may be empty) |
| API-05 | Add owner (browser) | Find Owners → Add Owner → submit | New owner appears in list |
| API-06 | GenAI read (Spring AI) | Chat: "Which veterinarians are available?" | Real vet data returned |
| API-07 | GenAI write (tool-calling) | Chat: "add pet Iggy for Pravin Gupta" | Pet persisted, visible in owners list |

## Layer 4 — Observability Validation

| ID | Test | Method | Expected |
|----|------|--------|----------|
| OBS-01 | Prometheus scraping | Prometheus `:9091` → Status → Targets | All targets UP |
| OBS-02 | Grafana dashboard | Grafana `:3030` → "Spring Petclinic Metrics" | Panels show live data |
| OBS-03 | Zipkin tracing | Zipkin `:9411` Run Query after traffic | Distributed traces captured across services |

## Layer 5 — Resilience (local analog of chaos test)

| ID | Test | Method | Expected |
|----|------|--------|----------|
| RES-01 | Service restart / re-register | `docker compose stop customers-service` then `start` | Service deregisters then re-registers in Eureka |

*Note: true self-healing (auto-restart of failed pods) is a Kubernetes/EKS
behavior. On EKS this is `kubectl delete pod` → ReplicaSet recreates it. The
Compose analog above demonstrates the service-discovery recovery path.*
