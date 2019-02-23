output "entrypoint" {
  value = "https://${cloudflare_record.domain.name}/"
}
