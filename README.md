# Deploy Services in either AWS or GCP

To deploy services in **AWS**, the value of the variable **aws_deployment** in **aws-variables.tf** file should be **true**
and **gcp_deployment** in **gcp-variables.tf** file should be **false**

Same Procedure for **GCP**. **gcp_deployment** in **gcp-variables.tf** file should be **true** 
and **aws_deployment** in **aws-variables.tf** file should be **false** 

# GCP

## This should be enabled first **cloudresourcemanager**

Go to the following link and click on **Enable API**

https://console.cloud.google.com/apis/api/cloudresourcemanager.googleapis.com

## Connecting a GitHub host
Go to the following link. You should logged in both you **GCP** and **GitHub** accounts before get into the below link.

https://github.com/apps/google-cloud-build

Then click **Install** or **Configure** based on it shows to you.

Select your GitHub account or the organization where the repository you want to connect to is located.

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_26.png?raw=true)

You can selet either selected repositories or all repositories. Then click **Install&Request**.

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_28.png?raw=true)

It will redirect you to your GCP account. No need to do anything after this. Just leave the page and click the below link again.

https://github.com/apps/google-cloud-build

Then click **Configure**.

Select your GitHub account or the organization which you configured early.

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_26.png?raw=true)

You can see the sumber in the link of that page. copy the number and paste it in you terraform code **gcp-variabels.tf** file **app_installation_id** variable.

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_27.png?raw=true)

## Create Service Account to give permissions to Terraform for create Resources in GCP
Go to the following link and click on **CREATE SERVICE ACCOUNT**

https://console.cloud.google.com/iam-admin/serviceaccounts


Enter a Name and ID for service account. Click **CREATE AND CONTINUE**

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_18.png?raw=true)

Add role for the service account. You can select **Owner** role to give permission to execute terraform using this service account. Then click **CONTINUE**

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_19.png?raw=true)

Click **DONE**

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_20.png?raw=true)

You can see the service accounts gets created. Click on the Name of your Service Account.

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_21.png?raw=true)

Go to **Keys --> ADD KEY --> Create new key**

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_22.png?raw=true)

Select **Key type** as **JSON** and click **CREATE**

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_23.png?raw=true)

Now your Key will be saved in your system. You can see that your serivce account hass an active key.

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_24.png?raw=true)

In the Terraform code Open **gcp-variables.tf** file and the variable **credentials** Enter the path of the gcp credentials file.

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_25.png?raw=true)


## To get Kubernetes dashboard token
```kubectl -n kube-system describe secret admin-user```

# AWS
## To Pass ARG in ECS Service
In **ecs-vars.tf** file  variable **task_commands**

#### For Single ECS services
Add the vaule as **[["generate"]]**

#### For multiple ECS services with different arguments
Add the vaule as **[["generate1"], ["generate2"]]**

#### For multiple ECS services with same argument
Add the vaule as **[["generate"]]**

## Add EFS as persistence Volume

If you want to add efs as persistent volume for your ECS services\
Open the **ecs-vars.tf** file and in line **149**\
Add values for variable **container_paths** with path names that you want to persist inside your container\
And change the variable **create_efs** value from **false** to **true**

## To apply ENV variables for ECS services

### For single ECS service

Replace the following values with your ENV values. You can add more values as much you want.

1. **ENV1, ENV2** --> Names of the Environment variables
2. **task1, task2** --> values of the Environment variables
```
variable "task_env_vars" {
  type = list(list(object(
    {
      name  = string,
      value = string
    }
  )))
  description = "List of key-value pair of environment variables for ecs task definition"
  default = [
    [
      {
        name  = "ENV1"
        value = "task1"
      },
      {
        name  = "ENV2"
        value = "task1"
      }
    ]
  ]
}
```

### For multiple ECS services

Each services can have any amount of environment variables like the below example.
```
variable "task_env_vars" {
  type = list(list(object(
    {
      name  = string,
      value = string
    }
  )))
  description = "List of key-value pair of environment variables for ecs task definition"
  default = [
    [
      {
        name  = "ENV1"
        value = "task1"
      },
      {
        name  = "ENV2"
        value = "task1"
      }
    ],
    [
      {
        name  = "ENV1"
        value = "task2"
      }
    ],
    [
      {
        name  = "ENV1"
        value = "task3"
      },
      {
        name  = "ENV2"
        value = "task3"
      }
    ]
  ]
}
```

## GitHub OAuth Token Create

Go to your github account and click on your **profile** followed by **Settings** --> **Developer settings**.

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_2.png?raw=true)

**Personal access tokens --> Tokens --> Generate new token**

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_1.png?raw=true)

Click on **Generate new token (classic)**

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_3.png?raw=true)

Enter a name for this token inside **Note**.
Select **Expiration** date for this token. If you need this token premanently select **No expiration**.

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_4.png?raw=true)

