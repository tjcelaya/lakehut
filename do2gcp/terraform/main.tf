terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # Local state for now. Move to a GCS backend before this stack grows past
  # buckets (see PLAN.md open questions).
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# One GCS bucket per DO Spaces bucket, 1:1. Object keys are copied verbatim by
# the sync scripts, so the medallion data model consumers rely on is unchanged;
# only the bucket name can differ (GCS names are globally unique).
resource "google_storage_bucket" "medallion" {
  for_each = var.buckets

  name          = each.value
  project       = var.project_id
  location      = var.location
  storage_class = var.storage_class

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = var.force_destroy

  versioning {
    enabled = var.versioning
  }

  labels = merge(var.labels, {
    source_do_bucket = replace(each.key, ".", "-")
  })
}
