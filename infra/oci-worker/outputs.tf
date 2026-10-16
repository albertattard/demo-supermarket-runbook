output "instance_id" {
  description = "Worker instance OCID."
  value       = oci_core_instance.worker.id
}

output "public_ip" {
  description = "Worker public IPv4 address."
  value       = oci_core_instance.worker.public_ip
}

output "ssh_private_key_path" {
  description = "Expanded local SSH private-key path; does not contain the key contents."
  value       = pathexpand(var.ssh_private_key_path)
}

output "ssh_command" {
  description = "Use the private key corresponding to ssh_public_key_path, via ssh-agent or -i."
  value       = "ssh -i ${var.ssh_private_key_path} opc@${oci_core_instance.worker.public_ip}"
}

output "bootstrap_check_command" {
  description = "Terraform completion is not evidence that software installation succeeded."
  value       = "ssh -i ${var.ssh_private_key_path} opc@${oci_core_instance.worker.public_ip} 'sudo cloud-init status --wait --long && sudo test -f /var/lib/java-worker/ready'"
}

output "availability_domain" {
  description = "Full availability-domain name selected for the worker."
  value       = oci_core_instance.worker.availability_domain
}

output "image_id" {
  description = "Latest compatible Oracle Linux 10 platform image selected for the worker."
  value       = try(data.oci_core_images.worker.images[0].id, null)
}

output "image_name" {
  description = "Display name of the selected Oracle Linux 10 platform image."
  value       = try(data.oci_core_images.worker.images[0].display_name, null)
}
