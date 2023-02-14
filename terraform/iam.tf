resource "aws_iam_role" "reader_lambda_role" {
    name_prefix = "role-${var.reader_lambda_name}"
    assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "sts:AssumeRole"
                ],
                "Principal": {
                    "Service": [
                        "lambda.amazonaws.com"
                    ]
                }
            }
        ]
    }
    EOF
}

resource "aws_iam_role" "scheduler_lambda_role" {
    name_prefix = "role-${var.scheduler_lambda_name}"
    assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "sts:AssumeRole"
                ],
                "Principal": {
                    "Service": [
                        "lambda.amazonaws.com"
                    ]
                }
            }
        ]
    }
    EOF
}

data "aws_iam_policy_document" "s3_reader_document" {
  statement {

    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.code_bucket.arn}/*",
      "${aws_s3_bucket.data_bucket.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "s3_scheduler_document" {
  statement {

    actions = ["s3:*"]


    resources = [
      "${aws_s3_bucket.code_bucket.arn}/*",
      "${aws_s3_bucket.data_bucket.arn}/*",
    ]
  }
  statement {
          actions =["s3:ListBucket"]
          resources =[
            "${aws_s3_bucket.code_bucket.arn}",
            "${aws_s3_bucket.data_bucket.arn}",
          ]
      }
}
data "aws_iam_policy_document" "cw_reader_document" {
  statement {

    actions = [ "logs:CreateLogGroup" ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {

    actions = [ "logs:CreateLogStream", "logs:PutLogEvents" ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.reader_lambda_name}:*"
    ]
  }
}

data "aws_iam_policy_document" "cw_scheduler_document" {
  statement {

    actions = [ "logs:CreateLogGroup" ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {

    actions = [ "logs:CreateLogStream", "logs:PutLogEvents" ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.scheduler_lambda_name}:*"
    ]
  }
}



resource "aws_iam_policy" "s3_reader_policy" {
    name_prefix = "s3-policy-${var.reader_lambda_name}"
    policy = data.aws_iam_policy_document.s3_reader_document.json
}


resource "aws_iam_policy" "cw_reader_policy" {
    name_prefix = "cw-policy-${var.reader_lambda_name}"
    policy = data.aws_iam_policy_document.cw_reader_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_s3_reader_policy_attachment" {
    role = aws_iam_role.reader_lambda_role.name
    policy_arn = aws_iam_policy.s3_reader_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_cw_reader_policy_attachment" {
    role = aws_iam_role.reader_lambda_role.name
    policy_arn = aws_iam_policy.cw_reader_policy.arn
}

resource "aws_iam_policy" "s3_scheduler_policy" {
    name_prefix = "s3-policy-${var.scheduler_lambda_name}"
    policy = data.aws_iam_policy_document.s3_scheduler_document.json
}


resource "aws_iam_policy" "cw_scheduler_policy" {
    name_prefix = "cw-policy-${var.scheduler_lambda_name}"
    policy = data.aws_iam_policy_document.cw_scheduler_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_s3_scheduler_policy_attachment" {
    role = aws_iam_role.scheduler_lambda_role.name
    policy_arn = aws_iam_policy.s3_scheduler_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_cw_scheduler_policy_attachment" {
    role = aws_iam_role.scheduler_lambda_role.name
    policy_arn = aws_iam_policy.cw_scheduler_policy.arn
}