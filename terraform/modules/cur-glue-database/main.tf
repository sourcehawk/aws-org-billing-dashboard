# --------------------------------------------------------
# S3 Bucket: To store cost & usage reports
# --------------------------------------------------------

resource "aws_s3_bucket" "billing_report_bucket" {
  bucket_prefix = "cur-${var.environment}-"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "allow_billing" {
  bucket = aws_s3_bucket.billing_report_bucket.id
  policy = data.aws_iam_policy_document.allow_billing.json
}

# --------------------------------------------------------
# AWS Cost and Usage Report (CUR): Formatted for Athena
# --------------------------------------------------------

resource "aws_cur_report_definition" "billing_report" {
  report_name       = local.report_name
  time_unit         = "HOURLY"
  format            = "Parquet"
  compression       = "Parquet"
  report_versioning = "OVERWRITE_REPORT"

  s3_bucket = aws_s3_bucket.billing_report_bucket.bucket
  s3_region = aws_s3_bucket.billing_report_bucket.region
  s3_prefix = local.report_s3_prefix

  additional_schema_elements = ["RESOURCES"]
  additional_artifacts       = ["ATHENA"]

  refresh_closed_reports = true
}

# --------------------------------------------------------
# AWS Glue Crawler: To crawl the cost & usage reports
# --------------------------------------------------------

resource "aws_glue_crawler" "cost_and_usage_report_crawler" {
  name          = "cur-crawler-${var.environment}"
  database_name = aws_glue_catalog_database.cost_and_usage_report_db.name
  role          = aws_iam_role.crawler_role.name

  s3_target {
    path = "s3://${aws_s3_bucket.billing_report_bucket.id}/${local.report_s3_prefix}/cost_and_usage_reports/"
    exclusions = [
      "**.json",
      "**.yml",
      "**.sql",
      "**.csv",
      "**.gz",
      "**.zip",
    ]
  }
  schema_change_policy {
    delete_behavior = "DELETE_FROM_DATABASE"
    update_behavior = "UPDATE_IN_DATABASE"
  }
}

resource "aws_iam_role" "crawler_role" {
  name               = "cur-crawler-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.crawler_assume_permission.json
}

resource "aws_iam_role_policy_attachment" "glue_service_role_policy_attach" {
  policy_arn = data.aws_iam_policy.glue_service_role_policy.arn
  role       = aws_iam_role.crawler_role.name
}

resource "aws_iam_role_policy" "crawler" {
  name   = "cur-crawler-policy-${var.environment}"
  role   = aws_iam_role.crawler_role.name
  policy = data.aws_iam_policy_document.crawler_iam_policy.json
}

# ----------------------------------------------
# AWS Glue Catalog: Our database and tables
# ----------------------------------------------

resource "aws_glue_catalog_database" "cost_and_usage_report_db" {
  name        = lower("cur-db-${var.environment}")
  description = "Contains CUR data based on contents from the S3 bucket '${aws_s3_bucket.billing_report_bucket.bucket}'"
  tags        = { "GrafanaDataSource" = "true" }
}

resource "aws_glue_catalog_table" "cur_report_status_table" {
  name          = "cost_and_usage_data_status"
  database_name = aws_glue_catalog_database.cost_and_usage_report_db.name
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.billing_report_bucket.id}/${local.report_s3_prefix}/cost_and_usage_data_status/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }
    columns {
      name = "status"
      type = "string"
    }
  }
  depends_on = [aws_glue_catalog_database.cost_and_usage_report_db]
  lifecycle {
    ignore_changes = [
      parameters,
    ]
  }
}

# --------------------------------------------------------
# Additional AWS Glue Table: To map account IDs to names
# --------------------------------------------------------

resource "aws_s3_object" "account_mappings" {
  bucket         = aws_s3_bucket.billing_report_bucket.id
  key            = "${local.account_table_name}/account_mappings.csv"
  content_base64 = base64encode(local.csv_content)
  content_type   = "csv"
  etag           = md5(local.csv_content)

  force_destroy = true
}

resource "aws_glue_catalog_table" "account_mappings" {
  name          = local.account_table_name
  database_name = aws_glue_catalog_database.cost_and_usage_report_db.name
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.billing_report_bucket.id}/${local.account_table_name}/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "LazySimpleSerDe"
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim"          = ","
        "serialization.format" = 1 # 0 for non-escaped, 1 for escaped (default)
      }
    }

    columns {
      name = "account_id"
      type = "string"
    }

    columns {
      name = "account_name"
      type = "string"
    }
  }

  parameters = {
    classification = "csv"
    delimiter      = ","
  }

  depends_on = [aws_s3_object.account_mappings]
}

# ---------------------------------------------------
# AWS Lambda: To initialize the crawler on new files
# ---------------------------------------------------

resource "aws_cloudwatch_log_group" "default" {
  name              = "/aws/lambda/${local.crawler_lambda_name}"
  retention_in_days = 90
}

resource "aws_lambda_permission" "allow_s3_bucket" {
  statement_id   = "AllowS3ToInvokeLambda-${var.environment}"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.cur_initializer.function_name
  source_account = data.aws_caller_identity.current.account_id
  principal      = "s3.amazonaws.com"
  source_arn     = aws_s3_bucket.billing_report_bucket.arn
}

resource "aws_iam_role" "cur_initializer_lambda_executor" {
  name               = "cur-lambda-executor-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.crawler_lambda_assume.json
}

resource "aws_iam_role_policy" "crawler_policy" {
  name   = "cur-lambda-executor-policy-${var.environment}"
  role   = aws_iam_role.cur_initializer_lambda_executor.name
  policy = data.aws_iam_policy_document.crawler_lambda_policy.json
}

resource "aws_lambda_function" "cur_initializer" {
  function_name                  = local.crawler_lambda_name
  filename                       = data.archive_file.cur_initializer_lambda_code.output_path
  handler                        = "${local.crawler_lambda_name}.lambda_handler"
  runtime                        = "python3.10"
  reserved_concurrent_executions = 1
  role                           = aws_iam_role.cur_initializer_lambda_executor.arn
  timeout                        = 30
  source_code_hash               = data.archive_file.cur_initializer_lambda_code.output_base64sha256
  environment {
    variables = {
      CRAWLER_NAME = "${aws_glue_crawler.cost_and_usage_report_crawler.name}"
    }
  }
  depends_on = [aws_cloudwatch_log_group.default]
}

resource "aws_s3_bucket_notification" "cur_initializer_lambda_trigger" {
  bucket = aws_s3_bucket.billing_report_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.cur_initializer.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "${local.report_s3_prefix}/"
    filter_suffix       = ".parquet"
  }

  depends_on = [
    aws_lambda_permission.allow_s3_bucket,
    aws_s3_bucket_policy.allow_billing,
  ]
}
