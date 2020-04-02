provider "google" {
  version     = "~> 2.1"
  credentials = file("../tf-sa.json")
  project     = var.project_id
}

provider "google-beta" {
  version     = "~> 2.1"
  credentials = file("../tf-sa.json")
  project     = var.project_id
}

resource "google_compute_instance" "default" {
  name         = "bastion"
  machine_type = "f1-micro"
  zone         = "asia-south1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  metadata_startup_script = templatefile("templates/startup-script.tmpl", {

  })

  network_interface {
    network = "default"

    access_config {
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  tags = ["bastion"]
}

resource "google_compute_firewall" "bastion" {
  name    = "bastion"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion"]
}