Select **repos** and **admin:repo_hook** permissions.

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_5.png?raw=true)

Click **Generate token** button.

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_6.png?raw=true)

Now it will show the OAuth token. Copy the token and save it somewhere else.

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_7.png?raw=true)

## Github1 to Github2 migration

Open the **variables.tf** file and the below screenshot is the example for **Github version 1**

The values for the below mentioned variables should be the same exactly like the below screenshot

1. source_provideer = "GitHub"
2. source_owner     = "ThirdParty"

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_8.png?raw=true)

The below picture is the example for **GitHub version 2** type.

The values for the below mentioned variables should be the same exactly like the below screenshot

1. source_provider = "CodeStarSourceConnection"
2. source_owner = "AWS"

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_9.png?raw=true)

Then execute terraform script. While the resources creation happens go to your AWS account and in follow the below steps with the reference of this image.

**Developer Tools --> Settings --> Connections --> Connection name**

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_10.png?raw=true)

Then click on **Update pending connection**.

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_11.png?raw=true)

It will open a new browser window. Click on the **Install a new app**.

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_12.png?raw=true)

Select the GitHub account that you have your source code.

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_13.png?raw=true)

If you want to give access to All repositories click on ** All repositories**.
But you can also mention for some particular one or more repos.

**Only select repositories --> Select repositories**

you can select one or multiple repositories.

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_14.png?raw=true)

You can able to see the selected repos to give access to aws code pipeline. Click on **Install** button.

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_15.png?raw=true)

Now you will see an ID of your GitHub connection. Click on **Connect**.

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_16.png?raw=true)

You will redirected to your AWS codestar connection page and you can see the **status** of your connection will be **Availabe**.

