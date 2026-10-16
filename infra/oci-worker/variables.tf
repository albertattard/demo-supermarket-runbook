variable "region" {
  description = "OCI region containing the compartment and Oracle Linux image."
  type        = string
}

variable "oci_config_profile" {
  description = "Profile in the local ~/.oci/config used to provision infrastructure."
  type        = string
  default     = "DEFAULT"
}

variable "compartment_id" {
  description = "Existing compartment OCID in which to create the demo resources."
  type        = string
}

variable "ssh_private_key_path" {
  description = "Local path to the SSH private key for the administrator's opc account."
  type        = string
}

variable "ssh_public_key_path" {
  description = "Local path to the SSH public key for the administrator's opc account."
  type        = string
}

variable "ssh_source_cidr" {
  description = "Administrator's public IPv4 address as a /32 CIDR."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_source_cidr)) && can(regex("/32$", var.ssh_source_cidr))
    error_message = "SSH must be restricted to one IPv4 address, for example 203.0.113.10/32."
  }
}

variable "display_name" {
  description = "Prefix used for the dedicated demo infrastructure."
  type        = string
  default     = "demo-supermarket-java-worker"
}

variable "shape" {
  description = "An x86_64 flexible shape; the bootstrap installs x86_64 Codex."
  type        = string
  default     = "VM.Standard.E4.Flex"

  validation {
    condition     = contains(["VM.Standard.E4.Flex", "VM.Standard.E5.Flex"], var.shape)
    error_message = "Use VM.Standard.E4.Flex or VM.Standard.E5.Flex with an Oracle Linux 10 x86_64 image."
  }
}

variable "ocpus" {
  description = "OCPUs allocated to the worker."
  type        = number
  default     = 2

  validation {
    condition     = var.ocpus >= 1 && var.ocpus <= 8 && floor(var.ocpus) == var.ocpus
    error_message = "Choose a whole number of OCPUs between 1 and 8 for this demo."
  }
}

variable "memory_in_gbs" {
  description = "Memory available to Codex, Maven, and the Java language server."
  type        = number
  default     = 12

  validation {
    condition     = var.memory_in_gbs >= 8 && var.memory_in_gbs <= 64
    error_message = "Choose between 8 and 64 GB for this demo."
  }
}

variable "codex_version" {
  description = "Pinned Codex release version; update the matching package checksum too."
  type        = string
  default     = "0.162.1"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.codex_version))
    error_message = "Supply a stable release version such as 0.162.1."
  }
}

variable "codex_sha256" {
  description = "SHA-256 of codex-package-x86_64-unknown-linux-musl.tar.gz for the selected release."
  type        = string
  default     = "a676f5722aae0d86cbe3764332f08eab1fdd89dc0a300b3ad4ffbf48611fa3e3"

  validation {
    condition     = can(regex("^[a-f0-9]{64}$", var.codex_sha256))
    error_message = "Supply the package's 64-character lowercase SHA-256 digest."
  }
}

variable "jdtls_archive_url" {
  description = "Pinned official Eclipse JDT LS milestone archive with Java 25 support."
  type        = string
  default     = "https://download.eclipse.org/jdtls/milestones/1.57.0/jdt-language-server-1.57.0-202602261110.tar.gz"

  validation {
    condition     = can(regex("^https://download\\.eclipse\\.org/jdtls/milestones/[0-9]+\\.[0-9]+\\.[0-9]+/jdt-language-server-[0-9]+\\.[0-9]+\\.[0-9]+-[0-9]+\\.tar\\.gz$", var.jdtls_archive_url))
    error_message = "Supply a versioned official Eclipse milestone archive URL, not a latest or snapshot URL."
  }
}

variable "jdtls_sha256" {
  description = "SHA-256 of the selected Eclipse JDT LS milestone archive; update together with its URL."
  type        = string
  default     = "f7ffa93fe1bbbea95dac13dd97cdcd25c582d6e56db67258da0dcceb2302601e"

  validation {
    condition     = can(regex("^[a-f0-9]{64}$", var.jdtls_sha256))
    error_message = "Supply the archive's 64-character lowercase SHA-256 digest."
  }
}

variable "freeform_tags" {
  description = "The freeform tags that will be applied to all resources"
  type        = map(string)
}
