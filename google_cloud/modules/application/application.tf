# Font:
# https://www.terraform.io/docs/providers/google/index.html
# https://cloud.google.com/compute/docs/images
# https://cloud.google.com/compute/docs/reference/rest/v1/addresses/get
#------------------------------------------------

# Create Instance 1
resource "google_compute_instance" "instance1" {
  name         = "ci-server2"
  machine_type = "${var.machine_type}"
  zone         = "${var.gc_zone}"

  tags = ["livro", "terraform", "test"]

  boot_disk {
    initialize_params {
      image = "${var.operating_system}"
    }
  }

  network_interface {
    network = "default"
  }
}

# Get IP Address instance 1
data "google_compute_address" "address_ci-server2" {
  name    = "ci-server2"
  project = "${var.gc_project}"
}

# Create Instance 2
resource "google_compute_instance" "instance2" {
  name         = "code2"
  machine_type = "${var.machine_type}"
  zone         = "${var.gc_zone}"

  tags = ["livro", "terraform", "test"]

  boot_disk {
    initialize_params {
      image = "${var.operating_system}"
    }
  }

  network_interface {
    network = "default"
  }
}

# Get IP Address instance 2
data "google_compute_address" "address_code2" {
  name    = "code2"
  project = "${var.gc_project}"
}

# Create Instance 3
resource "google_compute_instance" "instance3" {
  name         = "node-ubuntu2"
  machine_type = "${var.machine_type}"
  zone         = "${var.gc_zone}"

  tags = ["livro", "terraform", "test"]

  boot_disk {
    initialize_params {
      image = "${var.operating_system}"
    }
  }

  network_interface {
    network = "default"
  }
}

# Get IP Address instance 3
data "google_compute_address" "address_node-ubuntu2" {
  name    = "node-ubuntu2"
  project = "${var.gc_project}"
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
