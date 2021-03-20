provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_s3_bucket" "tf_files"{
  bucket = "jamjamtfiles20191118"
  acl    = "private"
}
