# ----------------------------------------------
# S3 bucket: To store athena query results
# ----------------------------------------------

resource "aws_s3_bucket" "queries_athena" {
  bucket_prefix = "athena-queries-${var.environment}-"
  force_destroy = true

  tags = {
    "GrafanaDataSource" = "true"
    "Name" = "athena-queries-${var.environment}"
  }
}


# ----------------------------------------------
# Athena Workgroup: For grafana
# ----------------------------------------------

resource "aws_athena_workgroup" "athena_workgroup" {
  name          = "athena-workgroup-${var.environment}"
  state         = "ENABLED"
  force_destroy = true
  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.queries_athena.bucket}/"
    }
  }
  tags = {
    "GrafanaDataSource" = "true"
  }
}

resource "aws_iam_policy" "athena_access" {
  name        = "athena-access-${var.environment}"
  description = "Policy that allows access to athena, s3 athena query bucket and glue"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "athena:GetDatabase",
            "athena:GetDataCatalog",
            "athena:GetTableMetadata",
            "athena:ListDatabases",
            "athena:ListDataCatalogs",
            "athena:ListTableMetadata",
            "athena:ListWorkGroups"
          ],
          "Resource" : [
            "*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "athena:GetQueryExecution",
            "athena:GetQueryResults",
            "athena:GetWorkGroup",
            "athena:StartQueryExecution",
            "athena:StopQueryExecution"
          ],
          "Resource" : [
            "*"
          ],
          "Condition" : {
            "Null" : {
              "aws:ResourceTag/GrafanaDataSource" : "false"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "glue:GetDatabase",
            "glue:GetDatabases",
            "glue:GetTable",
            "glue:GetTables",
            "glue:GetPartition",
            "glue:GetPartitions",
            "glue:BatchGetPartition"
          ],
          "Resource" : [
            "*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:ListMultipartUploadParts",
            "s3:AbortMultipartUpload",
            "s3:CreateBucket",
            "s3:PutObject",
            "s3:PutBucketPublicAccessBlock"
          ],
          "Resource" : [
            "${aws_s3_bucket.queries_athena.arn}",
            "${aws_s3_bucket.queries_athena.arn}/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:ListBucket",
            "s3:GetBucketLocation"
          ],
          "Resource" : [
            "${data.aws_s3_bucket.athena_billing_report_bucket.arn}",
            "${data.aws_s3_bucket.athena_billing_report_bucket.arn}/*"
          ]
        }
      ]
    }
  )
}


# ----------------------------------------------
# AWS IAM: User for grafana (programmatic access)
# ----------------------------------------------

resource "aws_iam_user" "athena_user" {
  count = var.create_secret ? 1 : 0
  name  = "grafana-athena-user-${var.environment}"
}

resource "aws_iam_user_policy_attachment" "athena_user_policy_attachment" {
  count      = var.create_secret ? 1 : 0
  user       = aws_iam_user.athena_user[0].name
  policy_arn = aws_iam_policy.athena_access.arn
}

resource "aws_iam_access_key" "athena_user_access_key" {
  count = var.create_secret ? 1 : 0
  user  = aws_iam_user.athena_user[0].name
}


# ----------------------------------------------
# AWS Secrets Manager: Athena datasource for grafana
# ----------------------------------------------

resource "aws_secretsmanager_secret" "athena_user_access_key_secret" {
  count       = var.create_secret ? 1 : 0
  name        = var.secret_name
  description = "Credentials for the Athena Datasource containing billing data from ${var.environment} account"
}

resource "aws_secretsmanager_secret_version" "athena_user_access_key_secret_version" {
  count     = var.create_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.athena_user_access_key_secret[0].id
  secret_string = jsonencode({
    "access_key_id"     = aws_iam_access_key.athena_user_access_key[0].id
    "secret_access_key" = aws_iam_access_key.athena_user_access_key[0].secret
    "workgroup"         = aws_athena_workgroup.athena_workgroup.name
    "catalog"           = "AwsDataCatalog"
    "database"          = var.glue_catalog_database_name
    "default_region"    = "us-east-1"
  })
}
