## Copyright (c) 2022, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_devops_build_pipeline" "test_build_pipeline" {
  project_id = oci_devops_project.test_project.id

  description  = var.build_pipeline_description
  display_name = var.build_pipeline_display_name
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }

  build_pipeline_parameters {
        items {
            name = "USER_AUTH_TOKEN"
            default_value = var.oci_user_authtoken
            description = "User auth token to push helm packages."
        }
        items {
            name = "HELM_REPO_USER"
            default_value = var.oci_username
            description = "User to push helm packages."
        }
        items {
            name = "HELM_REPO_URL"
            default_value = "oci://${local.ocir_docker_repository}/${local.ocir_namespace}/devops-helm-${random_id.tag.hex}"
            description = "Helm repo URL to push helm packages."
        }
        items {
            name = "HELM_REPO"
            default_value = "${local.ocir_docker_repository}"
            description = "Helm repo name"
        }
    }
}

resource "oci_devops_build_run" "test_build_run" {
    depends_on = [module.oci-oke]
    count = var.execute_build_pipeline ? 1 : 0
    build_pipeline_id = oci_devops_build_pipeline.test_build_pipeline.id
    display_name = "devops_build_run_${random_id.tag.hex}"

    defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }

    build_run_arguments {
        items {
            name = "USER_AUTH_TOKEN"
            value = var.oci_user_authtoken
        }
        
        items {
            name = "HELM_REPO_USER"
            value = var.oci_username
        }

        items {
            name = "HELM_REPO_URL"
            value = "oci://${local.ocir_docker_repository}/${local.ocir_namespace}/devops-helm-${random_id.tag.hex}"
        }

        items {
            name = "HELM_REPO"
            value = "${local.ocir_docker_repository}"
        }
    }
}



