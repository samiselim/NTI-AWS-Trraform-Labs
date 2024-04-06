provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "random_string" "random" {
  length = 6
  special = false
  upper = false
} 

resource "aws_s3_bucket" "bucket" {
  bucket = "sami-${random_string.random.result}"
  force_destroy = true
}


resource "aws_s3_bucket_website_configuration" "blog" {
  bucket = aws_s3_bucket.bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_object" "file1" {
  bucket = aws_s3_bucket.bucket.id
  key    = "index.html"
  source = "index.html"  
  acl    = "private"  
}

resource "aws_s3_bucket_object" "file2" {
  bucket = aws_s3_bucket.bucket.id
  key    = "error.html"
  source = "error.html"  
  acl    = "private"  
}