resource "aws_iam_role" "node_group" {
  name = "${var.name}-node-group"

  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        },
        {
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringEquals = {
              "${trimprefix(aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://")}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller-sa"
            }
          }
          Effect = "Allow"
          Principal = {
            Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${trimprefix(aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://")}"
          }
        }
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryPowerUser" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy" "lb-controller" {
  name = "${var.name}-lb-controller-policy"
  role = aws_iam_role.node_group.id

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ec2:CreateTags"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:ec2:*:*:security-group/*"
          Condition = {
            "StringEquals" = {
              "ec2:CreateAction" = "CreateSecurityGroup"
            },
            "Null" = {
              "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
            }
          }
        },
        {
          Action = [
            "ec2:CreateTags",
            "ec2:DeleteTags"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:ec2:*:*:security-group/*"
          Condition = {
            "Null" = {
              "aws:RequestTag/elbv2.k8s.aws/cluster"  = "true",
              "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
            }
          }
        },
        {
          Action = [
            "elasticloadbalancing:CreateLoadBalancer",
            "elasticloadbalancing:CreateTargetGroup"
          ]
          Effect   = "Allow"
          Resource = "*"
          Condition = {
            "Null" = {
              "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
            }
          }
        },
        {
          Action = [
            "elasticloadbalancing:AddTags",
            "elasticloadbalancing:RemoveTags"
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
            "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
            "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
          ]
          # Condition = {
          #   "Null" = {
          #     "aws:RequestTag/elbv2.k8s.aws/cluster"  = "true",
          #     "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
          #   }
          # }
        },
        {
          Action = [
            "elasticloadbalancing:AddTags",
            "elasticloadbalancing:RemoveTags"
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
            "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
            "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
            "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
          ]
        },
        {
          Action = [
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:RevokeSecurityGroupIngress",
            "ec2:DeleteSecurityGroup",
            "elasticloadbalancing:ModifyLoadBalancerAttributes",
            "elasticloadbalancing:SetIpAddressType",
            "elasticloadbalancing:SetSecurityGroups",
            "elasticloadbalancing:SetSubnets",
            "elasticloadbalancing:DeleteLoadBalancer",
            "elasticloadbalancing:ModifyTargetGroup",
            "elasticloadbalancing:ModifyTargetGroupAttributes",
            "elasticloadbalancing:DeleteTargetGroup"
          ]
          Effect = "Allow"
          Resource = [
            "*"
          ]
          Condition = {
            "Null" = {
              "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
            }
          }
        },
        {
          Action = [
            "elasticloadbalancing:RegisterTargets",
            "elasticloadbalancing:DeregisterTargets"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
        },
        {
          Action = [
            "iam:CreateServiceLinkedRole",
            "ec2:DescribeAccountAttributes",
            "ec2:DescribeAddresses",
            "ec2:DescribeAvailabilityZones",
            "ec2:DescribeInternetGateways",
            "ec2:DescribeVpcs",
            "ec2:DescribeVpcPeeringConnections",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeInstances",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeTags",
            "ec2:DescribeCoipPools",
            "elasticloadbalancing:DescribeLoadBalancers",
            "elasticloadbalancing:DescribeLoadBalancerAttributes",
            "elasticloadbalancing:DescribeListeners",
            "elasticloadbalancing:DescribeListenerCertificates",
            "elasticloadbalancing:DescribeSSLPolicies",
            "elasticloadbalancing:DescribeRules",
            "elasticloadbalancing:DescribeTargetGroups",
            "elasticloadbalancing:DescribeTargetGroupAttributes",
            "elasticloadbalancing:DescribeTargetHealth",
            "elasticloadbalancing:DescribeTags",
            "cognito-idp:DescribeUserPoolClient",
            "acm:ListCertificates",
            "acm:DescribeCertificate",
            "iam:ListServerCertificates",
            "iam:GetServerCertificate",
            "waf-regional:GetWebACL",
            "waf-regional:GetWebACLForResource",
            "waf-regional:AssociateWebACL",
            "waf-regional:DisassociateWebACL",
            "wafv2:GetWebACL",
            "wafv2:GetWebACLForResource",
            "wafv2:AssociateWebACL",
            "wafv2:DisassociateWebACL",
            "shield:GetSubscriptionState",
            "shield:DescribeProtection",
            "shield:CreateProtection",
            "shield:DeleteProtection",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:RevokeSecurityGroupIngress",
            "ec2:CreateSecurityGroup",
            "elasticloadbalancing:CreateListener",
            "elasticloadbalancing:DeleteListener",
            "elasticloadbalancing:CreateRule",
            "elasticloadbalancing:DeleteRule",
            "elasticloadbalancing:SetWebAcl",
            "elasticloadbalancing:ModifyListener",
            "elasticloadbalancing:AddListenerCertificates",
            "elasticloadbalancing:RemoveListenerCertificates",
            "elasticloadbalancing:ModifyRule"
          ]
          Effect = "Allow"
          Resource = [
            "*"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "AppMesh" {
  name = "${var.name}-AppMesh-policy"
  role = aws_iam_role.node_group.id

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "servicediscovery:CreateService",
            "servicediscovery:DeleteService",
            "servicediscovery:GetService",
            "servicediscovery:GetInstance",
            "servicediscovery:RegisterInstance",
            "servicediscovery:DeregisterInstance",
            "servicediscovery:ListInstances",
            "servicediscovery:ListNamespaces",
            "servicediscovery:ListServices",
            "servicediscovery:GetInstancesHealthStatus",
            "servicediscovery:UpdateInstanceCustomHealthStatus",
            "servicediscovery:GetOperation",
            "route53:GetHealthCheck",
            "route53:CreateHealthCheck",
            "route53:UpdateHealthCheck",
            "route53:ChangeResourceRecordSets",
            "route53:DeleteHealthCheck",
            "appmesh:*"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "AutoScaling" {
  name = "${var.name}-AutoScaling-policy"
  role = aws_iam_role.node_group.id

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DescribeTags",
            "autoscaling:SetDesiredCapacity",
            "autoscaling:TerminateInstanceInAutoScalingGroup",
            "ec2:DescribeInstanceTypes",
            "ec2:DescribeLaunchTemplateVersions"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "DNSChangeSet" {
  name = "${var.name}-DNSChangeSet-policy"
  role = aws_iam_role.node_group.id

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "route53:ChangeResourceRecordSets"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:route53:::hostedzone/*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "DNSHostedZones" {
  name = "${var.name}-DNSHostedZones-policy"
  role = aws_iam_role.node_group.id

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets",
            "route53:ListTagsForResource"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    }
  )
}
