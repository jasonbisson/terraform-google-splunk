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

data "google_organization" "org" {
  domain = "${var.domain}"
}

resource "random_id" "default" {
  byte_length = 8
}

resource "google_service_account" "default" {
  account_id   = "${var.environment}${random_id.default.hex}"
  display_name = "${var.environment}${random_id.default.hex}"
}

resource "google_pubsub_topic" "default" {
  name  = "${var.environment}${random_id.default.hex}"
}

resource "google_pubsub_subscription" "default" {
  name  = "${var.environment}${random_id.default.hex}"
  topic = "${google_pubsub_topic.default.name}"
}

resource "google_pubsub_subscription_iam_member" "subscriber" {
  count        = var.pubsub ? 1 : 0
  project      = "${var.project}"
  subscription = "${google_pubsub_subscription.default.name}"
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${google_service_account.default.email}"
}

resource "google_project_iam_member" "subscriber" {
  project = "${var.project}"
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_pubsub_topic_iam_member" "publisher" {
  topic  = "${google_pubsub_topic.default.name}"
  role   = "roles/pubsub.publisher"
  member = "${google_logging_organization_sink.default.writer_identity}"
}

resource "google_logging_organization_sink" "default" {
  name             = "${var.environment}${random_id.default.hex}"
  org_id           = "${data.google_organization.org.id}"
  filter           = "severity>=NOTICE"
  include_children = "true"
  destination      = "pubsub.googleapis.com/projects/${var.project}/topics/${google_pubsub_topic.default.name}"
}
