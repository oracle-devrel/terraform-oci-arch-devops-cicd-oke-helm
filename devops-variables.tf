## Copyright (c) 2022, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "log_group_display_name" {
  default = "devops-logs"
}

variable "notification_topic_name" {
  default = "devops-topic"
}

variable "execute_build_pipeline" {
  default = true
}

variable "project_description" {
  default = "DevOps Project for OKE deployment"
}

variable "environment_display_name" {
  default = "DevOps OKE Environment (Helm deployment)"
}
variable "environment_description" {
  default = "OKE environment  with Helm to deploy the app"
}
variable "environment_type" {
  default = "OKE_CLUSTER"
}

variable "project_logging_config_display_name_prefix" {
  default = "demo-"
}

variable "project_logging_config_is_archiving_enabled" {
  default = false
}

variable "project_logging_config_retention_period_in_days" {
  default = 30
}


variable "deploy_artifact_source_type" {
  default = "INLINE"
}

variable "deploy_artifact_type" {
  default = "KUBERNETES_MANIFEST"
}

variable "argument_substitution_mode" {
  default = "SUBSTITUTE_PLACEHOLDERS"
}

variable "create_dynamic_group_for_devops_pipln_in_compartment" {
  default = true
}

variable "deploy_pipeline_display_name" {
  default = "devops-oke-pipeline"
}

variable "deploy_pipeline_description" {
  default = "Devops Pipleline demo for OKE"
}

variable "deploy_stage_deploy_stage_type" {
  default = "OKE_HELM_CHART_DEPLOYMENT"
}

variable "deploy_stage_helm_release_name" {
  default = "node-service"
}

variable "deploy_stage_display_name" {
  default = "Deploy Helm"
}

variable "deploy_stage_description" {
  default = "test deployment to OKE"
}

variable "deploy_pipeline_deploy_pipeline_parameters_items_default_value" {
  default = ""
}

variable "deploy_pipeline_deploy_pipeline_parameters_items_description" {
  default = ""
}

variable "deploy_pipeline_deploy_pipeline_parameters_items_name" {
  default = "BUILDRUN_HASH"
}
