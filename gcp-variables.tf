variable "gcp_deployment" {
  type        = bool
  description = "Whether to deploy resources in GCP cloud"
  default     = true # this will create resources in GCP
}

variable "project_id" {
  type        = string
  description = "Project ID"
  default     = null # "my-project-id"
}

variable "gcp_region" {
  type        = string
  description = "Region for this infrastructure"
  default     = "us-central1"
}

variable "credentials" {
  type        = string
  description = "File path of the GCP service account key"
  default     = null # "./path/to/the/credentials/credential.json"
}

# Service APIs

variable "gcp_service_list" {
  description = "The list of apis necessary for the project" # No need to change these default value
  type        = list(string)
  default = [
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "container.googleapis.com",
    "secretmanager.googleapis.com"
  ]
}

# VPC
variable "gcp_name" {
  type        = string
  description = "Name for this infrastructure"
  default     = null
}

variable "vpc_network" {
  type        = string
  description = "GCP VPC Network Name"
  default     = null
}

variable "subnetwork" {
  type        = string
  description = "GCP SubNetwork Name"
  default     = null
}

variable "gcp_zones" {
  type        = list(string)
  description = "List of zones for nodes will be create in GCP cluster. like 'a', 'b', 'c', 'f'"
  default     = ["a", "b"]
}

variable "gcp_node_count" {
  type        = number
  description = "Node count for GCP cluster in each zone. For example if you set 'gcp_zones' to 'a', 'b', 'c' and 'gcp_node_count' to 2. Total 6 nodes will be created"
  default     = 1
}

variable "gcp_max_node_count" {
  type        = number
  description = "Node count for GCP cluster autoscaling"
  default     = 10
}

variable "gcp_node_disk_size" {
  type        = number
  description = "Node Storage size GCP cluster"
  default     = 30
}

variable "gcp_node_disk_type" {
  type        = string
  description = "Node Storage type GCP cluster"
  default     = "pd-standard"
}

variable "gcp_node_type" {
  type        = string
  description = "Type of the node for GCP cluster"
  default     = "e2-standard-2"
}

variable "gcp_autoscaling_cpu" {
  type = object(
    {
      minimum = number
      maximum = number
    }
  )
  description = "Minimum and Maximum limit for CPU"
  default = {
    minimum = 1
    maximum = 10
  }
}

variable "gcp_autoscaling_memory" {
  type = object(
    {
      minimum = number
      maximum = number
    }
  )
  description = "Minimum and Maximum limit for MEMORY"
  default = {
    minimum = 2
    maximum = 48
  }
}

variable "firewall_target_tags" {
  type        = list(string)
  description = "A list of instance tags indicating sets of instances located in the network that may make network connections as specified in allowed"
  default     = []
}

variable "gcp_cluster_version" {
  type        = string
  description = "Kubernetes cluster version for GKE"
  default     = "1.27.8-gke.1067004"
}

variable "cluster_master_network_cidr" {
  type        = string
  description = "The IP range in CIDR notation to use for the hosted master network."
  default     = "10.30.30.0/28"
}

# variable "services_ipv4_cidr_block" {
#   type        = string
#   description = "The IP range in CIDR notation to use for the pods network."
#   default     = "10.132.0.0/20"
# }

variable "gcp_kubernetes_dashboard_service_type" {
  type        = string
  description = "Enter the type of the service for GCP kubernetes dashboard. Valid values are: 'NodePort', 'ClusterIP', 'LoadBalancer'"
  default     = "NodePort"
}

variable "enable_prometheus" {
  type        = bool
  description = "Whether to enable GCP manager Prometheus Monitoring for GKE cluster"
  default     = true
}

variable "gcp_pipeline_names" {
  type        = list(string)
  description = "List of Names of the pipelines. Adding New name will create new Pipelines."
  default     = []
}

variable "gcp_repo_names" {
  type        = list(string)
  description = "List of Name of the source repositories. For multiple pipelines should need multiple repo names"
  default     = []
}

variable "gcp_github_username" {
  type        = string
  description = "github account username."
  default     = null
}

variable "gcp_branch" {
  type        = list(string)
  description = "List Branch name of the repositories. If all pipelines needs same branch name. Enter on branch name is enough"
  default     = ["main"]
}

variable "gcp_github_token" {
  type        = string
  description = "Github Oauth token for GCP"
  default     = null
}

variable "gcp_manifest_files" {
  type        = list(string)
  description = "list of File path of your Kubernetes manifest file in each GitHub Repositories. For multiple pipelines should need multiple values."
  default     = ["manifests/"]
}

variable "gcp_namespace" {
  type        = string
  description = "namespace for gcp kubernetes cluster"
  default     = null
}

variable "app_installation_id" {
  type        = string
  description = "The installation ID of your Cloud Build GitHub app. Your installation ID can be found in the URL of your Cloud Build GitHub App. In the following URL, https://github.com/settings/installations/1234567, the installation ID is the numerical value 1234567."
  default     = null
}

variable "enable_gcp_notification" {
  type        = bool
  description = "Whether to enable Pipeline notification in GCP"
  default     = false
}

variable "gcp_email_display_names" {
  type        = list(string)
  description = "List of names for email IDs for Alert Notifications"
  default     = []
}

variable "gcp_email_addresses" {
  type        = list(string)
  description = "list of email IDs for notification."
  default     = []
}

# variable "gcp_k8s_app_labels" {
#   type        = list(string)
#   description = "list of labels of deployments. For every pipeline, need seperate labels"
#   default     = ["app=myapp"] # ["app=myapp1", "app=myapp1"] # if you have 2 pipelines
# }