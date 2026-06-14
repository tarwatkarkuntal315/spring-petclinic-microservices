variable "project_name" {
  description = "Prefix for resource names and tags"
  type        = string
  default     = "petclinic"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "petclinic-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster and node group"
  type        = string
  default     = "1.30"
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS control plane (from the iam module)"
  type        = string
}

variable "node_role_arn" {
  description = "ARN of the IAM role for EKS worker nodes (from the iam module)"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of private subnets to place the control plane and nodes in (from the vpc module)"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "instance_types" {
  description = "EC2 instance types for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}
