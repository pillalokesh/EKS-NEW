variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type    = string
  default = "1.29"
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "cluster_sg_id" {
  type = string
}

variable "nodes_sg_id" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the EKS public API endpoint. Restrict to your VPN/office CIDRs in production."
  type        = list(string)
  default     = ["0.0.0.0/0"] # Override in prod tfvars with your corporate egress CIDRs
}

# System node group
variable "system_node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "system_node_desired" {
  type    = number
  default = 2
}

variable "system_node_min" {
  type    = number
  default = 2
}

variable "system_node_max" {
  type    = number
  default = 4
}

# Application node group
variable "app_node_instance_types" {
  type    = list(string)
  default = ["t3.large"]
}

variable "app_node_capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "app_node_desired" {
  type    = number
  default = 2
}

variable "app_node_min" {
  type    = number
  default = 2
}

variable "app_node_max" {
  type    = number
  default = 10
}

# Addon versions
variable "vpc_cni_version" {
  type    = string
  default = "v1.16.0-eksbuild.1"
}

variable "coredns_version" {
  type    = string
  default = "v1.11.1-eksbuild.4"
}

variable "kube_proxy_version" {
  type    = string
  default = "v1.29.0-eksbuild.1"
}

variable "ebs_csi_version" {
  type    = string
  default = "v1.26.0-eksbuild.1"
}

variable "tags" {
  type    = map(string)
  default = {}
}
