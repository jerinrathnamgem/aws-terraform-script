resource "aws_launch_template" "template" {
  name                   = "${var.name}-template"
  key_name               = var.private_key
  vpc_security_group_ids = [aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id, aws_security_group.node-sg.id]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.volume_size
      volume_type           = "gp3"
      throughput            = 125
      iops                  = 3000
      delete_on_termination = var.delete_on_termination
    }
  }

  metadata_options {
    http_tokens                 = "optional"
    http_put_response_hop_limit = 2
    http_endpoint               = "enabled"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name                             = "${var.name}-${random_integer.rand.result}-node"
      "alpha.eksctl.io/nodegroup-name" = "${var.name}-${random_integer.rand.result}"
      "alpha.eksctl.io/nodegroup-type" = "managed"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name                             = "${var.name}-${random_integer.rand.result}-node"
      "alpha.eksctl.io/nodegroup-name" = "${var.name}-${random_integer.rand.result}"
      "alpha.eksctl.io/nodegroup-type" = "managed"
    }
  }

  tag_specifications {
    resource_type = "network-interface"
    tags = {
      Name                             = "${var.name}-${random_integer.rand.result}-node"
      "alpha.eksctl.io/nodegroup-name" = "${var.name}-${random_integer.rand.result}"
      "alpha.eksctl.io/nodegroup-type" = "managed"
    }
  }
}