# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

###############
# Data Sources
###############
data "google_compute_image" "image" {
  project = "${var.source_image != "" ? var.source_image_project : "debian-cloud"}"
  name    = "${var.source_image != "" ? var.source_image : "debian-9-stretch-v20190326"}"
}

data "google_compute_image" "image_family" {
  project = "${var.source_image_family != "" ? var.source_image_project : "debian-cloud"}"
  family  = "${var.source_image_family != "" ? var.source_image_family : "debian-9"}"
}

data "template_file" "startup_script_config" {
  template = "${file("${path.module}/scripts/startup.tpl")}"

  vars = {
    BUCKET      = "${var.BUCKET}"
    ARCHIVE     = "${var.ARCHIVE}"
    ENVIRONMENT = "${var.environment}"
    DEVICE      = "${var.environment}"
    ADDON       = "${var.ADDON}"
  }
}


#########
# Locals
#########

locals {
  boot_disk = [{
    source_image = "${var.source_image != "" ? data.google_compute_image.image.self_link : data.google_compute_image.image_family.self_link}"
    disk_size_gb = "${var.disk_size_gb}"
    disk_type    = "${var.disk_type}"
    auto_delete  = "${var.auto_delete}"
    boot         = "true"
  }]
}

####################
# Instance Template
####################

resource "random_id" "service_account" {
  byte_length = 4
}

resource "google_service_account" "service_account" {
  account_id   = "${var.environment}${random_id.service_account.hex}"
  display_name = "${var.environment}${random_id.service_account.hex}"
}

resource "google_project_iam_member" "Compute_admin" {
  project = "${var.project}"
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "Storage_viewer" {
  project = "${var.project}"
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_compute_disk" "default" {
  name  = "${var.environment}"
  type  = "pd-ssd"
  size  = "${var.disk_size_gb}"
  zone  = "${var.zone}"
}

resource "google_compute_instance_template" "os_template" {
  name_prefix             = "${var.environment}-"
  machine_type            = "${var.machine_type}"
  labels                  = "${var.labels}"
  metadata                = "${var.metadata}"
  tags                    = ["${var.environment}"]
  can_ip_forward          = "${var.can_ip_forward}"
  metadata_startup_script = "${data.template_file.startup_script_config.rendered}"

  service_account  {
    email  = "${google_service_account.service_account.email}"
    scopes = ["cloud-platform"]
  }

  disk {
    source_image = "${var.source_image != "" ? data.google_compute_image.image.self_link : data.google_compute_image.image_family.self_link}"
    disk_size_gb = "${var.disk_size_gb}"
    disk_type    = "${var.disk_type}"
    auto_delete  = "${var.auto_delete}"
    boot         = "true"
  }

  disk {
    source      = "${google_compute_disk.default.name}"
    auto_delete = false
    boot        = false
  }

  network_interface {
    network            = "${var.network}"
    subnetwork         = "${var.subnetwork}"
    subnetwork_project = "${var.subnetwork_project}"
  }

  lifecycle {
    create_before_destroy = "false"
  }
}

####################
# Deploy an instance 
####################
resource "google_compute_instance_from_template" "deploy_os_template" {
  name                     = "${var.environment}${random_id.service_account.hex}"
  zone                     = "${var.zone}"
  source_instance_template = "${google_compute_instance_template.os_template.self_link}"
}

resource "google_compute_firewall" "default" {
  name          = "${var.environment}${random_id.service_account.hex}"
  description   = "Load Balancer and Health Check rule for ${var.environment}"
  network       = "${var.network}"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "209.85.152.0/22", "209.85.204.0/22"]
  target_tags   = ["${var.environment}"]

  allow {
    protocol = "tcp"
    ports    = ["${var.server_port}"]
  }
}

####################
# Create Instance group
####################

resource "google_compute_instance_group" "default" {
  name        = "${var.environment}"
  zone        = "${var.zone}"
  description = "Instance group for ${var.environment} "
  instances   = ["${google_compute_instance_from_template.deploy_os_template.self_link}"]

  named_port {
    name = "https"
    port = "${var.server_port}"
  }

  lifecycle {
    create_before_destroy = false
  }
}

####################
# Load Balancer
####################
resource "google_compute_backend_service" "default" {
  name          = "${var.environment}"
  port_name     = "https"
  protocol      = "HTTPS"
  timeout_sec   = "900"
  health_checks = ["${google_compute_https_health_check.default.self_link}"]
  enable_cdn    = "false"

  backend {
    group = "${google_compute_instance_group.default.self_link}"
  }
}

resource "google_compute_https_health_check" "default" {
  name               = "${var.environment}"
  port               = "${var.server_port}"
  timeout_sec        = 5
  check_interval_sec = 30
  request_path       = "${var.request_path}"
}

resource "google_compute_url_map" "default" {
  name            = "${var.environment}"
  default_service = "${google_compute_backend_service.default.self_link}"
}

resource "google_compute_global_address" "default" {
  name  = "${var.environment}${random_id.service_account.hex}"
}

resource "google_compute_managed_ssl_certificate" "default" {
  name     = "${var.environment}"
  project  = "${var.project}"
  provider = "google-beta"

  managed {
    domains = ["${var.environment}.${var.domain}"]
  }
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "${var.environment}"
  target     = "${google_compute_target_https_proxy.default.self_link}"
  ip_address = "${google_compute_global_address.default.address}"
  port_range = "443"
  depends_on = ["google_compute_global_address.default"]
}

resource "google_compute_target_https_proxy" "default" {
  name             = "${var.environment}"
  url_map          = "${google_compute_url_map.default.self_link}"
  ssl_certificates = ["${google_compute_managed_ssl_certificate.default.self_link}"]
}

resource "google_dns_record_set" "default" {
  name  = "${var.environment}.${var.domain}."
  type  = "A"
  ttl   = "300"

  managed_zone = "${var.dnszone}"

  rrdatas = [
    "${google_compute_global_address.default.address}",
  ]
}
