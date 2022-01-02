resource "aws_route53_zone" "main" {
    name = var.domain_name
    tags = var.common_tags
}

resource "aws_route53_record" "root-a" {
    zone_id = aws_route53_zone.main.zone_id
    name = var.domain_name
    type = "A"

    alias {
        name = aws_cloudfront_distribution.root_s3_distribution.domain_name
        zone_id = aws_cloudfront_distribution.root_s3_distribution.hosted_zone_id
        evaluate_target_health = false
    }
}

resource "aws_route53_record" "devs3-a" {
    zone_id = aws_route53_zone.main.zone_id
    name = "devs3.${var.domain_name}"
    type = "A"

    alias {
        name = aws_cloudfront_distribution.devs3_s3_distribution.domain_name
        zone_id = aws_cloudfront_distribution.devs3_s3_distribution.hosted_zone_id
        evaluate_target_health = false
    }
}

/* data "aws_lb" "alb" {
    name = "014f04b3-jenkins-ingress-8202"
}

resource "aws_route53_record" "www-a" {
    zone_id = aws_route53_zone.main.zone_id
    name = "www.${var.domain_name}"
    type = "A"

    alias {
        name = data.aws_lb.alb.dns_name
        zone_id = data.aws_lb.alb.zone_id
        evaluate_target_health = false
    }
} */