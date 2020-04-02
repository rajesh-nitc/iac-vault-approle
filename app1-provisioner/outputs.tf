output "terraform_token" {
  value       = vault_token.terraform_token.client_token
}

output "gitlab_token" {
  value       = vault_token.gitlab_token.client_token
}