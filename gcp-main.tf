# Service APIs
resource "google_project_service" "this" {
  for_each = var.gcp_deployment ? toset(var.gcp_service_list) : []

  project                    = var.project_id
  service                    = each.key
  disable_dependent_services = true

  disable_on_destroy = true
}

data "google_compute_zones" "this" {
  count  = var.gcp_deployment ? 1 : 0
  region = var.region
}

data "google_client_config" "provider" {
  count = var.gcp_deployment ? 1 : 0
}

data "google_project" "this" {
  count = var.gcp_deployment ? 1 : 0
}

locals {
  zones = one(data.google_compute_zones.this[*].names)
}

# Kubernetes Cluster
resource "google_container_cluster" "standard" {
  count = var.gcp_deployment ? 1 : 0

  # default_max_pods_per_node = 110
  # initial_node_count        = 0
  min_master_version  = var.gcp_cluster_version
  location            = var.gcp_region
  name                = var.gcp_name
  network             = var.vpc_network
  networking_mode     = "VPC_NATIVE"
  node_locations      = formatlist("${var.gcp_region}-%s", var.gcp_zones)
  project             = var.project_id
  subnetwork          = var.subnetwork
  deletion_protection = false

  addons_config {
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    http_load_balancing {
      disabled = false
    }
    network_policy_config {
      disabled = true
    }
  }
  binary_authorization {
    evaluation_mode = "DISABLED"
  }
  cluster_autoscaling {
    enabled = true
    auto_provisioning_defaults {
      disk_size       = var.gcp_node_disk_size
      disk_type       = var.gcp_node_disk_type
      image_type      = "COS_CONTAINERD"
      service_account = "default"
      management {
        auto_repair  = true
        auto_upgrade = true
      }
      shielded_instance_config {
        enable_integrity_monitoring = true
        enable_secure_boot          = false
      }
      upgrade_settings {
        max_surge       = 1
        max_unavailable = 0
        strategy        = "SURGE"
      }
    }
    resource_limits {
      maximum       = var.gcp_autoscaling_cpu["maximum"]
      minimum       = var.gcp_autoscaling_cpu["minimum"]
      resource_type = "cpu"
    }
    resource_limits {
      maximum       = var.gcp_autoscaling_memory["maximum"]
      minimum       = var.gcp_autoscaling_memory["minimum"]
      resource_type = "memory"
    }
  }
  ip_allocation_policy {
    stack_type = "IPV4"
    # services_ipv4_cidr_block = var.services_ipv4_cidr_block
    pod_cidr_overprovision_config {
      disabled = false
    }
  }
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
  monitoring_config {
    managed_prometheus {
      enabled = var.enable_prometheus
    }
  }

  // ignore changes in node pool configuration
  lifecycle {
    ignore_changes = [node_pool[0].node_count]
  }

  node_pool {
    # initial_node_count = 1
    # max_pods_per_node = 110
    name           = "${var.gcp_name}-pool"
    node_count     = var.gcp_node_count
    node_locations = formatlist("${var.gcp_region}-%s", var.gcp_zones)
    autoscaling {
      location_policy = "BALANCED"
      max_node_count  = var.gcp_max_node_count
      min_node_count  = 1
    }
    management {
      auto_repair  = true
      auto_upgrade = true
    }
    node_config {
      disk_size_gb    = var.gcp_node_disk_size
      disk_type       = var.gcp_node_disk_type
      image_type      = "COS_CONTAINERD"
      local_ssd_count = 0
      logging_variant = "DEFAULT"
      machine_type    = var.gcp_node_type
      metadata = {
        disable-legacy-endpoints = "true"
      }
      service_account = "default"
      spot            = false
      tags            = var.firewall_target_tags != [] ? var.firewall_target_tags : null
    }
    upgrade_settings {
      max_surge       = 1
      max_unavailable = 0
      strategy        = "SURGE"
    }
  }
  private_cluster_config {
    # This field only applies to private clusters, when enable_private_nodes is true.
    enable_private_endpoint = false

    # Enables the private cluster feature, creating a private endpoint on the cluster.
    enable_private_nodes = true

    # The IP range in CIDR notation to use for the hosted master network.
    master_ipv4_cidr_block = var.cluster_master_network_cidr

    # Whether the cluster master is accessible globally or not.
    master_global_access_config {
      enabled = true
    }
  }
  release_channel {
    channel = "REGULAR"
  }
  service_external_ips_config {
    enabled = false
  }
  vertical_pod_autoscaling {
    enabled = true
  }
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  depends_on = [google_project_service.this]
}

resource "helm_release" "gcp_kubernetes_dashboard" {
  count = var.gcp_deployment ? 1 : 0

  name       = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard"
  chart      = "kubernetes-dashboard"
  namespace  = "kube-system"
  version    = "6.0.8"

  values = [
    templatefile("./kube-dashboard.yml.tpl", {
      service_account_name = "kube-dashboard"
      service_type         = var.gcp_kubernetes_dashboard_service_type
    })
  ]
}

