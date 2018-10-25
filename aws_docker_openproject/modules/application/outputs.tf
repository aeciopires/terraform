output "security_group" {
    value = "${join(", ", aws_security_group.instance.*.id)}"
}

output "web_ip" {
    value = "${join(", ", aws_instance.openproject.*.public_ip)}"
}
