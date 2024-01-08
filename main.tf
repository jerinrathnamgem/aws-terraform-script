################### DATA SOURCES & LOCALS ###############################

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_caller_identity" "this" {}

data "aws_eks_cluster_auth" "this" {
  count = var.create_eks_deployment ? 1 : 0
  name  = var.eks_cluster_name
}

locals {
  account_id = data.aws_caller_identity.this.account_id
  s3_bucket  = var.create_s3_bucket ? aws_s3_bucket.this[0].id : var.s3_bucket_name
}

########################### ECS CLUSTER ##############################

module "ecs" {
  source = "./modules/ecs-cluster"
  count  = var.create_ecs_deployment ? 1 : 0

  cluster_name              = var.cluster_name
  create_cluster            = var.create_cluster
  name                      = var.ecs_service_names
  port                      = var.ecs_ports
  security_groups           = module.security-group-ecs[*].security_group_id
  subnet_ids                = var.ecs_subnet_ids == null ? data.aws_subnets.this.ids : var.ecs_subnet_ids
  load_balancing            = var.load_balancer_name != null ? true : false
  assign_public_ip          = var.assign_public_ip
  target_group_arns         = one(module.load-balancer[*].target_group_arn)
  cw_logs_retention_in_days = var.cw_logs_retention_in_days
  task_cpu                  = var.task_cpu
  task_memory               = var.task_memory
  ignore_changes            = var.ignore_changes
}

module "security-group-ecs" {
  source = "./modules/security-group"
  count  = var.create_ecs_deployment ? length(var.ecs_service_names) : 0

  name                                  = "${var.ecs_service_names[count.index]}-ECS"
  vpc_id                                = var.vpc_id
  tcp_ports                             = [var.ecs_ports[count.index]]
  ingress_tcp_source_security_group_ids = var.load_balancer_name != null ? [one(module.security-group-lb[*].security_group_id)] : []
}

##################### EC2 INSTANCE #####################

module "ec2" {
  source = "./modules/ec2"
  count  = var.create_ec2_deployment && var.create_ec2_server ? 1 : 0

  name               = var.ec2_name
  amiID              = var.ami_id
  create_eip         = var.create_eip
  instance_type      = var.ec2_instance_type
  sg_id              = one(module.security-group-ec2[*].security_group_id)
  subnet_id          = var.ec2_subnet_id
  volume_termination = var.volume_termination
  volume_encryption  = var.volume_encryption
  private_key_name   = var.private_key_name
  volume_size        = var.volume_size
  region             = var.region
  port               = var.ec2_port
}

module "security-group-ec2" {
  source = "./modules/security-group"
  count  = var.create_ec2_deployment && var.create_ec2_server ? 1 : 0

  name                                  = "${var.ec2_name}-EC2"
  vpc_id                                = var.vpc_id
  myip_ssh                              = var.ssh_cidr_ips
  tcp_ports                             = [var.ec2_port]
  ingress_tcp_source_security_group_ids = var.load_balancer_name != null ? [one(module.security-group-lb[*].security_group_id)] : []
}

resource "time_sleep" "ec2" {
  count      = var.create_ec2_deployment && var.create_ec2_server ? 1 : 0
  depends_on = [module.ec2]

  create_duration = "60s"
}

######################## EKS CLUSTER #####################################

module "eks-cluster" {
  count  = var.create_eks_deployment && var.create_cluster ? 1 : 0
  source = "./modules/eks-cluster"

  name                            = var.eks_cluster_name
  instance_types                  = [var.eks_node_type]
  subnet_ids                      = var.eks_subnet_ids == null ? slice(data.aws_subnets.this.ids, 0, 2) : var.eks_subnet_ids
  node_subnet_ids                 = var.eks_node_subnet_ids == null ? data.aws_subnets.this.ids : var.eks_node_subnet_ids
  vpc_id                          = var.vpc_id
  myip_ssh                        = var.node_ssh_cidr_ips
  private_key                     = var.node_private_key_name
  ami_type                        = var.node_ami_type
  cluster_version                 = var.cluster_version
  min_size                        = var.node_min_size
  max_size                        = var.node_max_size
  desired_size                    = var.node_desired_size
  region                          = var.region
  account_id                      = local.account_id
  delete_on_termination           = var.node_volume_termination
  volume_size                     = var.node_volume_size
  enabled_cluster_log_types       = var.enabled_cluster_log_types
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
}

