
resource "aws_iam_user" "s3_uploader" {
  provider = aws.main
  name = "s3_uploader"
  
  lifecycle {
    ignore_changes = [
      tags
    ]
  }

}

resource "aws_iam_access_key" "s3_uploader_ak" {
  provider = aws.main
  user = aws_iam_user.s3_uploader.name
}



resource "aws_iam_policy" "s3_uploader_iam_policy" {
  provider = aws.main
  name   = "PubliiS3AccessPolicy"
  policy = data.aws_iam_policy_document.s3_uploader_iam_policy.json
}

data "aws_iam_policy_document" "s3_uploader_iam_policy" {
  statement {
    sid       = "allowpubliiaccesss3bucket"
    effect    = "Allow"
    actions   = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.s3_web_bucket.arn}/*",
      "${aws_s3_bucket.s3_web_bucket.arn}"
    ]
  }
}

resource "aws_iam_user_policy_attachment" "s3_uploader_iam_user_policy_attach" {
  provider = aws.main
  user       = aws_iam_user.s3_uploader.name
  policy_arn = aws_iam_policy.s3_uploader_iam_policy.arn
}
