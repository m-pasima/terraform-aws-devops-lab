provider "aws" {
  region = "eu-west-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


resource "aws_security_group" "test_sg" {
  name        = "test-servers-sg"
  description = "Allow HTTP access to apps"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 8080
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
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

module "jenkins" {
  source            = "../modules/ec2"
  ami               = "ami-05f861f26432a5eed"
  instance_type     = "t2.medium"
  subnet_id         =  data.aws_subnets.default_subnets.ids[0]
  security_group_id = aws_security_group.test_sg.id
  user_data_path    = "../scripts/jenkins.sh"
  instance_name     = "jenkins-server"
  key_name = "maven"

}
module "sonarqube" {
  source            = "../modules/ec2"
  ami               = "ami-0fc32db49bc3bfbb1"
  instance_type     = "t2.medium"
  subnet_id         =  data.aws_subnets.default_subnets.ids[1]
  security_group_id = aws_security_group.test_sg.id
  user_data_path    = "../scripts/sonarqube.sh"
  instance_name     = "sonarqube-server"
  key_name = "maven"

}
module "nexus" {
  source            = "../modules/ec2"
  ami               = "ami-0fc32db49bc3bfbb1"
  instance_type     = "t2.medium"
  subnet_id         =  data.aws_subnets.default_subnets.ids[2]
  security_group_id = aws_security_group.test_sg.id
  user_data_path    = "../scripts/nexus.sh"
  instance_name     = "nexus-server"
  key_name = "maven"

}
module "tomcat" {
  source            = "../modules/ec2"
  ami               = "ami-0fc32db49bc3bfbb1"
  instance_type     = "t2.micro"
  subnet_id         =  data.aws_subnets.default_subnets.ids[0]
  security_group_id = aws_security_group.test_sg.id
  user_data_path    = "../scripts/tomcat.sh"
  instance_name     = "tomcat-server"
  key_name = "maven"

}
