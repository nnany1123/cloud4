output "aws_acm_arn" {
    value = aws_acm_certificate.ssl_certificate.arn
}

output "aws_route53_zone" {
    value = aws_route53_zone.main.zone_id
}