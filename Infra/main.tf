provider "aws" {
  region     = "ap-south-1"              # Change if needed
  access_key = "AKIARCTMIVVTZEPERM2M"     # Hardcoded creds (not recommended)
  secret_key = "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"
}

resource "aws_instance" "shopingkaro" {
  ami           = "ami-0f918f7e67a3323f0" # Ubuntu 22.04 LTS AMI for ap-south-1
  instance_type = "t2.micro"
  key_name      = "ubuntutest"     # Must exist in AWS

  tags = {
    Name = "ShopingKaro-App"
  }

  # Install Docker and run your container
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              docker login -u "YOUR_DOCKER_USERNAME" -p "YOUR_DOCKER_PASSWORD"
              docker pull YOUR_DOCKER_USERNAME/shopingkaro:latest
              docker run -d -p 80:3000 YOUR_DOCKER_USERNAME/shopingkaro:latest
              EOF
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
