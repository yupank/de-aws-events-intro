resource "aws_lambda_function" "s3_file_reader" {
  function_name = "${var.reader_lambda_name}"
  s3_bucket = aws_s3_bucket.code_bucket.bucket
  s3_key = "s3_file_reader/reader_function.zip"
  role = aws_iam_role.reader_lambda_role.arn
  handler = "reader.lambda_handler"
  runtime = "python3.9"
  #filename = "reader_function.zip"
  source_code_hash = filebase64sha256("reader_function.zip")
}

resource "aws_lambda_function" "s3_scheduler" {
  function_name = "${var.scheduler_lambda_name}"
  s3_bucket = aws_s3_bucket.code_bucket.bucket
  s3_key = "s3_scheduler/scheduler_function.zip"
  role = aws_iam_role.scheduler_lambda_role.arn
  handler = "scheduler.lambda_handler"
  runtime = "python3.9"
  #filename = "scheduler_function.zip"
  source_code_hash = filebase64sha256("scheduler_function.zip")
}

resource "aws_lambda_permission" "allow_s3_reader" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_file_reader.function_name
  principal = "s3.amazonaws.com"
  source_arn = aws_s3_bucket.data_bucket.arn
  source_account = data.aws_caller_identity.current.account_id
}

resource "aws_lambda_permission" "allow_s3_scheduler" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_scheduler.function_name
  principal = "s3.amazonaws.com"
  source_arn = aws_s3_bucket.data_bucket.arn
  source_account = data.aws_caller_identity.current.account_id
}