resource "kubernetes_service_account_v1" "gcp" {
  count = var.gcp_deployment ? 1 : 0

  metadata {
    name      = "admin-user"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding_v1" "gcp" {
  count = var.gcp_deployment ? 1 : 0

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

resource "kubernetes_secret_v1" "gcp" {
  count = var.gcp_deployment ? 1 : 0

  metadata {
    name      = "admin-user"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" : "admin-user"
    }
  }

  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_namespace" "this" {
  for_each = var.gcp_deployment ? toset([var.gcp_namespace]) : []

  metadata {
    annotations = {
      name = each.value
    }

    name = each.value
  }
}

locals {
  image = "${var.gcp_region}-docker.pkg.dev/${var.project_id != null ? var.project_id : ""}/${var.gcp_name != null ? var.gcp_name : ""}-repo"
}

# Artifact Registry Repository
resource "google_artifact_registry_repository" "this" {
  count = var.gcp_deployment ? 1 : 0

  location      = var.gcp_region
  repository_id = "${var.gcp_name}-repo"
  format        = "DOCKER"

  depends_on = [
    google_project_service.this
  ]
}

# Secret Manager
resource "google_secret_manager_secret" "github-token-secret" {
  count = var.gcp_deployment ? 1 : 0

  project   = var.project_id
  secret_id = "${var.gcp_name}-github-token-secret"

  replication {
    auto {}
  }

  depends_on = [
    google_project_service.this
  ]
}

resource "google_secret_manager_secret_version" "github-token-secret-version" {
  count = var.gcp_deployment ? 1 : 0

  secret      = google_secret_manager_secret.github-token-secret[0].id
  secret_data = var.gcp_github_token

  depends_on = [
    google_project_service.this
  ]
}

# Access permission for Secret
data "google_iam_policy" "p4sa-secretAccessor" {
  count = var.gcp_deployment ? 1 : 0

  binding {
    role    = "roles/secretmanager.secretAccessor"
    members = ["serviceAccount:service-${data.google_project.this[0].number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"]
  }

  depends_on = [
    google_project_service.this
  ]
}

resource "google_secret_manager_secret_iam_policy" "policy" {
  count = var.gcp_deployment ? 1 : 0

  secret_id   = google_secret_manager_secret.github-token-secret[0].secret_id
  policy_data = data.google_iam_policy.p4sa-secretAccessor[0].policy_data

  depends_on = [
    google_project_service.this
  ]
}

# GitHub Connection
resource "google_cloudbuildv2_connection" "this" {
  count = var.gcp_deployment ? 1 : 0

  project  = var.project_id
  location = var.gcp_region
  name     = "${var.gcp_name}-github-connection"

  github_config {
    app_installation_id = var.app_installation_id
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github-token-secret-version[0].id
    }
  }

  depends_on = [
    data.google_iam_policy.p4sa-secretAccessor
  ]
}

resource "google_cloudbuildv2_repository" "this" {
  count = var.gcp_deployment ? length(var.gcp_pipeline_names) : 0

  project           = var.project_id
  location          = var.gcp_region
  name              = var.gcp_pipeline_names[count.index]
  parent_connection = google_cloudbuildv2_connection.this[0].name
  remote_uri        = "https://github.com/${var.gcp_github_username}/${var.gcp_repo_names[count.index]}.git"

  depends_on = [
    google_cloudbuildv2_connection.this
  ]
}

# Cloud Build Trigger
resource "google_cloudbuild_trigger" "this" {
  count = var.gcp_deployment ? length(var.gcp_pipeline_names) : 0

  name               = var.gcp_pipeline_names[count.index]
  location           = var.gcp_region
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"

  repository_event_config {
    repository = google_cloudbuildv2_repository.this[count.index].id
    push {
      branch = "^${length(var.gcp_branch) > 1 ? var.gcp_branch[count.index] : var.gcp_branch[0]}$"
    }
  }

  build {

    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "${local.image}/${var.gcp_pipeline_names[count.index]}:latest", "-t", "${local.image}/${var.gcp_pipeline_names[count.index]}:$SHORT_SHA", "."]
    }

    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "${local.image}/${var.gcp_pipeline_names[count.index]}:latest"]
    }

    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "${local.image}/${var.gcp_pipeline_names[count.index]}:$SHORT_SHA"]
    }

    # step {
    #   name = "gcr.io/cloud-builders/kubectl"
    #   args = ["delete", "pods", "--all", "-n", var.gcp_namespace] #["delete", "pods", "-l", var.gcp_k8s_app_labels[count.index], "-n", var.gcp_namespace]
    #   env = [
    #     "CLOUDSDK_COMPUTE_REGION=${var.gcp_region}",
    #     "CLOUDSDK_CONTAINER_CLUSTER=${var.gcp_name}"
    #   ]
    # }

    step {
      name = "gcr.io/cloud-builders/gke-deploy"
      args = ["run", "--filename", var.gcp_manifest_files[count.index], "--image", "${local.image}/${var.gcp_pipeline_names[count.index]}:$SHORT_SHA", "--cluster", var.gcp_name, "--location", var.gcp_region]
    }
  }

  depends_on = [
    kubernetes_namespace.this
  ]
}

