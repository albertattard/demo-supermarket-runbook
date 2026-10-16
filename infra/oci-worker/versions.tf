terraform {
  required_version = ">= 1.5, < 2.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 7.0"
    }
  }
}

# Credentials come from the local OCI configuration, never from VM metadata.
provider "oci" {
  region              = var.region
  config_file_profile = var.oci_config_profile
}
