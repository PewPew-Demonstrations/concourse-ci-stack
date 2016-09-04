resource "aws_route53_record" "www" {
  zone_id = "${var.hosted_zone_id}"
  name = "${var.domain}"
  type = "A"

  alias {
    name = "${var.elb_address}"
    zone_id = "${var.elb_zone_id}"
    evaluate_target_health = true
  }
}
