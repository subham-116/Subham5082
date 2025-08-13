//vpc
resource "aws_vpc" "rearc_quest_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name="rearc-quest-vpc"
  }
}
//subnet
resource "aws_subnet" "rearc_quest_public_subnet" {
  vpc_id = aws_vpc.rearc_quest_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name="rearc-quest-public-subnet"
  }
}
//internet-gateway
resource "aws_internet_gateway" "rearc_quest_igw" {
  vpc_id = aws_vpc.rearc_quest_vpc.id
  tags = {
    Name="rearc-quest-igw"
  }
}
//route-table
resource "aws_route_table" "rearc_quest_public_rt" {
  vpc_id = aws_vpc.rearc_quest_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rearc_quest_igw.id
  }
  tags={
    Name="rearc-quest-public-rt"
  }
}
//route-table and subnet association
resource "aws_route_table_association" "rearc_quest_subnet_assoction" {
  subnet_id = aws_subnet.rearc_quest_public_subnet.id
  route_table_id = aws_route_table.rearc_quest_public_rt.id
}
//Security Group
resource "aws_security_group" "rearc_quest_SG" {
  name = "rearc_quest_SG"
  description = "allow HTTP and SSH acess"
  vpc_id = aws_vpc.rearc_quest_vpc.id
  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1" //all prortocols
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  tags = {
    Name="rearc-quest-sg"
  }
}
//aws ec2 instances
resource "aws_instance" "rearc_quest_ec2" {
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.rearc_quest_public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [ aws_security_group.rearc_quest_SG.id ]
  user_data = <<-EOF
             #!/bin/bash
             yum update -y
             yum install -y git
             curl -sL https://rpm.nodesource.com/setup_18.x | bash -
             yum install -y nodejs
             cd /home/ec2-user
             git clone https://github.com/deepak-401/rearc-quest.git
             cd rearc-quest
             npm install
             node src/index.js > output.log 2>&1 &
             EOF
  tags = {
    Name="rearc-quest-ec2"
  }
}