###################################### CONFIG MAP ################################################

resource "kubernetes_config_map_v1_data" "aws-auth" {
  count = var.create_eks_deployment && var.create_cluster ? 1 : 0

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  force = true

  data = {
    mapRoles = yamlencode(
      [
        {
          rolearn  = module.eks-cluster[0].kubectl_role_arn
          username = "build"
          groups   = ["system:masters"]
        },
        {
          rolearn  = module.eks-cluster[0].ng_role_arn
          username = "system:node:{{EC2PrivateDNSName}}"
          groups   = ["system:bootstrappers", "system:nodes"]
        }
      ]
    )
  }

  depends_on = [
    module.eks-cluster
  ]
}

####################### CODE PIPELINE #######################################

module "ecs-pipeline" {
  source = "./modules/code-pipeline"
  count  = var.create_ecs_deployment ? length(var.ecs_service_names) : 0

  ecs_deployment       = var.create_ecs_deployment
  ec2_deployment       = var.create_ec2_deployment
  name                 = var.ecs_service_names[count.index]
  github_oauth_token   = var.github_oauth_token
  repo_owner           = var.repo_owner
  repo_name            = var.repo_owner != null ? var.repo_ids[count.index] : null
  branch               = var.repo_owner != null ? var.repo_branch_names[count.index] : null
  source_owner         = var.source_owner
  source_provider      = var.source_provider
  repo_id              = var.repo_owner == null ? var.repo_ids[count.index] : null
  repo_branch_name     = var.repo_owner == null ? var.repo_branch_names[count.index] : null
  cluster_name         = var.cluster_name
  service_name         = one(module.ecs[*].ecs_service[count.index].name)
  s3_bucket_name       = local.s3_bucket
  create_s3_bucket     = false
  connection_arn       = var.connection_arn != null ? var.connection_arn : one(aws_codestarconnections_connection.this[*].arn)
  project_visibility   = "PUBLIC_READ"
  compute_type         = var.codebuild_compute_type
  build_container_type = var.build_container_type
  image_identifier     = var.image_identifier
  deployment_timeout   = var.ecs_deployment_timeout
  secret_id            = var.create_secrets_manager == false && var.secrets_manager_arn == null ? null : var.secrets_manager_arn == null ? aws_secretsmanager_secret.this[0].id : var.secrets_manager_arn

  env_vars = {
    ECSNAME         = var.ecs_service_names[count.index]
    REPOSITORY_URI  = one(module.ecs[*].ecr_repository[count.index].repository_url)
    SECRET_USERNAME = var.create_secrets_manager == false && var.secrets_manager_arn == null ? "none" : "${var.secrets_manager_arn == null ? aws_secretsmanager_secret.this[0].id : var.secrets_manager_arn}:username"
    SECRET_PASSWORD = var.create_secrets_manager == false && var.secrets_manager_arn == null ? "none" : "${var.secrets_manager_arn == null ? aws_secretsmanager_secret.this[0].id : var.secrets_manager_arn}:password"
  }

  depends_on = [module.ecs]
}

module "ec2-pipeline" {
  source = "./modules/code-pipeline"
  count  = var.create_ec2_deployment ? 1 : 0

  ecs_deployment     = var.create_ecs_deployment
  ec2_deployment     = var.create_ec2_deployment
  name               = var.ec2_name
  github_oauth_token = var.github_oauth_token
  repo_owner         = var.repo_owner
  repo_name          = var.repo_owner != null ? var.repo_ids[count.index] : null
  branch             = var.repo_owner != null ? var.repo_branch_names[count.index] : null
  source_owner       = var.source_owner
  source_provider    = var.source_provider
  repo_id            = var.repo_owner == null ? var.repo_ids[count.index] : null
  repo_branch_name   = var.repo_owner == null ? var.repo_branch_names[count.index] : null
  s3_bucket_name     = local.s3_bucket
  create_s3_bucket   = false
  connection_arn     = var.connection_arn != null ? var.connection_arn : one(aws_codestarconnections_connection.this[*].arn)
  secret_id          = var.create_secrets_manager == false && var.secrets_manager_arn == null ? null : var.secrets_manager_arn == null ? aws_secretsmanager_secret.this[0].id : var.secrets_manager_arn

