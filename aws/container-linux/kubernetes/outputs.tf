output "ingress_dns_name" {
  value       = "${module.workers.ingress_dns_name}"
  description = "DNS name of the network load balancer for distributing traffic to Ingress controllers"
}

# Outputs for worker pools

output "vpc_id" {
  value       = "${aws_vpc.network.id}"
  description = "ID of the VPC for creating worker instances"
}

output "external_subnet_ids" {
  value       = ["${aws_subnet.public.*.id}"]
  description = "List of subnet IDs for creating worker instances"
}

output "internal_subnet_ids" {
  value       = ["${aws_subnet.private.*.id}"]
  description = "List of subnet IDs for creating worker instances"
}

output "worker_security_groups" {
  value       = ["${aws_security_group.worker.id}"]
  description = "List of worker security group IDs"
}

output "kubeconfig" {
  value = "${module.bootkube.kubeconfig}"
}

output "apiserver_dns_name" {
  value       = "${aws_route53_record.apiserver.fqdn}"
  description = "DNS name of the Route53 record used to access the Kubernetes apiserver"
}

output "bootstrap_controller_ip" {
  value       = "${aws_instance.controllers.0.private_ip}"
  description = "IP address of the controller instance used to bootstrap the cluster"
}

output "private_route_table" {
  value       = "${aws_route_table.private.id}"
  description = "ID of the private route table that can be used to add additional private routes"
}

output "depends_id" {
  value       = "${null_resource.bootkube-start.id}"
  description = "Resource ID that will be defined when the cluster is ready"
}
