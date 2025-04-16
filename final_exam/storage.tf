resource "aws_s3_bucket" "vault" {
  bucket = "patel-2657-bucket"

  tags = {
    "Name"  = "Patel Vault"
    "Owner" = "Rishikumar Patel"
    "ID"    = "8972657"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.vault.id

  versioning_configuration {
    status = "Enabled"
  }
}
