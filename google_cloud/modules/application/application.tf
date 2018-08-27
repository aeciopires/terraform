# Font:
# https://www.terraform.io/docs/providers/google/index.html
# https://cloud.google.com/compute/docs/images
# https://cloud.google.com/compute/docs/reference/rest/v1/addresses/get
#------------------------------------------------

# Create Instance 1
resource "google_compute_instance" "default" {
  name         = "ci-server2"
  machine_type = "${var.machine_type}"
  zone         = "${var.gc_zone}"

  tags = ["livro", "terraform", "test"]

  boot_disk {
    initialize_params {
      image = "${var.operating_system}"
    }
  }

  // Local SSD disk
  scratch_disk {
  }

  network_interface {
    network = "default"
  }
}

# Get IP Address instance 1
data "google_compute_address" "address_ci-server2" {
  name    = "ci-server2"
  project = "${var.gc_project}"
  zone    = "${var.gc_zone}"
}

# Create Instance 2
resource "google_compute_instance" "default" {
  name         = "code2"
  machine_type = "${var.machine_type}"
  zone         = "${var.gc_zone}"

  tags = ["livro", "terraform", "test"]

  boot_disk {
    initialize_params {
      image = "${var.operating_system}"
    }
  }

  // Local SSD disk
  scratch_disk {
  }

  network_interface {
    network = "default"
  }
}

# Get IP Address instance 2
data "google_compute_address" "address_code2" {
  name    = "code2"
  project = "${var.gc_project}"
  zone    = "${var.gc_zone}"
}

# Create Instance 3
resource "google_compute_instance" "default" {
  name         = "node-ubuntu2"
  machine_type = "${var.machine_type}"
  zone         = "${var.gc_zone}"

  tags = ["livro", "terraform", "test"]

  boot_disk {
    initialize_params {
      image = "${var.operating_system}"
    }
  }

  // Local SSD disk
  scratch_disk {
  }

  network_interface {
    network = "default"
  }
}

# Get IP Address instance 3
data "google_compute_address" "address_node-ubuntu2" {
  name    = "node-ubuntu2"
  project = "${var.gc_project}"
  zone    = "${var.gc_zone}"
}

# Configure Remote Access
resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  source_tags = ["allowall"]
}

# Use this data source to get information about a Google Billing Account
data "google_billing_account" "acct" {
  display_name = "My Billing Account"
  open         = true
}

resource "google_project" "my_project" {
  name       = "My Project"
  project_id = "${var.gc_project}"

  billing_account = "${data.google_billing_account.acct.id}"
}
