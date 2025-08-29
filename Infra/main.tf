provider "aws" {
  region = "ap-south-1" # change to your region
}

resource "aws_instance" "node_app" {
  ami           = "ami-0f5ee92e2d63afc18"   # Ubuntu 22.04 (ap-south-1)
  instance_type = "t2.micro"
  key_name      = "my-key"                  # <-- your AWS key pair name

  security_groups = [aws_security_group.node_sg.name]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io

    # Enable and start Docker
    systemctl enable docker
    systemctl start docker

    # Add ubuntu user to Docker group
    usermod -aG docker ubuntu

    # Avoid multiple containers: stop & remove any old one
    docker stop node_app || true
    docker rm node_app || true

    # Login to Docker Hub
    echo "${var.docker_pass}" | docker login -u "${var.docker_user}" --password-stdin

    # Pull and run the latest image
    docker pull ${var.image_name}:${var.image_tag}
    docker run -d --name node_app -p 80:3000 ${var.image_name}:${var.image_tag}
  EOF

  tags = {
    Name = "NodeApp-Instance"
  }
}

resource "aws_security_group" "node_sg" {
  name        = "node-sg"
  description = "Allow HTTP"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
