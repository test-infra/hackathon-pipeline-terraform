#
# Creates Crowd Infrastructure
#

variable "aws_key_pair" {}
variable "tool_name" {}
variable "ssh_sg" {}
variable "http_sg" {}
variable "maint_distribution_name" {}
variable "maint_distribution_zone_id" {}

data "aws_ebs_volume" "crowd_volume" {
  filter {
    name   = "tag:Name"
    values = ["crowd_data"]
  }

  most_recent = true
}

resource "aws_instance" "crowd" {
  ami               = "ami-1853ac65"
  instance_type     = "t2.large"
  key_name          = "${var.aws_key_pair}"
  security_groups   = ["${var.ssh_sg}", "${var.http_sg}"]
  availability_zone = "us-east-1a"

  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }

  tags {
    Project = "hackathon_pipeline"
    Name    = "${var.tool_name}_hackathon"
  }
}

resource "aws_volume_attachment" "crowd_data" {
  device_name  = "/dev/sdh"
  volume_id    = "${data.aws_ebs_volume.crowd_volume.id}"
  instance_id  = "${aws_instance.crowd.id}"
  skip_destroy = true
}
