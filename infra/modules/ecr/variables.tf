variable "project_name" {
  description = "Prefix for ECR repository names and tags"
  type        = string
  default     = "petclinic"
}

variable "service_names" {
  description = "Microservice names — one ECR repository is created per entry"
  type        = list(string)
  default = [
    "config-server",
    "discovery-server",
    "api-gateway",
    "customers-service",
    "vets-service",
    "visits-service",
    "admin-server",
    "genai-service",
  ]
}
