##########################
### AWS Lambda for stopping CloudFront distribution
##########################

data "aws_iam_policy_document" "lambda_disable_cloudfront_iam_policy_doc" {
  statement {
    sid    = "allowLambdaDisableCloudFront"
    effect = "Allow"
    actions = [
      "cloudfront:ListDistributions",
      "cloudfront:GetDistributionConfig",
      "cloudfront:UpdateDistribution"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_disable_cloudfront_iam_policy" {
  provider = aws.main
  name     = "lambda_disable_cloudfront"
  policy   = data.aws_iam_policy_document.lambda_disable_cloudfront_iam_policy_doc.json
}



data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_disable_cloudfront" {
  provider            = aws.main
  name                = "lambda_disable_cloudfront"
  path                = "/system/"
  assume_role_policy  = data.aws_iam_policy_document.lambda_assume_role_policy.json
  managed_policy_arns = [aws_iam_policy.lambda_disable_cloudfront_iam_policy.arn]
}

data "archive_file" "lambda_disable_cloudfront" {
  type        = "zip"
  source_file = "disablecloudfront.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "lambda_disable_cloudfront" {
  provider      = aws.main
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_disable_cloudfront"
  role          = aws_iam_role.lambda_disable_cloudfront.arn
  handler       = "disablecloudfront.lambda_handler"
  runtime       = "python3.11"
  timeout       = 10

}

resource "aws_lambda_permission" "with_sns" {
  provider      = aws.main
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_disable_cloudfront.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.aws_budgets_100_sns.arn
}

##########################
### AWS SNS for triggering Lambda
##########################
resource "aws_sns_topic" "aws_budgets_100_sns" {
  provider = aws.main
  name = "aws_budgets_100_sns"
  tags = merge(
    local.common_tags,
    {
      "Name"           = lower(join("-", compact([local.config.resources_tags.customer_short, local.config.resources_tags.project_short,local.config.global.region_id, "budget","sns"])))
      "Category"       = "budget"
      "Criticality"    = "true"
      "Location"       = "${local.config.global.region_id}"
      "Environment"    = "PROD"
    }
  )
}


resource "aws_sns_topic_subscription" "aws_budgets_100_sns_lambda" {
  provider = aws.main
  topic_arn = aws_sns_topic.aws_budgets_100_sns.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda_disable_cloudfront.arn
}

##########################
### AWS budgets
##########################
resource "aws_budgets_budget" "budget-alert" {
  provider = aws.main
  name              = lower(join("-", compact([local.config.resources_tags.customer_short, local.config.resources_tags.project_short,local.config.global.region_id, "budget","overview"])))
  budget_type       = "COST"
  limit_amount      = local.config.aws_budget.budget_limit
  limit_unit        = local.config.aws_budget.budget_currency
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = local.config.aws_budget.budget_notification_emails
  }
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 85
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = local.config.aws_budget.budget_notification_emails
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = local.config.aws_budget.budget_notification_emails
    subscriber_sns_topic_arns  = [aws_sns_topic.aws_budgets_100_sns.arn]
  }
}

