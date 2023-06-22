terraform {
  backend "gcs" {
    bucket = "shkirmantsev-demo-bucket"
    prefix = "terraform/state"
  }
}