terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 8.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.0, < 8.0"
    }
  }

  # -----------------------------------------------------------------------
  # Remote Backend (uncomment and configure for your environment)
  # -----------------------------------------------------------------------
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "gemini-enterprise/your-project"
  # }
}
