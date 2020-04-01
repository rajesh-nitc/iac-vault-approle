provider "google" {
  version     = "~> 2.1"
  access_token = data.vault_generic_secret.gcp_token.data["token"]
  project     = var.project_id
}

data "vault_generic_secret" "gcp_token" {
  path = "gcp/token/project_editor_roleset"
}

data "vault_approle_auth_backend_role_id" "role" {
  backend   = "approle"
  role_name = "app1"
}

# Initialize with tf token which can only read app1 roleid
provider "vault" {
  address = var.vault_address
  token = var.terraform_token
}

resource "google_compute_instance" "default" {
  name         = "app1"
  machine_type = "f1-micro"
  zone         = "asia-south1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  metadata_startup_script = templatefile("templates/startup-script.tmpl", {
    role_id = data.vault_approle_auth_backend_role_id.role.role_id
  })

  network_interface {
    network = "default"

    access_config {
    }
  }

  tags = ["http-server"]
}

resource "google_compute_firewall" "http-server" {
  name    = "default-allow-http-app1"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}