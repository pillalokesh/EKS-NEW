variable "cluster_name" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "elasticache_sg_id" {
  type = string
}

variable "engine_version" {
  type    = string
  default = "7.0"
}

variable "node_type" {
  type    = string
  default = "cache.t3.medium"
}

variable "num_cache_clusters" {
  description = "Number of cache nodes (should be >= 2 for HA)"
  type        = number
  default     = 2
}

variable "tags" {
  type    = map(string)
  default = {}
}
