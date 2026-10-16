data "oci_identity_availability_domains" "worker" {
  compartment_id = var.compartment_id
}

locals {
  # Match the domain number; OCI does not guarantee list ordering.
  availability_domain = one([
    for ad in data.oci_identity_availability_domains.worker.availability_domains : ad.name
    if endswith(ad.name, "-AD-1")
  ])

  bootstrap = templatefile("${path.module}/bootstrap.sh.tftpl", {
    codex_version          = var.codex_version
    codex_sha256           = var.codex_sha256
    jdtls_archive_url      = var.jdtls_archive_url
    jdtls_sha256           = var.jdtls_sha256
    jdtls_installer_base64 = filebase64("${path.module}/install-jdtls.sh")
  })
}

# Official x86_64 Oracle Linux 10 platform image names; exclude Arm and custom images.
data "oci_core_images" "worker" {
  compartment_id   = var.compartment_id
  operating_system = "Oracle Linux"
  shape            = var.shape
  state            = "AVAILABLE"
  sort_by          = "TIMECREATED"
  sort_order       = "DESC"

  filter {
    name   = "display_name"
    values = ["^Oracle-Linux-10\\.[0-9]+-[0-9]{4}\\.[0-9]{2}\\.[0-9]{2}-[0-9]+$"]
    regex  = true
  }
}

resource "oci_core_vcn" "worker" {
  compartment_id = var.compartment_id
  display_name   = var.display_name
  cidr_blocks    = ["10.42.0.0/16"]
  dns_label      = "javaworker"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_internet_gateway" "worker" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.worker.id
  display_name   = var.display_name
  enabled        = true
  freeform_tags  = var.freeform_tags
}

resource "oci_core_route_table" "worker" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.worker.id
  display_name   = var.display_name
  freeform_tags  = var.freeform_tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.worker.id
  }
}

# Use a dedicated list instead of the VCN's default security list.
# This is a demo network with outbound Internet access, not a domain allowlist.
resource "oci_core_security_list" "worker" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.worker.id
  display_name   = var.display_name
  freeform_tags  = var.freeform_tags

  ingress_security_rules {
    protocol    = "6"
    source      = var.ssh_source_cidr
    source_type = "CIDR_BLOCK"
    description = "SSH from the administrator's public IP only"

    tcp_options {
      min = 22
      max = 22
    }
  }

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    description      = "Package installation, model access, Git, and Maven dependencies"
  }
}

resource "oci_core_subnet" "worker" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.worker.id
  display_name               = var.display_name
  cidr_block                 = "10.42.1.0/24"
  dns_label                  = "worker"
  route_table_id             = oci_core_route_table.worker.id
  security_list_ids          = [oci_core_security_list.worker.id]
  prohibit_public_ip_on_vnic = false
  freeform_tags              = var.freeform_tags
}

resource "oci_core_instance" "worker" {
  compartment_id       = var.compartment_id
  availability_domain  = local.availability_domain
  display_name         = var.display_name
  shape                = var.shape
  preserve_boot_volume = false
  freeform_tags        = var.freeform_tags

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  source_details {
    source_type             = "image"
    source_id               = try(data.oci_core_images.worker.images[0].id, null)
    boot_volume_size_in_gbs = 50
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.worker.id
    assign_public_ip = true
    hostname_label   = "java-worker"
    freeform_tags    = var.freeform_tags
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }

  metadata = {
    ssh_authorized_keys = trimspace(file(pathexpand(var.ssh_public_key_path)))
    user_data           = base64encode(local.bootstrap)
  }

  # cloud-init runs once. Replace the disposable worker when its bootstrap changes.
  lifecycle {
    replace_triggered_by = [terraform_data.bootstrap]

    precondition {
      condition     = local.availability_domain != null
      error_message = "AD-1 was not found in the configured region."
    }

    precondition {
      condition     = length(data.oci_core_images.worker.images) > 0
      error_message = "No available official Oracle Linux 10 x86_64 image was found for this region and shape."
    }
  }

  # Ensure the network is ready before cloud-init starts downloading packages.
  depends_on = [oci_core_route_table.worker, oci_core_security_list.worker]
}

resource "terraform_data" "bootstrap" {
  input = sha256(local.bootstrap)
}

# Fail apply when cloud-init fails, without tainting the VM itself. A later
# apply retries the check; it does not rerun cloud-init on the existing VM.
resource "terraform_data" "worker_ready" {
  triggers_replace = [
    oci_core_instance.worker.id,
    filesha256("${path.module}/check-bootstrap.sh"),
  ]

  provisioner "local-exec" {
    command = "bash \"$WORKER_CHECK_SCRIPT\" \"$WORKER_HOST\""
    environment = {
      WORKER_CHECK_SCRIPT  = abspath("${path.module}/check-bootstrap.sh")
      WORKER_HOST          = oci_core_instance.worker.public_ip
      SSH_PRIVATE_KEY_PATH = pathexpand(var.ssh_private_key_path)
    }
  }
}