# Cloud Build Role
resource "google_project_iam_member" "cloudbuild_roles" {
  for_each = var.gcp_deployment ? toset(["roles/run.admin", "roles/iam.serviceAccountUser", "roles/container.developer"]) : []

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${data.google_project.this[0].number}@cloudbuild.gserviceaccount.com"

  depends_on = [
    google_cloudbuild_trigger.this
  ]
}

# IP Address for Ingress
resource "google_compute_global_address" "ingress" {
  count = var.gcp_deployment ? length(var.gcp_pipeline_names) : 0

  name         = var.gcp_pipeline_names[count.index]
  address_type = "EXTERNAL"
}

data "google_compute_global_address" "ingress" {
  count = var.gcp_deployment ? length(var.gcp_pipeline_names) : 0

  name = var.gcp_pipeline_names[count.index]

  depends_on = [google_compute_global_address.ingress]
}

# Pipeline Notification
resource "google_monitoring_notification_channel" "this" {
  count = var.gcp_deployment && var.enable_gcp_notification ? length(var.gcp_email_addresses) : 0

  display_name = var.gcp_email_display_names[count.index]
  type         = "email"
  enabled      = true
  force_delete = true

  labels = {
    email_address = var.gcp_email_addresses[count.index]
  }
}

locals {
  trigger = zipmap(var.gcp_pipeline_names, google_cloudbuild_trigger.this[*].trigger_id)
}

resource "google_logging_metric" "error" {
  for_each = var.gcp_deployment && var.enable_gcp_notification ? local.trigger : {}

  project = var.project_id
  name    = "${each.key}-error-metric"
  filter  = "resource.type=\"build\"\r\nresource.labels.build_trigger_id=\"${each.value}\"\r\ntextPayload=~\"^ERROR:\""
  metric_descriptor {
    display_name = null
    metric_kind  = "DELTA"
    unit         = "1"
    value_type   = "INT64"
  }
  disabled         = false
  value_extractor  = null
  label_extractors = {}
  bucket_name      = null
}

resource "google_logging_metric" "success" {
  for_each = var.gcp_deployment && var.enable_gcp_notification ? local.trigger : {}

  project = var.project_id
  name    = "${each.key}-success-metric"
  filter  = "resource.type=\"build\"\r\nresource.labels.build_trigger_id=\"${each.value}\"\r\ntextPayload=~\"^DONE\""
  metric_descriptor {
    display_name = null
    metric_kind  = "DELTA"
    unit         = "1"
    value_type   = "INT64"
  }
  disabled         = false
  value_extractor  = null
  label_extractors = {}
  bucket_name      = null
}

resource "google_monitoring_alert_policy" "error" {
  for_each = var.gcp_deployment && var.enable_gcp_notification ? local.trigger : {}

  display_name = "${each.key}-error-alert"
  combiner     = "OR"
  conditions {
    display_name = "error-alert"
    condition_threshold {
      threshold_value = 0.5
      filter          = "resource.type = \"build\" AND metric.type = \"logging.googleapis.com/user/${google_logging_metric.error[each.key].id}\""
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_COUNT"
      }
      trigger {
        count   = 1
        percent = 0
      }
    }
  }
  severity              = "ERROR"
  notification_channels = google_monitoring_notification_channel.this[*].id
  alert_strategy {
    auto_close = "1800s"
    notification_channel_strategy {
      notification_channel_names = google_monitoring_notification_channel.this[*].id
      renotify_interval          = "3600s"
    }
  }

  documentation {
    content   = <<-EOT
      ## Pipeline Failed

      ### Summary

      The $${metric.display_name} of the $${resource.type} ${each.key}
      in the project $${resource.project} has failed,

      ### Additional resource information

      Pipeline Name: ${each.key}
    EOT
    mime_type = "text/markdown"
    subject   = "Cloud build Pipeline ${each.key} has Failed"
  }
}

resource "google_monitoring_alert_policy" "success" {
  for_each = var.gcp_deployment && var.enable_gcp_notification ? local.trigger : {}

  display_name = "${each.key}-success-alert"
  combiner     = "OR"
  conditions {
    display_name = "success-alert"
    condition_threshold {
      threshold_value = 0.5
      filter          = "resource.type = \"build\" AND metric.type = \"logging.googleapis.com/user/${google_logging_metric.success[each.key].id}\""
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_COUNT"
      }
      trigger {
        count   = 1
        percent = 0
      }
    }
  }
  # severity = "ERROR"
  notification_channels = google_monitoring_notification_channel.this[*].id
  alert_strategy {
    auto_close = "1800s"
    notification_channel_strategy {
      notification_channel_names = google_monitoring_notification_channel.this[*].id
      renotify_interval          = "3600s"
    }
  }

  documentation {
    content   = <<-EOT
      ## Pipeline succeed

      ### Summary

      The $${metric.display_name} of the $${resource.type} ${each.key}
      in the project $${resource.project} has runs successfully,

      ### Additional resource information

      Pipeline Name: ${each.key}
    EOT
    mime_type = "text/markdown"
    subject   = "Cloud build Pipeline ${each.key} runs successfully"
  }
}