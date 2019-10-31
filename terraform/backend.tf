terraform {
    backend "gcs" {
        bucket  = "golovin-nik95-gcp-capstone"
        prefix  = "terraform/state"
    }
}