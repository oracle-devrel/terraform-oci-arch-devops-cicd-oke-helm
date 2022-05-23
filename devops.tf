## Copyright (c) 2022, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_logging_log_group" "test_log_group" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.app_name_normalized}_${random_string.deploy_id.result}_log_group"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_logging_log" "test_log" {
  #Required
  display_name = "${local.app_name_normalized}_${random_string.deploy_id.result}_log"
  log_group_id = oci_logging_log_group.test_log_group.id
  log_type     = "SERVICE"

  #Optional
  configuration {
    #Required
    source {
      #Required
      category    = "all"
      resource    = oci_devops_project.test_project.id
      service     = "devops"
      source_type = "OCISERVICE"
    }

    #Optional
    compartment_id = var.compartment_ocid
  }

  is_enabled         = true
  retention_duration = var.project_logging_config_retention_period_in_days
  defined_tags       = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_ons_notification_topic" "test_notification_topic" {
  compartment_id = var.compartment_ocid
  name           = "${local.app_name_normalized}_${random_string.deploy_id.result}_topic"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_devops_project" "test_project" {
  compartment_id = var.compartment_ocid
  # logging_config {
  #   log_group_id             = oci_logging_log_group.test_log_group.id
  #   retention_period_in_days = var.project_logging_config_retention_period_in_days
  # }

  name = "${local.app_name_normalized}_${random_string.deploy_id.result}"
  notification_config {
    #Required
    topic_id = oci_ons_notification_topic.test_notification_topic.id
  }
  #  LOgging config missing- Add that 

  #Optional
  description = var.project_description
  #freeform_tags = var.project_freeform_tags
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_devops_deploy_environment" "test_environment" {
  display_name            = "test_oke_env"
  description             = "test oke based enviroment"
  deploy_environment_type = "OKE_CLUSTER"
  project_id              = oci_devops_project.test_project.id
  cluster_id              = var.create_new_oke_cluster ? module.oci-oke[0].cluster.id : var.existent_oke_cluster_id
  #  cluster_id              = oci_containerengine_cluster.oke_cluster[0].id
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#  Add var to choose between an existing Articat and an inline one

resource "oci_devops_deploy_artifact" "test_deploy_values_yaml_artifact" {
  argument_substitution_mode = var.argument_substitution_mode
  deploy_artifact_type       = "GENERIC_FILE"
  project_id                 = oci_devops_project.test_project.id
  display_name               = "values.yaml"

  deploy_artifact_source {
    deploy_artifact_source_type = var.deploy_artifact_source_type #INLINE,GENERIC_ARTIFACT_OCIR
    base64encoded_content       = replace(file("${path.module}/manifest/values.yaml"), "<NODE_SERVICE_REPO>", "${local.ocir_docker_repository}/${local.ocir_namespace}/${oci_artifacts_container_repository.test_container_repository.display_name}")
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_devops_deploy_pipeline" "test_deploy_pipeline" {
  #Required
  project_id   = oci_devops_project.test_project.id
  description  = var.deploy_pipeline_description
  display_name = var.deploy_pipeline_display_name

  deploy_pipeline_parameters {
    items {
      name          = var.deploy_pipeline_deploy_pipeline_parameters_items_name
      default_value = var.deploy_pipeline_deploy_pipeline_parameters_items_default_value
      description   = var.deploy_pipeline_deploy_pipeline_parameters_items_description
    }
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_devops_deploy_artifact" "test_deploy_helm_artifact" {
  project_id = oci_devops_project.test_project.id
  display_name = "Helm Repo"
  deploy_artifact_type = "HELM_CHART"
  argument_substitution_mode = "NONE"
  deploy_artifact_source {
    deploy_artifact_source_type = "HELM_CHART"
    chart_url = "oci://${local.ocir_docker_repository}/${local.ocir_namespace}/${oci_artifacts_container_repository.test_container_repository_helm.display_name}/${var.deploy_helm_chart_name}"
    deploy_artifact_version = "0.1.0-$${BUILDRUN_HASH}"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_devops_deploy_stage" "test_helm_deploy_stage" {
  #Required
  deploy_pipeline_id = oci_devops_deploy_pipeline.test_deploy_pipeline.id
  deploy_stage_predecessor_collection {
    #Required
    items {
      #Required
      id = oci_devops_deploy_pipeline.test_deploy_pipeline.id
    }
  }

  description  = var.deploy_stage_description
  display_name = var.deploy_stage_display_name
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }

  deploy_stage_type = var.deploy_stage_deploy_stage_type
  release_name = var.deploy_stage_helm_release_name
  values_artifact_ids = [oci_devops_deploy_artifact.test_deploy_values_yaml_artifact.id]
  helm_chart_deploy_artifact_id = oci_devops_deploy_artifact.test_deploy_helm_artifact.id
  oke_cluster_deploy_environment_id = oci_devops_deploy_environment.test_environment.id
}
