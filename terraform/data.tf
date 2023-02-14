data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "archive_file" "reader_lambda" {
  type        = "zip"
  source_file = "${path.module}/../src/file_reader/reader.py"
  output_path = "${path.module}/reader_function.zip"
}

data "archive_file" "scheduler_lambda" {
  type        = "zip"
  source_file = "${path.module}/../src/event_scheduler/scheduler.py"
  output_path = "${path.module}/scheduler_function.zip"
}

