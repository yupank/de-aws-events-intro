resource "aws_s3_bucket" "code_bucket" {
    bucket = "nc-yp-de-code-1"
}

resource "aws_s3_bucket" "data_bucket" {
    bucket = "nc-yp-de-data-1"
}

resource "aws_s3_object" "reader_lambda_code" {
  bucket = aws_s3_bucket.code_bucket.bucket
  key = "s3_file_reader/reader_function.zip"
  source = "${path.module}/../reader_function.zip"
}

resource "aws_s3_object" "scheduler_lambda_code" {
  bucket = aws_s3_bucket.code_bucket.bucket
  key = "s3_scheduler/scheduler_function.zip"
  source = "${path.module}/../scheduler_function.zip"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.data_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_file_reader.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_reader]
}