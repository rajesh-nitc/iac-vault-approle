provider "vault" {
  address = var.vault_address
  token = var.vault_token
}

# setup approle in vault
resource "vault_auth_backend" "approle" {
  type = "approle"
}

# setup gcp credentails in vault
resource "vault_gcp_secret_backend" "gcp" {
  path        = "gcp"
  credentials = file("../tf-sa.json")
}

resource "vault_gcp_secret_roleset" "roleset" {
  backend      = vault_gcp_secret_backend.gcp.path
  roleset      = "project_editor_roleset"
  secret_type  = "access_token"
  project      = var.project_id
  token_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

  binding {
    resource = "//cloudresourcemanager.googleapis.com/projects/${var.project_id}"

    roles = [
      "roles/editor",
    ]
  }
}