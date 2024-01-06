terraform {
  # backend "s3" {
  #   bucket  = "cf-templates-1kgnmsqm99wdh-us-east-1" # bucket name for state file. Must be created manually
  #   key     = "ecs/terraform.tfstate"                # folder-name/path/terraform.tfstate (you can change the foler-name for each terraform script.)
  #   region  = "us-east-1"                            # region of the bucket 
  #   profile = "default"                              # need aws profile configured
  # }
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

provider "kubernetes" {
  host                   = one(module.eks-cluster[*].endpoint)
  cluster_ca_certificate = var.create_eks_deployment ? base64decode(module.eks-cluster[0].cluster_certificate_authority_data) : null
  token                  = one(data.aws_eks_cluster_auth.this[*].token)
}

provider "helm" {
  kubernetes {
    host                   = one(module.eks-cluster[*].endpoint)
    cluster_ca_certificate = var.create_eks_deployment ? base64decode(module.eks-cluster[0].cluster_certificate_authority_data) : null
    token                  = one(data.aws_eks_cluster_auth.this[*].token)
  }
}