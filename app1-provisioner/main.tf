provider "vault" {
  address = var.vault_address
  token = var.vault_token
}

data "vault_auth_backend" "approle" {
  path = "approle"
}

# App1
resource "vault_approle_auth_backend_role" "example" {
  backend   = data.vault_auth_backend.approle.path
  role_name = "app1"
  token_policies  = ["app1-secret-read"]
}

resource "vault_approle_auth_backend_role_secret_id" "id" {
  backend   = data.vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.example.role_name
}

resource "vault_policy" "app1-secret-read" {
  name = "app1-secret-read"

  policy = <<EOT
path "secret/app1" {
  capabilities = ["read", "list"]
}
EOT
}

# Terraform
resource "vault_policy" "app1-approle-roleid-get" {
  name = "app1-approle-roleid-get"

  policy = <<EOT
path "auth/approle/role/app1/role-id" {
  capabilities = ["read"]
}
EOT
}

resource "vault_policy" "perform-login" {
  name = "perform-login"

  policy = <<EOT
path "auth/approle/login" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOT
}

resource "vault_policy" "gcp-token-get" {
  name = "gcp-token-get"

  policy = <<EOT
path "gcp/token/project_editor_roleset" {
  capabilities = ["read"]
}
EOT
}

resource "vault_policy" "terraform-token-create" {
  name = "terraform-token-create"

  policy = <<EOT
path "auth/token/create" {
  capabilities = [ "update" ]
}

path "auth/token/lookup-accessor" {
  capabilities = ["update"]
}

path "auth/token/revoke-accessor" {
  capabilities = ["update"]
}
EOT
}

resource "vault_token" "terraform_token" {
  policies = ["app1-approle-roleid-get", "terraform-token-create", "gcp-token-get", "perform-login"]

  renewable = true
  ttl = "24h"

  renew_min_lease = 43200
  renew_increment = 86400
}

# Gitlab
resource "vault_policy" "app1-approle-secretid-create" {
  name = "app1-approle-secretid-create"

  policy = <<EOT
path "auth/approle/role/app1/secret-id" {
  capabilities = [ "update" ]
}
EOT
}

resource "vault_token" "gitlab_token" {
  policies = ["app1-approle-secretid-create"]

  renewable = true
  ttl = "24h"

  renew_min_lease = 43200
  renew_increment = 86400
}

# Put secret
resource "vault_generic_secret" "app1" {
  path = "secret/app1"

  data_json = <<EOT
{
  "id":   "1",
  "name": "app1"
}
EOT
}