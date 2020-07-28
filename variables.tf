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

#Project Variables
variable "region" {
  description = "Default region to deploy Splunk Infrastructure"
  default = "us-central1"
}

variable "zone" {
  description = "Default zone to deploy Splunk Infrastructure"
  default = "us-central1-b"
}
variable "project" {
  description = "GCP Project where Splunk Infrastructure will be deployed"
}

variable "environment" {
  description = "Environment required as key value for deployment"
}

# Modules on or off
variable "gce" {
  description = "Module to deploy Splunk Enterprise infrastructure"
  default = "true"
}

variable "pubsub" {
  description = "Module to deploy Pub/Sub Infrastructure for Splunk to consume log events"
  default = "true"
}

# Service Control Variables
variable "domain" {
  description = "Organization Domain e.g. example.com"
}

variable "dnszone" {
  description = "GCP DNS Zone to set DNS record for Load Balancer"
}

#Splunk Software location
variable "BUCKET" {
  description = "Name of Google Storage bucket where Splunk trial Installation package in tgz format"
}

variable "ARCHIVE" {
  description = "Name of Splunk trial Installation package in tgz format ie splunk-7.1.2-a0c72a66db66-Linux-x86_64.tgz"
}

variable "ADDON" {
  description = "Name of GCP Splunk Add package in tgz format ie splunk-add-on-for-google-cloud-platform_130.tgz"
}

