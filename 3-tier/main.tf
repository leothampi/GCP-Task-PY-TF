terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = "microservices-workshop-368903"
  region  = "us-central1"
  zone    = "us-central1-c"
}

terraform {
 backend "gcs" {
   bucket  = "terra_bucket_leyon"
   prefix  = "terraform/state"
 }
}

resource "google_compute_network" "vpc_network" {
  name                    = "my-3-t-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  name          = "my-3-t-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-west1"
  network       = google_compute_network.vpc_network.id
}

# Create a single Compute Engine instance
resource "google_compute_instance" "default" {
  name         = "flask-vm"
  machine_type = "f1-micro"
  zone         = "us-west1-a"
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # Install Flask
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python3-pip rsync; pip install flask"

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}
resource "google_compute_network" "vpc_network2" {
  name                    = "sec-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default2" {
  name          = "sec-vpc-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = "us-west1"
  network       = google_compute_network.vpc_network2.id
}

resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}
resource "google_compute_firewall" "flask" {
  name    = "flask-app-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }
  source_ranges = ["0.0.0.0/0"]
}
# Create a single Compute Engine instance
resource "google_compute_instance" "default1" {
  name         = "application-vm"
  machine_type = "f1-micro"
  zone         = "us-west1-a"
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # Install Flask
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python3-pip rsync; pip install flask"

  network_interface {
    subnetwork = google_compute_subnetwork.default2.id

    access_config {
      
    }
  }
}
  resource "google_sql_database_instance" "master" {
    name = "master"
    database_version = "MYSQL_8_0"
    region = "us-central1"
    settings {
      tier = "db-n1-standard-2"
    }
    
    
  }
  resource "google_sql_database" "flask_db" {
    name = "flask_db"
    instance = "${google_sql_database_instance.master.name}"
    charset = "utf8"
    collation = "utf8_general_ci"
  }
  resource "google_sql_user" "users" {
    name = "root"
    instance = "${google_sql_database_instance.master.name}"
    host = "%"
    password = "Test@24"
  }


resource "google_compute_firewall" "allow_subnet" {
  name    = "allow-subnet"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["10.0.4.0/24"]
  target_tags   = ["subnet"]
}

resource "google_compute_target_http_proxy" "target_http_proxy" {
  name   = "my-target-http-proxy"
  url_map = google_compute_url_map.url_map.self_link
}

resource "google_compute_url_map" "url_map" {
  name            = "my-url-map"
  default_service = google_compute_backend_service.backend_service.self_link
}

resource "google_compute_backend_service" "backend_service" {
  name          = "my-backend-service"
  health_checks = [google_compute_health_check.health_check.self_link]
}

resource "google_compute_health_check" "health_check" {
  name = "my-health-check"
  check_interval_sec = 5
  timeout_sec = 5
  healthy_threshold = 2
  unhealthy_threshold = 2

  http_health_check {
    port = 80
  }
}

resource "google_compute_global_forwarding_rule" "global_forwarding_rule" {
  name = "my-global-forwarding-rule"
  target = google_compute_target_http_proxy.target_http_proxy.self_link
  load_balancing_scheme = "EXTERNAL"
}
