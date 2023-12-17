module "glue_db" {
  source      = "./modules/cur-glue-database"
  environment = var.environment
}

module "athena_for_grafana" {
  source                     = "./modules/cur-athena"
  environment                = var.environment
  billing_report_bucket_name = module.glue_db.billing_report_bucket_name
  glue_catalog_database_name = module.glue_db.glue_catalog_database_name

  create_secret = var.create_secret
  secret_name   = var.secret_name
}
