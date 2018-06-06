# Bastion Security Groups
resource "aws_security_group" "bastion_external" {
  name_prefix = "${var.cluster_name}-bastion-external-"
  description = "Allows access to the bastion from the internet"

  vpc_id = "${aws_vpc.network.id}"

  tags {
    Name = "${var.cluster_name}-bastion-external"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "bastion_internal" {
  name_prefix = "${var.cluster_name}-bastion-internal-"
  description = "Allows access to a host from the bastion"

  vpc_id = "${aws_vpc.network.id}"

  tags {
    Name = "${var.cluster_name}-bastion-internal"
  }

  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    security_groups = ["${aws_security_group.bastion_external.id}"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Bastion Instance
resource "aws_instance" "bastion" {
  tags = {
    Name = "${var.cluster_name}-bastion"
  }

  instance_type = "${var.bastion_type}"

  ami       = "${local.ami_id}"
  user_data = "${data.ct_config.bastion_ign.rendered}"

  # network
  subnet_id = "${element(aws_subnet.public.*.id, 0)}"

  vpc_security_group_ids = [
    "${aws_security_group.bastion_external.id}",
  ]

  lifecycle {
    ignore_changes = ["ami"]
  }
}

# Bastion Container Linux Config
data "template_file" "bastion_config" {
  template = "${file("${path.module}/cl/bastion.yaml.tmpl")}"
}

data "ct_config" "bastion_ign" {
  content      = "${data.template_file.bastion_config.rendered}"
  pretty_print = false
  snippets     = ["${var.bastion_clc_snippets}"]
}

resource "aws_eip_association" "bastion" {
  instance_id   = "${aws_instance.bastion.id}"
  allocation_id = "${aws_eip.bastion.id}"
}

resource "aws_eip" "bastion" {
  vpc = true
}

resource "aws_route53_record" "bastion" {
  zone_id = "${var.dns_zone_id}"

  name = "${format("bastion.%s.%s.", var.cluster_name, var.dns_zone)}"
  type = "CNAME"
  ttl  = 300

  records = ["${aws_instance.bastion.public_dns}"]
}
