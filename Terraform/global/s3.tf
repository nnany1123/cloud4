# 웹사이트용 S3

resource "aws_s3_bucket" "devs3_bucket" {
    bucket = "devs3.${var.bucket_name}"
    acl = "public-read"
    policy = templatefile("templates/s3-policy.json", {bucket = "devs3.${var.bucket_name}"})#EOS로 따로 지정해야할수도..

    cors_rule {
        allowed_headers = ["Authorization", "Content-Length"]
        allowed_methods = ["GET", "POST"]
        allowed_origins = ["https://devs3.${var.domain_name}"]
        max_age_seconds = 3000
    }

    website {
        index_document = "index.html"
        error_document = "404.html"
    }

    tags = var.common_tags
}

# devs3가 아닌것을 devs3로 리디렉션

resource "aws_s3_bucket" "root_bucket" {
    bucket = var.bucket_name
    acl = "public-read"
    policy = templatefile("templates/s3-policy.json", {bucket = var.bucket_name})

    website {
        redirect_all_requests_to = "https://devs3.${var.domain_name}"
    }

    tags = var.common_tags
}
# 특정 위치에 존재하는 S3 객체 업로드(index.html)
#resource "aws_s3_bucket_object" "index-error" {
#    for_each = fileset(var.upload_directory, "**/*.*")
#    bucket = aws_s3_bucket.devs3_bucket.id
#    acl = "public-read"
#    key = replace(each.value, var.upload_directory, "")
#    source = "${var.upload_directory}${each.value}"
#    etag = filemd5("${var.upload_directory}${each.value}")

#}