##################### GitHub Connection ###############################

resource "aws_codestarconnections_connection" "this" {
  count = var.create_pipeline && var.connection_arn == null && var.github_oauth_token == null ? 1 : 0

  name          = "${var.create_ecs_deployment ? var.ecs_service_names[count.index] : var.eks_pipeline_names[count.index]}-pipeline"
  provider_type = "GitHub"
}

######################## S3 BUCKET ###################################

resource "aws_s3_bucket" "this" {
  count = var.create_s3_bucket ? 1 : 0

  bucket        = var.s3_bucket_name != null ? var.s3_bucket_name : "${lower(var.create_ecs_deployment ? var.ecs_service_names[0] : var.eks_pipeline_names[0])}-${local.account_id}-pipeline"
  force_destroy = true

  tags = merge(
    {
      "Name" = var.s3_bucket_name != null ? var.s3_bucket_name : "${lower(var.create_ecs_deployment ? var.ecs_service_names[0] : var.eks_pipeline_names[0])}-${local.account_id}-pipeline"
    },
  )
}

resource "aws_s3_bucket_policy" "this" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = local.s3_bucket

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action    = "s3:PutObject"
          Effect    = "Deny"
          Principal = "*"
          Resource = [
            "arn:aws:s3:::${local.s3_bucket}",
            "arn:aws:s3:::${local.s3_bucket}/*"

          ]
          Condition = {
            StringNotEquals = {
              "s3:x-amz-server-side-encryption" : "aws:kms"
            }
          }
        },
        {
          Action    = "s3:*"
          Effect    = "Deny"
          Principal = "*"
          Resource = [
            "arn:aws:s3:::${local.s3_bucket}",
            "arn:aws:s3:::${local.s3_bucket}/*"

          ]
          Condition = {
            Bool = {
              "aws:SecureTransport" : "false"
            }
          }
        }
      ]
    }
  )
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = local.s3_bucket

  rule {
    id = "Delete Objects after 1 day"

    expiration {
      days = 1
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    status = "Enabled"
  }
}

######################### EFS ################################

resource "aws_efs_file_system" "this" {
  count            = var.create_efs ? length(var.ecs_service_names) : 0
  encrypted        = var.efs_encrypted
  kms_key_id       = var.efs_kms_id
  throughput_mode  = var.efs_throughput_mode
  creation_token   = var.ecs_service_names[count.index]
  performance_mode = var.efs_performance_mode

  tags = {
    Name = var.ecs_service_names[count.index]
  }
}

resource "aws_efs_mount_target" "this" {
  count = var.create_efs && length(var.ecs_service_names) > 0 ? (length(var.efs_subnet_ids) == 0 ? length(data.aws_subnets.this.ids) : length(var.efs_subnet_ids)) : 0

  file_system_id  = one([aws_efs_file_system.this[0].id])
  subnet_id       = length(var.efs_subnet_ids) == 0 ? data.aws_subnets.this.ids[count.index] : var.efs_subnet_ids[count.index]
  security_groups = [aws_security_group.this[0].id]
}

resource "aws_efs_mount_target" "this_1" {
  count = var.create_efs && length(var.ecs_service_names) > 1 ? (length(var.efs_subnet_ids) == 0 ? length(data.aws_subnets.this.ids) : length(var.efs_subnet_ids)) : 0

  file_system_id  = one([aws_efs_file_system.this[1].id])
  subnet_id       = length(var.efs_subnet_ids) == 0 ? data.aws_subnets.this.ids[count.index] : var.efs_subnet_ids[count.index]
  security_groups = [aws_security_group.this[0].id]
}

resource "aws_efs_mount_target" "this_2" {
  count = var.create_efs && length(var.ecs_service_names) > 2 ? (length(var.efs_subnet_ids) == 0 ? length(data.aws_subnets.this.ids) : length(var.efs_subnet_ids)) : 0

  file_system_id  = one([aws_efs_file_system.this[2].id])
  subnet_id       = length(var.efs_subnet_ids) == 0 ? data.aws_subnets.this.ids[count.index] : var.efs_subnet_ids[count.index]
  security_groups = [aws_security_group.this[0].id]
}

resource "aws_efs_mount_target" "this_3" {
  count = var.create_efs && length(var.ecs_service_names) > 3 ? (length(var.efs_subnet_ids) == 0 ? length(data.aws_subnets.this.ids) : length(var.efs_subnet_ids)) : 0

  file_system_id  = one([aws_efs_file_system.this[3].id])
  subnet_id       = length(var.efs_subnet_ids) == 0 ? data.aws_subnets.this.ids[count.index] : var.efs_subnet_ids[count.index]
  security_groups = [aws_security_group.this[0].id]
}

# resource "aws_efs_access_point" "this" {
#   count = var.create_efs ? length(var.ecs_service_names) : 0

#   file_system_id = aws_efs_file_system.this[0].id
#   root_directory {
#     path = "/efs/${var.ecs_service_names[count.index]}"
#   }
# }

resource "aws_security_group" "this" {
  count = var.create_efs ? 1 : 0

  name        = "${var.ecs_service_names[0]}-EFS-SG"
  description = "Security group for Elastic File System"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.ecs_service_names[0]}-EFS-SG"
  }
}

############################## ROUTE 53 ##################################

