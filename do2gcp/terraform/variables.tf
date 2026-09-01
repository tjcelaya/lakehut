variable "project_id" {
  description = "GCP project to create the buckets in."
  type        = string
}

variable "region" {
  description = "Default provider region."
  type        = string
  default     = "us-central1"
}

variable "location" {
  description = "Bucket location: a region (us-central1) or multi-region (US)."
  type        = string
  default     = "us-central1"
}

variable "buckets" {
  description = <<-EOT
    Map of DO Spaces bucket name -> GCS bucket name, one entry per medallion
    tier bucket being migrated. Keep names identical unless taken in GCS's
    global namespace; object keys are always copied verbatim.
  EOT
  type        = map(string)
}

variable "versioning" {
  description = "Object versioning. On by default during migration as a guard against a bad sync run deleting objects; costs extra on churn — revisit after cutover."
  type        = bool
  default     = true
}

variable "storage_class" {
  type    = string
  default = "STANDARD"
}

variable "force_destroy" {
  description = "Allow terraform destroy to delete non-empty buckets. Keep false while these hold the only GCP copy."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Extra labels applied to every bucket."
  type        = map(string)
  default     = {}
}
