terraform {
  backend "s3" {
    endpoint                    = "https://minio:9000/"
    bucket                      = "terraform"
    key                         = "state"
    region                      = "main"
    encrypt                     = true
    force_path_style            = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 2.0"
    }
  }
}