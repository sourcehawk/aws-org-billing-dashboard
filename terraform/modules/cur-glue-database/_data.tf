data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_organizations_organization" "current" {}

data "aws_iam_policy_document" "allow_billing" {
  statement {
    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketPolicy",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.billing_report_bucket.arn}",
      "${aws_s3_bucket.billing_report_bucket.arn}/*",
    ]

    principals {
      type        = "Service"
      identifiers = ["billingreports.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"

      values = [
        "arn:aws:cur:us-east-1:${data.aws_caller_identity.current.id}:definition/*",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
        data.aws_caller_identity.current.id,
      ]
    }
  }
}

data "aws_iam_policy_document" "crawler_assume_permission" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "crawler_iam_policy" {
  statement {
    sid       = "S3DecryptPermission"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["*"]
  }

  statement {
    sid    = "GluePermission"
    effect = "Allow"
    actions = [
      "glue:ImportCatalogToGlue",
      "glue:GetDatabase",
      "glue:UpdateDatabase",
      "glue:CreateTable",
      "glue:UpdateTable",
      "glue:UpdatePartition"
    ]

    resources = [
      aws_glue_catalog_database.cost_and_usage_report_db.arn,
      "arn:${data.aws_partition.current.partition}:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:catalog",
      "arn:${data.aws_partition.current.partition}:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${aws_glue_catalog_database.cost_and_usage_report_db.name}/*",
    ]
  }

  statement {
    sid    = "CloudWatchPermission"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:logs:*:*:*"
    ]
  }

  statement {
    sid    = "S3Permission"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "${aws_s3_bucket.billing_report_bucket.arn}",
      "${aws_s3_bucket.billing_report_bucket.arn}/*",
    ]
  }
}

data "aws_iam_policy" "glue_service_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

data "archive_file" "cur_initializer_lambda_code" {
  type        = "zip"
  source_dir  = "${path.module}/crawler"
  output_path = "${path.module}/${local.crawler_lambda_name}.zip"
}

data "aws_iam_policy_document" "crawler_lambda_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "crawler_lambda_policy" {
  statement {
    sid    = "CloudWatch"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
    ]
    resources = ["${aws_cloudwatch_log_group.default.arn}:*"]
  }

  statement {
    sid    = "Glue"
    effect = "Allow"
    actions = [
      "glue:StartCrawler",
    ]
    resources = ["*"]
  }
}
