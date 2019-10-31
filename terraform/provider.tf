variable "project_id" {}
variable "region" {}

provider "google" {
    project = var.project_id
    region = var.region
}