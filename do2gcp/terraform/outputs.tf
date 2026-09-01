output "bucket_map" {
  description = "DO Spaces bucket -> created GCS bucket name."
  value       = { for do_name, b in google_storage_bucket.medallion : do_name => b.name }
}

output "bucket_urls" {
  description = "DO Spaces bucket -> gs:// URL."
  value       = { for do_name, b in google_storage_bucket.medallion : do_name => b.url }
}
