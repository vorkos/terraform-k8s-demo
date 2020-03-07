terraform {
    backend "s3" {
    bucket = "bm-demo-tf"
    key    = "state/"
    region = "us-east-2"
    }
}
