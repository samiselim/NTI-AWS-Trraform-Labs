data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "src"
  output_path = "lambdafile.zip"
}

resource "aws_lambda_function" "func" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "terminateServers"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "terminateServers.lambda_handler" 
  runtime       = "python3.8"        
  timeout       = 300 
}
resource "aws_iam_role_policy_attachment" "lambda_ec2_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"  
}