resource "aws_route53_record" "this" {
  count = length(var.route53_record_names)

  zone_id = length(var.route53_zone_ids) > 1 ? var.route53_zone_ids[count.index] : var.route53_zone_ids[0]
  name    = var.route53_record_names[count.index]
  type    = var.load_balancer_name != null ? "CNAME" : "A"
  ttl     = 300
  records = var.load_balancer_name != null ? [one(module.load-balancer[*].dns_name)] : [one(module.ec2[*].public_ip)]
}

######################### PIPELINE ALERTS ################################

resource "aws_codestarnotifications_notification_rule" "this" {
  count = !var.create_pipeline ? 0 : (var.create_ecs_deployment ? length(var.ecs_service_names) : var.create_eks_deployment ? length(var.eks_pipeline_names) : 1)

  detail_type = "FULL"
  name        = "${var.create_ecs_deployment ? var.ecs_service_names[count.index] : var.create_eks_deployment ? var.eks_pipeline_names[count.index] : var.ec2_name}-pipeline-notification"
  resource    = var.create_ecs_deployment ? module.ecs-pipeline[count.index].code_pipeline_arn : (var.create_ec2_deployment ? module.ec2-pipeline[0].code_pipeline_arn : module.eks-pipeline[count.index].code_pipeline_arn)

  event_type_ids = [
    "codepipeline-pipeline-pipeline-execution-failed",
    "codepipeline-pipeline-pipeline-execution-succeeded"
  ]

  target {
    address = var.sns_topic_arn == null ? one(aws_sns_topic.this[*].arn) : var.sns_topic_arn
  }
}

resource "aws_sns_topic" "this" {
  count = var.create_pipeline && var.sns_topic_arn == null ? 1 : 0

  name = "${var.create_ecs_deployment ? var.ecs_service_names[0] : var.create_eks_deployment ? var.eks_pipeline_names[0] : var.ec2_name}-pipeline-notification"
}

resource "aws_sns_topic_policy" "this" {
  count = var.create_pipeline && var.sns_topic_arn == null ? 1 : 0

  arn    = aws_sns_topic.this[0].arn
  policy = data.aws_iam_policy_document.this[0].json
}

data "aws_iam_policy_document" "this" {
  count = var.create_pipeline && var.sns_topic_arn == null ? 1 : 0

  policy_id = "__default_policy_ID"

  statement {
    effect = "Allow"
    sid    = "__default_statement_ID"

    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
      "SNS:Receive"
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        local.account_id,
      ]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      var.sns_topic_arn == null ? one(aws_sns_topic.this[*].arn) : var.sns_topic_arn
    ]
  }

  statement {
    effect = "Allow"
    sid    = "AWSCodeStarNotifications_publish"
    actions = [
      "SNS:Publish"
    ]
    principals {
      type        = "Service"
      identifiers = ["codestar-notifications.amazonaws.com"]
    }
    resources = [
      var.sns_topic_arn == null ? one(aws_sns_topic.this[*].arn) : var.sns_topic_arn
    ]
  }
}

resource "aws_sns_topic_subscription" "this" {
  count = var.create_pipeline && var.sns_topic_arn == null ? length(var.email_addresses) : 0

  topic_arn = one(aws_sns_topic.this[*].arn)
  protocol  = "email"
  endpoint  = var.email_addresses[count.index]
}

################## SECRETS MANAGER ###########################

resource "aws_secretsmanager_secret" "this" {
  count = var.secrets_manager_arn == null && var.create_secrets_manager ? 1 : 0

  name                    = var.secret_name
  kms_key_id              = var.secrets_manager_kms_key_id
  recovery_window_in_days = var.kms_key_recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "this" {
  count = var.secrets_manager_arn == null && var.create_secrets_manager ? 1 : 0

  secret_id = aws_secretsmanager_secret.this[0].id
  secret_string = jsonencode(
    {
      username = var.docker_username,
      password = var.docker_password
    }
  )
}

######################### KUBERNETES HELM #########################

resource "helm_release" "aws-load-balancer-controller" {
  count = var.create_eks_deployment ? 1 : 0

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller-sa"
  }

  set {
    name  = "serviceAccount.create"
    value = false
  }

  set {
    name  = "image.repository"
    value = format("602401143452.dkr.ecr.%s.amazonaws.com/amazon/aws-load-balancer-controller", var.region)
  }
}

resource "kubernetes_service_account_v1" "alb" {
  count = var.create_eks_deployment ? 1 : 0

  metadata {
    name      = "aws-load-balancer-controller-sa"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = module.eks-cluster[0].ng_role_arn
    }
  }
}


resource "helm_release" "kubernetes_dashboard" {
  count = var.create_eks_deployment ? 1 : 0

  name       = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard"
  chart      = "kubernetes-dashboard"
  namespace  = "kube-system"

  values = [
    templatefile("./kube-dashboard.yml.tpl", { #${path.module}
      service_account_name = "kube-dashboard-sa"
      service_type         = var.kubernetes_dashboard_service_type
    })
  ]
}

resource "kubernetes_service_account_v1" "this" {
  count = var.create_eks_deployment ? 1 : 0

  metadata {
    name      = "admin-user"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding_v1" "this" {
  count = var.create_eks_deployment ? 1 : 0

  metadata {
    name = "admin-user"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "admin-user"
    namespace = "kube-system"
  }
}

resource "kubernetes_secret_v1" "this" {
  count = var.create_eks_deployment ? 1 : 0

  metadata {
    name      = "admin-user"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" : "admin-user"
    }
  }

  type = "kubernetes.io/service-account-token"
}