# Font:
# https://www.terraform.io/docs/providers/aws/index.html
# http://blog.aeciopires.com/conhecendo-o-terraform/
# https://blog.gruntwork.io/an-introduction-to-terraform-f17df9c6d180
# https://aws.amazon.com/blogs/apn/terraform-beyond-the-basics-with-aws/
# https://read.acloud.guru/building-a-highly-scalable-resilient-rest-api-with-terraform-go-and-aws-94377b90fd24
# https://terraformbook.com
# http://www.steamhaus.co.uk/wp-content/uploads/2017/03/Infrastructure-as-Code.pdf
# https://www.guug.de/veranstaltungen/ffg2016/slides/Martin%20Sch%C3%BCtte%20-%20Terraform,%20Config%20Management%20for%20Cloud%20Services.pdf
#------------------------------------------------

# Create Instance 1
resource "aws_instance" "ci-server" {
ami = "${var.operating_system}"
  instance_type = "${var.machine_type}"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  tags {
    Name = "livro, terraform, test"
  }
}

# Create Instance 2
resource "aws_instance" "code" {
ami = "${var.operating_system}"
  instance_type = "${var.machine_type}"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  tags {
    Name = "livro, terraform, test"
  }
}

# Create Instance 3
resource "aws_instance" "node-ubuntu" {
ami = "${var.operating_system}"
  instance_type = "${var.machine_type}"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  tags {
    Name = "livro, terraform, test"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
