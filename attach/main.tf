resource "aws_elb_attachment" "foo" {
  count = "${var.attachment_count}"
  elb = "${var.elb_id}"
  instance = "${var.instance_ids[count.index]}"
}