![alt text](https://github.com/jerinrathnamgem/aws-terraform-script/blob/main/images/Screenshot_17.png?raw=true)


## Enter values for Terraform  Variables 

1. For **access_key** and **secret_key**, provide the AWS credentials with their respective values.
2. For **ECS Deployment**, set **create_ecs_deployment** to **true** and set **create_ec2_deployment** and **create_eks_deployment** to **false**.
3. For **EC2 Deployment**, set **create_ec2_deployment** to **true** and set **create_ecs_deployment** and **create_eks_deployment** to **false**.
3. For **EKS Deployment**, set **create_eks_deployment** to **true** and set **create_ecs_deployment** and **create_ec2_deployment** to **false**.

## Run Terraform script

1. ```terraform init``` This command need to run once you have cloned this code in your system to initialize the terraform depencies.

2. ```terraform plan``` This command will shows the details of creation or changes of the resources.

3. ```terraform apply``` This command will deploy the resources. 

4. ```terraform destroy``` To delete all the resources
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.39.1 |
| <a name="provider_google"></a> [google](#provider\_google) | 5.19.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.12.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.26.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.10.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2"></a> [ec2](#module\_ec2) | ./modules/ec2 | n/a |
| <a name="module_ec2-pipeline"></a> [ec2-pipeline](#module\_ec2-pipeline) | ./modules/code-pipeline | n/a |
| <a name="module_ecs"></a> [ecs](#module\_ecs) | ./modules/ecs-cluster | n/a |
| <a name="module_ecs-pipeline"></a> [ecs-pipeline](#module\_ecs-pipeline) | ./modules/code-pipeline | n/a |
| <a name="module_eks-cluster"></a> [eks-cluster](#module\_eks-cluster) | ./modules/eks-cluster | n/a |
| <a name="module_eks-pipeline"></a> [eks-pipeline](#module\_eks-pipeline) | ./modules/code-pipeline | n/a |
| <a name="module_load-balancer"></a> [load-balancer](#module\_load-balancer) | ./modules/load-balancer | n/a |
| <a name="module_security-group-ec2"></a> [security-group-ec2](#module\_security-group-ec2) | ./modules/security-group | n/a |
| <a name="module_security-group-ecs"></a> [security-group-ecs](#module\_security-group-ecs) | ./modules/security-group | n/a |
| <a name="module_security-group-lb"></a> [security-group-lb](#module\_security-group-lb) | ./modules/security-group | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_codestarconnections_connection.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codestarconnections_connection) | resource |
| [aws_codestarnotifications_notification_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codestarnotifications_notification_rule) | resource |
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_efs_access_point.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_file_system.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_sns_topic.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [google_artifact_registry_repository.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_cloudbuild_trigger.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger) | resource |
| [google_cloudbuildv2_connection.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuildv2_connection) | resource |
| [google_cloudbuildv2_repository.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuildv2_repository) | resource |
| [google_compute_global_address.ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_container_cluster.standard](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [google_logging_metric.error](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_metric) | resource |
| [google_logging_metric.success](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_metric) | resource |
| [google_monitoring_alert_policy.error](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_alert_policy.success](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_notification_channel.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_notification_channel) | resource |
| [google_project_iam_member.cloudbuild_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_secret_manager_secret.github-token-secret](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_policy.policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_policy) | resource |
| [google_secret_manager_secret_version.github-token-secret-version](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [helm_release.aws-load-balancer-controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.gcp_kubernetes_dashboard](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.kubernetes_dashboard](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_cluster_role_binding_v1.gcp](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding_v1) | resource |
| [kubernetes_cluster_role_binding_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding_v1) | resource |
| [kubernetes_config_map_v1_data.aws-auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1_data) | resource |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret_v1.gcp](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_service_account_v1.alb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |
| [kubernetes_service_account_v1.gcp](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |
| [kubernetes_service_account_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |
| [time_sleep.ec2](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_subnets.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [google_client_config.provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_global_address.ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_global_address) | data source |
| [google_compute_zones.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [google_iam_policy.p4sa-secretAccessor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_policy) | data source |
| [google_project.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_key"></a> [access\_key](#input\_access\_key) | Enter the AWS Access Key ID | `string` | `null` | no |
| <a name="input_alb_subnet_ids"></a> [alb\_subnet\_ids](#input\_alb\_subnet\_ids) | list of subnet ids for Load Balancer | `list(string)` | `null` | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | Provide the AMI ID for EC2 Instance | `string` | `null` | no |
| <a name="input_app_installation_id"></a> [app\_installation\_id](#input\_app\_installation\_id) | The installation ID of your Cloud Build GitHub app. Your installation ID can be found in the URL of your Cloud Build GitHub App. In the following URL, https://github.com/settings/installations/1234567, the installation ID is the numerical value 1234567. | `string` | `null` | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Whether the public ip for ECS service should be created | `bool` | `true` | no |
| <a name="input_aws_deployment"></a> [aws\_deployment](#input\_aws\_deployment) | Whether to deploy resources in AWS cloud | `bool` | `false` | no |
| <a name="input_build_container_type"></a> [build\_container\_type](#input\_build\_container\_type) | Type of build environment to use for related builds. Valid values: LINUX\_CONTAINER, LINUX\_GPU\_CONTAINER, WINDOWS\_CONTAINER (deprecated), WINDOWS\_SERVER\_2019\_CONTAINER, ARM\_CONTAINER. | `string` | `"LINUX_CONTAINER"` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | Certificate arn of the domain for load balancer | `string` | `""` | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Whether the Amazon EKS private API server endpoint is enabled. | `string` | `false` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Whether the Amazon EKS public API server endpoint is enabled. | `string` | `true` | no |
| <a name="input_cluster_master_network_cidr"></a> [cluster\_master\_network\_cidr](#input\_cluster\_master\_network\_cidr) | The IP range in CIDR notation to use for the hosted master network. | `string` | `"10.30.30.0/28"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the ECS cluster | `string` | `"cluster-name"` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Version of the EKS cluster | `string` | `"1.28"` | no |
| <a name="input_codebuild_compute_type"></a> [codebuild\_compute\_type](#input\_codebuild\_compute\_type) | Type or aize of the server for code build project. Valid values: BUILD\_GENERAL1\_SMALL, BUILD\_GENERAL1\_MEDIUM, BUILD\_GENERAL1\_LARGE, BUILD\_GENERAL1\_2XLARGE | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_connection_arn"></a> [connection\_arn](#input\_connection\_arn) | ARN of the code star connection, Not needed | `string` | `null` | no |
| <a name="input_container_images"></a> [container\_images](#input\_container\_images) | List of images for task definition | `list(string)` | `[]` | no |
| <a name="input_container_paths"></a> [container\_paths](#input\_container\_paths) | List of volume path in ECS task containers. Should be same as the vaue of the variable task\_mount\_path --> containerPath | `list(string)` | `[]` | no |
| <a name="input_create_cluster"></a> [create\_cluster](#input\_create\_cluster) | Whether the ECS or EKS cluster needs to be create or not. If 'false' It will use existing ECS cluster | `bool` | `true` | no |
| <a name="input_create_ec2_deployment"></a> [create\_ec2\_deployment](#input\_create\_ec2\_deployment) | For EC2 deployment | `bool` | `false` | no |
| <a name="input_create_ec2_server"></a> [create\_ec2\_server](#input\_create\_ec2\_server) | whether to create EC2 instance | `bool` | `true` | no |
| <a name="input_create_ecs_deployment"></a> [create\_ecs\_deployment](#input\_create\_ecs\_deployment) | For ECS deployment | `bool` | `true` | no |
| <a name="input_create_efs"></a> [create\_efs](#input\_create\_efs) | Whether to create efs storage for ECS | `bool` | `false` | no |
| <a name="input_create_eip"></a> [create\_eip](#input\_create\_eip) | Whether to create Elastic IP or not | `bool` | `true` | no |
| <a name="input_create_eks_deployment"></a> [create\_eks\_deployment](#input\_create\_eks\_deployment) | For EKS deployment | `bool` | `false` | no |
| <a name="input_create_pipeline"></a> [create\_pipeline](#input\_create\_pipeline) | Whether to create pipeline or not | `bool` | `true` | no |
| <a name="input_create_s3_bucket"></a> [create\_s3\_bucket](#input\_create\_s3\_bucket) | Whether to create s3 bucket for pipeline | `bool` | `true` | no |
| <a name="input_create_secrets_manager"></a> [create\_secrets\_manager](#input\_create\_secrets\_manager) | whether to create secrets manager or not | `bool` | `true` | no |
| <a name="input_credentials"></a> [credentials](#input\_credentials) | File path of the GCP service account key | `string` | `null` | no |
| <a name="input_cw_logs_retention_in_days"></a> [cw\_logs\_retention\_in\_days](#input\_cw\_logs\_retention\_in\_days) | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, and 0 | `number` | `60` | no |
| <a name="input_docker_password"></a> [docker\_password](#input\_docker\_password) | Username of docker hub password | `string` | n/a | yes |
| <a name="input_docker_username"></a> [docker\_username](#input\_docker\_username) | Username of the Docker hub registry | `string` | n/a | yes |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | Provide the type of the EC2 Instance | `string` | `"t3.medium"` | no |
| <a name="input_ec2_name"></a> [ec2\_name](#input\_ec2\_name) | Name for EC2 instance | `string` | `"Node-App-1"` | no |
| <a name="input_ec2_port"></a> [ec2\_port](#input\_ec2\_port) | Port number for the application in EC2 | `number` | `3000` | no |
| <a name="input_ec2_subnet_id"></a> [ec2\_subnet\_id](#input\_ec2\_subnet\_id) | ID of the subnet for ec2 | `string` | `null` | no |
| <a name="input_ecs_deployment_timeout"></a> [ecs\_deployment\_timeout](#input\_ecs\_deployment\_timeout) | The Amazon ECS deployment action timeout in minutes. The timeout is configurable up to the maximum default timeout for this action. | `number` | `10` | no |
| <a name="input_ecs_ports"></a> [ecs\_ports](#input\_ecs\_ports) | List of Port numbers for the application in ECS | `list(number)` | <pre>[<br>  3000<br>]</pre> | no |
| <a name="input_ecs_service_names"></a> [ecs\_service\_names](#input\_ecs\_service\_names) | List of Names for ECS services | `list(string)` | <pre>[<br>  "Node-App-1"<br>]</pre> | no |
| <a name="input_ecs_subnet_ids"></a> [ecs\_subnet\_ids](#input\_ecs\_subnet\_ids) | list of subnet ids for ECS service | `list(string)` | `null` | no |
| <a name="input_efs_encrypted"></a> [efs\_encrypted](#input\_efs\_encrypted) | Whether the EFS storage c=should be encrypted | `bool` | `true` | no |
| <a name="input_efs_file_system_id"></a> [efs\_file\_system\_id](#input\_efs\_file\_system\_id) | ID of the EFS file system. Needed only 'create\_efs' is set to 'false' | `string` | `null` | no |
| <a name="input_efs_kms_id"></a> [efs\_kms\_id](#input\_efs\_kms\_id) | The ARN for the KMS encryption key. When specifying kms\_key\_id, encrypted needs to be set to true. | `string` | `null` | no |
| <a name="input_efs_performance_mode"></a> [efs\_performance\_mode](#input\_efs\_performance\_mode) | The file system performance mode. Can be either 'generalPurpose' or 'maxIO' | `string` | `"generalPurpose"` | no |
| <a name="input_efs_subnet_ids"></a> [efs\_subnet\_ids](#input\_efs\_subnet\_ids) | List of subnet IDs for EFS. If default VPC using, Leave it as empty | `list(string)` | `[]` | no |
| <a name="input_efs_throughput_mode"></a> [efs\_throughput\_mode](#input\_efs\_throughput\_mode) | The throughput, measured in MiB/s, that you want to provision for the file system. Only applicable with throughput\_mode set to provisioned. | `string` | `"bursting"` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Name for EKS cluster | `string` | `"eks-cluster-name"` | no |
| <a name="input_eks_node_subnet_ids"></a> [eks\_node\_subnet\_ids](#input\_eks\_node\_subnet\_ids) | list of subnet ids for EKS Node group | `list(string)` | `null` | no |
| <a name="input_eks_node_type"></a> [eks\_node\_type](#input\_eks\_node\_type) | Provide the type of the EKS cluster nodes | `string` | `"t3.medium"` | no |
| <a name="input_eks_pipeline_names"></a> [eks\_pipeline\_names](#input\_eks\_pipeline\_names) | List of names for EKS pipelines. Leave it blank if no pipeline needs to be create | `list(string)` | `[]` | no |
| <a name="input_eks_subnet_ids"></a> [eks\_subnet\_ids](#input\_eks\_subnet\_ids) | list of subnet ids for EKS Cluster Control plane | `list(string)` | `null` | no |
| <a name="input_email_addresses"></a> [email\_addresses](#input\_email\_addresses) | List of Email address for code commit notification | `list(string)` | <pre>[<br>  "example@gmail.com"<br>]</pre> | no |
| <a name="input_enable_gcp_notification"></a> [enable\_gcp\_notification](#input\_enable\_gcp\_notification) | Whether to enable Pipeline notification in GCP | `bool` | `true` | no |
| <a name="input_enable_prometheus"></a> [enable\_prometheus](#input\_enable\_prometheus) | Whether to enable GCP manager Prometheus Monitoring for GKE cluster | `bool` | `true` | no |
| <a name="input_enabled_cluster_log_types"></a> [enabled\_cluster\_log\_types](#input\_enabled\_cluster\_log\_types) | List of EKS Cluster log types. Enter 'null' for disable logs | `list(string)` | <pre>[<br>  "api",<br>  "audit",<br>  "authenticator"<br>]</pre> | no |
| <a name="input_env_vars"></a> [env\_vars](#input\_env\_vars) | Map of environment variables for code build project | `map(any)` | `{}` | no |
| <a name="input_firewall_target_tags"></a> [firewall\_target\_tags](#input\_firewall\_target\_tags) | A list of instance tags indicating sets of instances located in the network that may make network connections as specified in allowed | `list(string)` | `[]` | no |
| <a name="input_gcp_autoscaling_cpu"></a> [gcp\_autoscaling\_cpu](#input\_gcp\_autoscaling\_cpu) | Minimum and Maximum limit for CPU | <pre>object(<br>    {<br>      minimum = number<br>      maximum = number<br>    }<br>  )</pre> | <pre>{<br>  "maximum": 10,<br>  "minimum": 1<br>}</pre> | no |
| <a name="input_gcp_autoscaling_memory"></a> [gcp\_autoscaling\_memory](#input\_gcp\_autoscaling\_memory) | Minimum and Maximum limit for MEMORY | <pre>object(<br>    {<br>      minimum = number<br>      maximum = number<br>    }<br>  )</pre> | <pre>{<br>  "maximum": 48,<br>  "minimum": 2<br>}</pre> | no |
| <a name="input_gcp_branch"></a> [gcp\_branch](#input\_gcp\_branch) | List Branch name of the repositories. If all pipelines needs same branch name. Enter on branch name is enough | `list(string)` | <pre>[<br>  "main"<br>]</pre> | no |
| <a name="input_gcp_cluster_version"></a> [gcp\_cluster\_version](#input\_gcp\_cluster\_version) | Kubernetes cluster version for GKE | `string` | `"1.27.8-gke.1067004"` | no |
| <a name="input_gcp_deployment"></a> [gcp\_deployment](#input\_gcp\_deployment) | Whether to deploy resources in GCP cloud | `bool` | `true` | no |
| <a name="input_gcp_email_addresses"></a> [gcp\_email\_addresses](#input\_gcp\_email\_addresses) | list of email IDs for notification. | `list(string)` | `[]` | no |
| <a name="input_gcp_email_display_names"></a> [gcp\_email\_display\_names](#input\_gcp\_email\_display\_names) | List of names for email IDs for Alert Notifications | `list(string)` | `[]` | no |
| <a name="input_gcp_github_token"></a> [gcp\_github\_token](#input\_gcp\_github\_token) | Github Oauth token for GCP | `string` | `null` | no |
| <a name="input_gcp_github_username"></a> [gcp\_github\_username](#input\_gcp\_github\_username) | github account username. | `string` | `null` | no |
| <a name="input_gcp_kubernetes_dashboard_service_type"></a> [gcp\_kubernetes\_dashboard\_service\_type](#input\_gcp\_kubernetes\_dashboard\_service\_type) | Enter the type of the service for GCP kubernetes dashboard. Valid values are: 'NodePort', 'ClusterIP', 'LoadBalancer' | `string` | `"NodePort"` | no |
| <a name="input_gcp_manifest_files"></a> [gcp\_manifest\_files](#input\_gcp\_manifest\_files) | list of File path of your Kubernetes manifest file in each GitHub Repositories. For multiple pipelines should need multiple values. | `list(string)` | <pre>[<br>  "manifests/"<br>]</pre> | no |
| <a name="input_gcp_max_node_count"></a> [gcp\_max\_node\_count](#input\_gcp\_max\_node\_count) | Node count for GCP cluster autoscaling | `number` | `10` | no |
| <a name="input_gcp_name"></a> [gcp\_name](#input\_gcp\_name) | Name for this infrastructure | `string` | `null` | no |
| <a name="input_gcp_namespace"></a> [gcp\_namespace](#input\_gcp\_namespace) | namespace for gcp kubernetes cluster | `string` | `null` | no |
| <a name="input_gcp_node_count"></a> [gcp\_node\_count](#input\_gcp\_node\_count) | Node count for GCP cluster in each zone. For example if you set 'gcp\_zones' to 'a', 'b', 'c' and 'gcp\_node\_count' to 2. Total 6 nodes will be created | `number` | `1` | no |
| <a name="input_gcp_node_disk_size"></a> [gcp\_node\_disk\_size](#input\_gcp\_node\_disk\_size) | Node Storage size GCP cluster | `number` | `30` | no |
| <a name="input_gcp_node_disk_type"></a> [gcp\_node\_disk\_type](#input\_gcp\_node\_disk\_type) | Node Storage type GCP cluster | `string` | `"pd-standard"` | no |
| <a name="input_gcp_node_type"></a> [gcp\_node\_type](#input\_gcp\_node\_type) | Type of the node for GCP cluster | `string` | `"e2-standard-2"` | no |
| <a name="input_gcp_pipeline_names"></a> [gcp\_pipeline\_names](#input\_gcp\_pipeline\_names) | List of Names of the pipelines. Adding New name will create new Pipelines. | `list(string)` | `[]` | no |
| <a name="input_gcp_region"></a> [gcp\_region](#input\_gcp\_region) | Region for this infrastructure | `string` | `"us-central1"` | no |
| <a name="input_gcp_repo_names"></a> [gcp\_repo\_names](#input\_gcp\_repo\_names) | List of Name of the source repositories. For multiple pipelines should need multiple repo names | `list(string)` | `[]` | no |
| <a name="input_gcp_service_list"></a> [gcp\_service\_list](#input\_gcp\_service\_list) | The list of apis necessary for the project | `list(string)` | <pre>[<br>  "artifactregistry.googleapis.com",<br>  "cloudbuild.googleapis.com",<br>  "container.googleapis.com",<br>  "secretmanager.googleapis.com"<br>]</pre> | no |
| <a name="input_gcp_zones"></a> [gcp\_zones](#input\_gcp\_zones) | List of zones for nodes will be create in GCP cluster. like 'a', 'b', 'c', 'f' | `list(string)` | <pre>[<br>  "a",<br>  "b"<br>]</pre> | no |
| <a name="input_github_oauth_token"></a> [github\_oauth\_token](#input\_github\_oauth\_token) | GitHub OAuth Token with permissions to access private repositories | `string` | `"ouath-token"` | no |
| <a name="input_group_id"></a> [group\_id](#input\_group\_id) | Group ID in the docker container | `number` | `0` | no |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | Approximate amount of time, in seconds, between health checks of an individual target | `number` | `60` | no |
| <a name="input_health_check_paths"></a> [health\_check\_paths](#input\_health\_check\_paths) | List of health check paths | `list(string)` | <pre>[<br>  "/"<br>]</pre> | no |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | Amount of time, in seconds, during which no response from a target means a failed health check. | `number` | `30` | no |
| <a name="input_host_names"></a> [host\_names](#input\_host\_names) | List of names of domains. If you need to setup multiple domains, enter the domain names from the second applciations | `list(string)` | `[]` | no |
| <a name="input_host_paths"></a> [host\_paths](#input\_host\_paths) | List of paths of hosts. If ypu jave setup multiple paths, enter paths from the second applications | `list(string)` | `[]` | no |
| <a name="input_ignore_changes"></a> [ignore\_changes](#input\_ignore\_changes) | Whehter to ignore changes configuration should be apply | `bool` | `true` | no |
| <a name="input_image_identifier"></a> [image\_identifier](#input\_image\_identifier) | Docker image to use for this build project. | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:4.0"` | no |
| <a name="input_image_tags"></a> [image\_tags](#input\_image\_tags) | List of ECR image tags. If tags are 'latest' for all the images just leave it default. If a single value is same for all services, then provide one value is enough | `list(string)` | <pre>[<br>  "latest"<br>]</pre> | no |
| <a name="input_kms_key_recovery_window_in_days"></a> [kms\_key\_recovery\_window\_in\_days](#input\_kms\_key\_recovery\_window\_in\_days) | Number of days that AWS Secrets Manager waits before it can delete the secret. This value can be 0 to force deletion without recovery or range from 7 to 30 days. | `number` | `30` | no |
| <a name="input_kubernetes_dashboard_service_type"></a> [kubernetes\_dashboard\_service\_type](#input\_kubernetes\_dashboard\_service\_type) | Enter the type of the service for kubernetes dashboard. Valid values are: 'NodePort', 'ClusterIP', 'LoadBalancer' | `string` | `"NodePort"` | no |
| <a name="input_load_balancer_name"></a> [load\_balancer\_name](#input\_load\_balancer\_name) | Name for load balancer. if this value is 'null' Load Balancer won't be created. | `string` | `null` | no |
| <a name="input_node_ami_type"></a> [node\_ami\_type](#input\_node\_ami\_type) | Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Valid Values: AL2\_x86\_64 \| AL2\_x86\_64\_GPU \| AL2\_ARM\_64 \| CUSTOM \| BOTTLEROCKET\_ARM\_64 \| BOTTLEROCKET\_x86\_64 \| BOTTLEROCKET\_ARM\_64\_NVIDIA \| BOTTLEROCKET\_x86\_64\_NVIDIA \| WINDOWS\_CORE\_2019\_x86\_64 \| WINDOWS\_FULL\_2019\_x86\_64 \| WINDOWS\_CORE\_2022\_x86\_64 \| WINDOWS\_FULL\_2022\_x86\_64 | `string` | `"AL2_x86_64"` | no |
| <a name="input_node_desired_size"></a> [node\_desired\_size](#input\_node\_desired\_size) | desired size of the nodes for autoscaling group | `number` | `2` | no |
| <a name="input_node_max_size"></a> [node\_max\_size](#input\_node\_max\_size) | maximun size of the nodes for autoscaling group | `number` | `5` | no |
| <a name="input_node_min_size"></a> [node\_min\_size](#input\_node\_min\_size) | minimum size of the nodes for autoscaling group | `number` | `2` | no |
| <a name="input_node_private_key_name"></a> [node\_private\_key\_name](#input\_node\_private\_key\_name) | Enter the name of the Key-Pair for EKS Node Group | `string` | `null` | no |
| <a name="input_node_ssh_cidr_ips"></a> [node\_ssh\_cidr\_ips](#input\_node\_ssh\_cidr\_ips) | list of ssh IPs for EKS Node group | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_node_volume_size"></a> [node\_volume\_size](#input\_node\_volume\_size) | Size of the EKS cluster nodes | `number` | `30` | no |
| <a name="input_node_volume_termination"></a> [node\_volume\_termination](#input\_node\_volume\_termination) | Select the volume of EKS cluster nodes should be delete or not | `bool` | `false` | no |
| <a name="input_private_key_name"></a> [private\_key\_name](#input\_private\_key\_name) | Enter the name of the Key-Pair | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Enter the region for your infrastructure | `string` | `"us-east-1"` | no |
| <a name="input_repo_branch_names"></a> [repo\_branch\_names](#input\_repo\_branch\_names) | List of Names of the source code repo branch | `list(string)` | <pre>[<br>  "main"<br>]</pre> | no |
| <a name="input_repo_ids"></a> [repo\_ids](#input\_repo\_ids) | List of IDs of the source code repository | `list(string)` | <pre>[<br>  "repo-id"<br>]</pre> | no |
| <a name="input_repo_owner"></a> [repo\_owner](#input\_repo\_owner) | GitHub Organization or Username | `string` | `"github-username"` | no |
| <a name="input_route53_record_names"></a> [route53\_record\_names](#input\_route53\_record\_names) | List of subdomains for your applications | `list(string)` | `[]` | no |
| <a name="input_route53_zone_ids"></a> [route53\_zone\_ids](#input\_route53\_zone\_ids) | List of IDs of Route 53 Hosted zones. if same hosted zone for all sub domains single value is enough | `list(string)` | `[]` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of the S3 bucket for codepipeline | `string` | `null` | no |
| <a name="input_secret_key"></a> [secret\_key](#input\_secret\_key) | Enter the AWS Secret Access Key | `string` | `null` | no |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | Name for the secrets manager | `string` | `"secret-name"` | no |
| <a name="input_secrets_manager_arn"></a> [secrets\_manager\_arn](#input\_secrets\_manager\_arn) | ARN of the secrets manager. If you have existing Secrets Manager, Provide the ARN here | `string` | `null` | no |
| <a name="input_secrets_manager_kms_key_id"></a> [secrets\_manager\_kms\_key\_id](#input\_secrets\_manager\_kms\_key\_id) | ARN or Id of the AWS KMS key to be used to encrypt the secret values in the versions stored in this secret | `string` | `null` | no |
| <a name="input_services_ipv4_cidr_block"></a> [services\_ipv4\_cidr\_block](#input\_services\_ipv4\_cidr\_block) | The IP range in CIDR notation to use for the pods network. | `string` | `"10.132.0.0/20"` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | Only need to Provide SNS ARN, if there is existing SNS topic | `string` | `null` | no |
| <a name="input_source_owner"></a> [source\_owner](#input\_source\_owner) | Owner of the source provider for the code pipeline | `string` | `"ThirdParty"` | no |
| <a name="input_source_provider"></a> [source\_provider](#input\_source\_provider) | Name of the source provider for the code pipeline | `string` | `"GitHub"` | no |
| <a name="input_ssh_cidr_ips"></a> [ssh\_cidr\_ips](#input\_ssh\_cidr\_ips) | list of ssh Ips for ec2 instance | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | GCP SubNetwork Name | `string` | `null` | no |
| <a name="input_task_commands"></a> [task\_commands](#input\_task\_commands) | List of The commands that's passed to the container. | `list(list(string))` | `[]` | no |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | List of CPU for task definition. If a single value is same for all services, then provide one value is enough | `list(number)` | <pre>[<br>  256<br>]</pre> | no |
| <a name="input_task_credential_specs"></a> [task\_credential\_specs](#input\_task\_credential\_specs) | A list of ARNs in SSM or Amazon S3 to a credential spec (CredSpec) file that configures the container for Active Directory authentication. We recommend that you use this parameter instead of the dockerSecurityOptions. The maximum number of ARNs is 1. | `list(list(string))` | `[]` | no |
| <a name="input_task_entry_points"></a> [task\_entry\_points](#input\_task\_entry\_points) | List of The entry points that's passed to the container | `list(list(string))` | `[]` | no |
| <a name="input_task_env_files"></a> [task\_env\_files](#input\_task\_env\_files) | A list of files containing the environment variables to pass to a container. | <pre>list(list(object(<br>    {<br>      type  = string,<br>      value = string<br>    }<br>  )))</pre> | `[]` | no |
| <a name="input_task_env_vars"></a> [task\_env\_vars](#input\_task\_env\_vars) | List of key-value pair of environment variables for ecs task definition | <pre>list(list(object(<br>    {<br>      name  = string,<br>      value = string<br>    }<br>  )))</pre> | `[]` | no |
| <a name="input_task_ephemeral_storage"></a> [task\_ephemeral\_storage](#input\_task\_ephemeral\_storage) | The total amount, in GiB, of ephemeral storage to set for the task. The minimum supported value is 21 GiB and the maximum supported value is 200 GiB. | `list(number)` | `[]` | no |
| <a name="input_task_health_check"></a> [task\_health\_check](#input\_task\_health\_check) | The container health check command and associated configuration parameters for the container. | `list(map(any))` | `[]` | no |
| <a name="input_task_host_name"></a> [task\_host\_name](#input\_task\_host\_name) | The hostname to use for your container. | `list(string)` | `[]` | no |
| <a name="input_task_max_capacity"></a> [task\_max\_capacity](#input\_task\_max\_capacity) | List of maximum capacity number for task. If a single value is same for all services, then provide one value is enough | `list(number)` | <pre>[<br>  5<br>]</pre> | no |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | List of Memory for task definition. If a single value is same for all services, then provide one value is enough | `list(number)` | <pre>[<br>  512<br>]</pre> | no |
| <a name="input_task_min_capacity"></a> [task\_min\_capacity](#input\_task\_min\_capacity) | List of minimum capacity number for task. If a single value is same for all services, then provide one value is enough | `list(number)` | <pre>[<br>  1<br>]</pre> | no |
| <a name="input_task_volumes_from"></a> [task\_volumes\_from](#input\_task\_volumes\_from) | Data volumes to mount from another container | `list(list(map(any)))` | `[]` | no |
| <a name="input_user_id"></a> [user\_id](#input\_user\_id) | User ID in the docker container | `number` | `0` | no |
| <a name="input_volume_encryption"></a> [volume\_encryption](#input\_volume\_encryption) | Whether to encypt you ec2 root volume | `bool` | `true` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | Size of the EC2 root volume and EKS cluster nodes | `number` | `50` | no |
| <a name="input_volume_termination"></a> [volume\_termination](#input\_volume\_termination) | Select the volume of the instance and EKS cluster nodes should be delete or not | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the vpc | `string` | `"vpc-id"` | no |
| <a name="input_vpc_network"></a> [vpc\_network](#input\_vpc\_network) | GCP VPC Network Name | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_GCP_docker_image"></a> [GCP\_docker\_image](#output\_GCP\_docker\_image) | docker image URI of the GCP deployment application |
| <a name="output_GCP_loadbalancer_ip"></a> [GCP\_loadbalancer\_ip](#output\_GCP\_loadbalancer\_ip) | Name ad IP address of the Ingress Loadbalancer |
| <a name="output_build_logs_public_url"></a> [build\_logs\_public\_url](#output\_build\_logs\_public\_url) | List of Public Build URLs of Code Build projects |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | Domain Name of the Load Balancer |
