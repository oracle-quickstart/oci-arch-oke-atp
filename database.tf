## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_database_autonomous_database" "ATP_database" {
  count                    = var.deploy_ATP ? 1 : 0
  admin_password           = var.ATP_password
  compartment_id           = var.compartment_ocid
  cpu_core_count           = var.ATP_database_cpu_core_count
  data_storage_size_in_tbs = var.ATP_database_data_storage_size_in_tbs
  db_name                  = var.ATP_database_db_name
  db_version               = var.ATP_database_db_version
  display_name             = var.ATP_database_display_name
  freeform_tags            = var.ATP_database_freeform_tags
  license_model            = var.ATP_database_license_model  
  is_data_guard_enabled    = var.ATP_data_guard_enabled
}

resource "random_string" "wallet_password" {
  length  = 16
  special = true
}

resource "oci_database_autonomous_database_wallet" "ATP_database_wallet" {
  count                  = var.deploy_ATP ? 1 : 0
  autonomous_database_id = oci_database_autonomous_database.ATP_database[count.index].id
  password               = random_string.wallet_password.result
  base64_encode_content  = "true"
}