  ec2_tag_filters = {
    "Name" = var.ec2_name
  }

  depends_on = [time_sleep.ec2]
}

module "eks-pipeline" {
  source = "./modules/code-pipeline"
  count  = var.create_eks_deployment ? length(var.eks_pipeline_names) : 0

  ecs_deployment       = var.create_ecs_deployment
  ec2_deployment       = var.create_ec2_deployment
  backend_deployment   = true
  name                 = var.eks_pipeline_names[count.index]
  github_oauth_token   = var.github_oauth_token
  repo_owner           = var.repo_owner
  repo_name            = var.repo_owner != null ? var.repo_ids[count.index] : null
  branch               = var.repo_owner != null ? var.repo_branch_names[count.index] : null
  source_owner         = var.source_owner
  source_provider      = var.source_provider
  repo_id              = var.repo_owner == null ? var.repo_ids[count.index] : null
  repo_branch_name     = var.repo_owner == null ? var.repo_branch_names[count.index] : null
  s3_bucket_name       = local.s3_bucket
  create_s3_bucket     = false
  connection_arn       = var.connection_arn != null ? var.connection_arn : one(aws_codestarconnections_connection.this[*].arn)
  project_visibility   = "PUBLIC_READ"
  build_spec           = "buildspec-eks.yml"
  compute_type         = var.codebuild_compute_type
  build_container_type = var.build_container_type
  image_identifier     = var.image_identifier
  secret_id            = var.create_secrets_manager == false && var.secrets_manager_arn == null ? null : var.secrets_manager_arn == null ? aws_secretsmanager_secret.this[0].id : var.secrets_manager_arn

  env_vars = merge(
    {
      "REPOSITORY_NAME"      = var.repo_ids[count.index],
      "REPOSITORY_BRANCH"    = var.repo_branch_names[count.index],
      "EKS_CLUSTER_NAME"     = var.eks_cluster_name
      "REPOSITORY_URI"       = aws_ecr_repository.this[count.index].repository_url
      "EKS_KUBECTL_ROLE_ARN" = module.eks-cluster[0].kubectl_role_arn
      "SECRET_USERNAME"      = var.create_secrets_manager == false && var.secrets_manager_arn == null ? "none" : "${var.secrets_manager_arn == null ? aws_secretsmanager_secret.this[0].id : var.secrets_manager_arn}:username"
      "SECRET_PASSWORD"      = var.create_secrets_manager == false && var.secrets_manager_arn == null ? "none" : "${var.secrets_manager_arn == null ? aws_secretsmanager_secret.this[0].id : var.secrets_manager_arn}:password"
    },
  var.env_vars)

  depends_on = [
    module.eks-cluster
  ]
}

resource "aws_ecr_repository" "this" {
  count = var.create_eks_deployment ? length(var.eks_pipeline_names) : 0

  name                 = lower(var.eks_pipeline_names[count.index])
  force_delete         = true
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    "Name" = var.eks_pipeline_names[count.index]
  }
}

########################### LOAD BALANCER #############################

module "load-balancer" {
  source = "./modules/load-balancer"
  count  = var.load_balancer_name != null ? 1 : 0

  certificate_arn       = var.certificate_arn
  host_names            = var.host_names
  host_paths            = var.host_paths
  health_check_paths    = var.health_check_paths
  names                 = var.create_ec2_deployment ? [var.ec2_name] : var.ecs_service_names
  load_balancer_name    = var.load_balancer_name
  ports                 = var.create_ec2_deployment ? [var.ec2_port] : var.ecs_ports
  security_groups       = [module.security-group-lb[0].security_group_id]
  subnet_ids            = var.alb_subnet_ids == null ? data.aws_subnets.this.ids : var.alb_subnet_ids
  vpc_id                = var.vpc_id
  instance_id           = one(module.ec2[*].instance_id)
  target_type           = [var.create_ec2_deployment ? "instance" : "ip"]
  create_ec2_deployment = var.create_ec2_deployment
  health_check_interval = var.health_check_interval
  health_check_timeout  = var.health_check_timeout
}

module "security-group-lb" {
  source = "./modules/security-group"
  count  = var.load_balancer_name != null ? 1 : 0

  name      = "${var.load_balancer_name}-LB"
  vpc_id    = var.vpc_id
  tcp_ports = [80, 443]
}