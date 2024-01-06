################# DATA SOURCES #########################

data "aws_caller_identity" "this" {}

data "aws_region" "this" {}

######################## LOCALS #########################

locals {
  account_id = data.aws_caller_identity.this.account_id
  region     = data.aws_region.this.name
  s3_bucket  = var.create_s3_bucket ? aws_s3_bucket.this[0].id : var.s3_bucket_name
}

###################### CODE PIPELINE #########################

resource "aws_codepipeline" "this" {
  count = var.backend_deployment ? 1 : 0

  name     = var.name
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = local.s3_bucket
    type     = "S3"

  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = var.source_owner
      provider         = var.source_provider
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.connection_arn
        FullRepositoryId = var.repo_id
        BranchName       = var.repo_branch_name
        OAuthToken       = var.github_oauth_token
        Owner            = var.repo_owner
        Repo             = var.repo_name
        Branch           = var.branch
        #PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.this[0].name
      }
    }
  }

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

resource "aws_codepipeline" "this_1" {
  count = var.ec2_deployment ? 1 : 0

  name     = var.name
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = local.s3_bucket
    type     = "S3"

  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = var.source_owner
      provider         = var.source_provider
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.connection_arn
        FullRepositoryId = var.repo_id
        BranchName       = var.repo_branch_name
        OAuthToken       = var.github_oauth_token
        Owner            = var.repo_owner
        Repo             = var.repo_name
        Branch           = var.branch
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        "ApplicationName"     = var.create_deploy_group ? aws_codedeploy_app.this[0].name : var.codedeploy_app
        "DeploymentGroupName" = var.create_deploy_group ? aws_codedeploy_deployment_group.this[0].deployment_group_name : var.deployment_group
      }
    }
  }

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

resource "aws_codepipeline" "this_2" {
  count = var.ecs_deployment ? 1 : 0

  name     = var.name
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = local.s3_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = var.source_owner
      provider         = var.source_provider
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.connection_arn
        FullRepositoryId = var.repo_id
        BranchName       = var.repo_branch_name
        OAuthToken       = var.github_oauth_token
        Owner            = var.repo_owner
        Repo             = var.repo_name
        Branch           = var.branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.this[0].name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      run_order       = 1
      input_artifacts = ["build_output"]

      configuration = {
        "ClusterName"       = var.cluster_name
        "ServiceName"       = var.service_name
        "FileName"          = "imagedefinitions.json"
        "DeploymentTimeout" = var.deployment_timeout
      }
    }
  }

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

################ CODE BUILD PROJECT #########################

resource "aws_codebuild_project" "this" {
  count = var.ec2_deployment == false ? 1 : 0

  name                 = var.name
  description          = "Codebuild for the ECS app"
  service_role         = aws_iam_role.build_role[0].arn
  project_visibility   = var.project_visibility
  resource_access_role = aws_iam_role.public_build_role[0].arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.compute_type
    image                       = var.image_identifier
    type                        = var.build_container_type
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = var.privileged_mode

    dynamic "environment_variable" {
      for_each = var.env_vars != null ? var.env_vars : {}
      content {
        name  = environment_variable.key
        type  = "PLAINTEXT"
        value = environment_variable.value
      }
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file(var.build_spec)
  }

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

############### CODE DEPLOY APP & GROUP ######################

resource "aws_codedeploy_app" "this" {
  count = var.ec2_deployment && var.create_deploy_group ? 1 : 0

  compute_platform = "Server"
  name             = var.name

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

resource "aws_codedeploy_deployment_group" "this" {
  count = var.ec2_deployment && var.create_deploy_group ? 1 : 0

  app_name              = aws_codedeploy_app.this[0].name
  deployment_group_name = var.name
  service_role_arn      = aws_iam_role.deploy_role[0].arn

  ec2_tag_set {
    dynamic "ec2_tag_filter" {
      for_each = var.ec2_tag_filters
      content {
        key   = ec2_tag_filter.key
        type  = "KEY_AND_VALUE"
        value = ec2_tag_filter.value
      }
    }
  }

  deployment_style {
    deployment_type = "IN_PLACE"
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

##################### S3 BUCKET ###########################

resource "aws_s3_bucket" "this" {
  count = var.create_s3_bucket ? 1 : 0

  bucket        = var.s3_bucket_name != null ? var.s3_bucket_name : "${lower(var.name)}-${local.account_id}-pipeline"
  force_destroy = true

  tags = merge(
    {
      "Name" = var.s3_bucket_name != null ? var.s3_bucket_name : "${lower(var.name)}-${local.account_id}-pipeline"
    },
    var.tags
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