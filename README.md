# Terraform Splunk Module

The module will create a single compute engine instance to host Splunk Enterprise (trial version) and set up a pub/sub topic to export Stackdriver log events which will be pulled into Splunk Enterprise.

## Usage
The default behavior of the module is to deploy both Splunk Enterprise and the Pub/Sub message queue, but can be updated to deploy individually with gce or pubsub variables. The environment variable will be the primary key for the deployment to reduce naming conflicts with mulitple deployments. The DNS zone will be used to set the public DNS record. 

```hcl
module "gce" {
  source      = "modules/gce"
  gce         = "${var.gce}"
  project     = "${var.project}"
  environment = "${var.environment}"
  zone        = "${var.zone}"
  domain      = "${var.domain}"
  dnszone     = "${var.dnszone}"
}

module "pubsub" {
  source      = "modules/pubsub"
  pubsub      = "${var.pubsub}"
  project     = "${var.project}"
  environment = "${var.environment}"
  domain      = "${var.domain}"
}
```

### Requirements

### Terraform plugins
- [Terraform](https://www.terraform.io/downloads.html) 0.12.x
- [terraform-provider-google](https://github.com/terraform-providers terraform-provider-google) plugin v2.2.0
- [terraform-provider-google-beta](https://github.com/terraform-providers/terraform-provider-google-beta) plugin v2.2.0

## Splunk Enterprise 
Download lastest versions of Splunk Trial and Add-on and copy to Google Storage Bucket
[Splunk] https://www.splunk.com/en_us/download/splunk-enterprise.html#
[Splunk Add on] https://splunkbase.splunk.com/app/3088/

### APIs
For the Splunk to work, the following APIs must be enabled in the project:
- Identity and Access Management API: `iam.googleapis.com`
- Compute: `compute.googleapis.com`
- Logging: `logging.googleapis.com`
- DNS: `dns.googleapis.com`
- Pub/Sub `pubsub.googleapis.com`

### Service account
We need two Terraform service accounts for this module:
* **Terraform service account** (that will create the VM for Splunk Infrastructure)
* **VM service account** (that will be used on the VM to install Splunk and write them to Stackdriver Logging)

The **Terraform service account** used to run this module must have the following IAM Roles:
- `Logging Admin` on the Organization Level
- `Organization Viewer` on the Organization Level
- `Compute Instance Admin` on the project to create the VM.
- `Project IAM Admin` on the project to grant permissions to the VM service account.
- `DNS Administrator` on the project to set the public DNS record.
- `Logging Admin` on the organization to create the export sink.
- `Pub/Sub Admin` on the project where pub/sub topic will be created.
## Install

### Terraform
Be sure you have the correct Terraform version (0.12.x), you can choose the binary here:
- https://releases.hashicorp.com/terraform/

Then perform the following commands:
-  Create a Google Storage bucket to store Terraform state 
-  `gsutil mb gs://<your state bucket>`
-  Copy terraform.tfvars.template to terraform.tfvars 
-  `cp terraform.tfvars.template  terraform.tfvars`
-  Update required variables in terraform.tfvars for Splunk Software, GCS Bucket, and DNS configuration 
- `terraform init` to get the plugins
-  Enter Google Storage bucket that will store the Terraform state
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure

#### Variables
Please refer the `variables.tf` file for the required and optional variables.

## File structure
The project has the following folders and files:

- /modules: modules folder
- /scripts: Helper script for Terraform deployment
- /main.tf: main file for this module, contains all the resources to create
- /variables.tf: all the variables for the module
- /readme.MD: this file





