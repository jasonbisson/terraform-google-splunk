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

variable "environment" {
  description = "Environment required as key value for deployment"
}

variable "project" {
  description = "GCP Project where Splunk Infrastructure will be deployed"
}

variable "zone" {
  default = "GCP Zone where GCE instance will be deployed"
}

variable "machine_type" {
  description = "Machine type to deploy Splunk"
  default     = "n1-standard-1"
}

variable "can_ip_forward" {
  description = "Enable IP forwarding, for NAT instances for example"
  default     = "false"
}

variable "labels" {
  type        = "map"
  description = "Labels, provided as a map"
  default     = {}
}

#######
# disk
#######
variable "source_image" {
  description = "Source disk image. If neither source_image nor source_image_family is specified, defaults to the latest public CentOS image."
  default     = ""
}

variable "source_image_family" {
  description = "Source image family. If neither source_image nor source_image_family is specified, defaults to the latest public CentOS image."
  default     = ""
}

variable "source_image_project" {
  description = "Project where the source image comes from"
  default     = ""
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  default     = "100"
}

variable "disk_type" {
  description = "Boot disk type, can be either pd-ssd, local-ssd, or pd-standard"
  default     = "pd-standard"
}

variable "auto_delete" {
  description = "Whether or not the boot disk should be auto-deleted"
  default     = "true"
}

variable "additional_disks" {
  description = "List of maps of additional disks. See https://www.terraform.io/docs/providers/google/r/compute_instance_template.html#disk_name"
  type        = "list"
  default     = []
}

####################
# network_interface
####################
variable "network" {
  description = "The name or self_link of the network to attach this interface to. Use network attribute for Legacy or Auto subnetted networks and subnetwork for custom subnetted networks."
  default     = "default"
}

variable "subnetwork" {
  description = "The name of the subnetwork to attach this interface to. The subnetwork must exist in the same region this instance will be created in. Either network or subnetwork must be provided."
  default     = ""
}

variable "subnetwork_project" {
  description = "The ID of the project in which the subnetwork belongs. If it is not provided, the provider project is used."
  default     = ""
}

###########
# metadata
###########

variable "startup_script" {
  description = "User startup script to run when instances spin up"
  default     = ""
}

variable "metadata" {
  type        = "map"
  description = "Metadata, provided as a map"
  default     = {}
}

variable "service_account" {
  type        = "map"
  description = "Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template.html#service_account."
  default     = {}
}

variable "BUCKET" {
  description = "Name of Google Storage bucket where Splunk trial Installation package in tgz format"
}

variable "ARCHIVE" {
  description = "Name of Splunk trial Installation package in tgz format ie splunk-7.1.2-a0c72a66db66-Linux-x86_64.tgz"
}

variable "ADDON" {
  description = "Name of GCP Splunk Add on package in tgz format ie splunk-add-on-for-google-cloud-platform_130.tgz"
}

variable "gce" {
  description = "Flag to Deploy Splunk Enterprise Infrastructure"
  default     = "true"
}

variable "server_port" {
  description = "Web port for Splunk GCE server"
  default     = "8080"
}

variable "domain" {
  description = "DNS Domain for deployment"
}

variable "dnszone" {
  description = "GCP DNS Zone to set DNS record"
}

variable "request_path" {
  description = "Path to Splunk Login page"
  default     = "/en-US/account/login?return_to=%2Fen-US%2F"
}
