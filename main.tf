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

terraform {
  required_version = ">= 0.12"
  backend "gcs" {}
}

provider "google" {
  version = "~> 2.5.0"
  project = "${var.project}"
  region  = "${var.region}"
  zone    = "${var.zone}"
}

provider "google-beta" {
  version = "~> 2.5.0"
}

module "gce" {
  source      = "./modules/gce"
  gce         = "${var.gce}"
  project     = "${var.project}"
  environment = "${var.environment}"
  zone        = "${var.zone}"
  domain      = "${var.domain}"
  dnszone     = "${var.dnszone}"
  BUCKET      = "${var.BUCKET}"
  ARCHIVE     = "${var.ARCHIVE}"
  ADDON       = "${var.ADDON}"
}

module "pubsub" {
  source      = "./modules/pubsub"
  pubsub      = "${var.pubsub}"
  project     = "${var.project}"
  environment = "${var.environment}"
  domain      = "${var.domain}"
}
