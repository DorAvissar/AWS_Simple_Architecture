resource "aws_instance" "ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private-subnet-1.id
  security_groups             = [aws_security_group.ec2.id]
  associate_public_ip_address = false
  user_data                   = <<-EOL
  #!/bin/bash -xe
  sudo yum update -y
  sudo yum -y install docker
  sudo service docker start
  sudo usermod -a -G docker ec2-user
  sudo chmod 666 /var/run/docker.sock
  docker pull nginx
  docker tag nginx my-nginx
  docker run --rm --name nginx-server -d -p 80:80 -t my-nginx
  EOL

  tags = {
    Name = "${var.ec2_instance_name}-instance"
  }
}
