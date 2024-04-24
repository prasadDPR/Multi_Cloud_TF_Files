resource "aws_vpc" "vpc" {
  cidr_block = "192.168.1.0/24"
  tags = {
    Name = "task-vpc"
  }
}

resource "aws_subnet" "subnet-public-1a" {
  availability_zone = "ap-south-1a"
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.1.0/26"
  tags = {
    Name = "public-subnet-ap-south-1a"
  }
}

resource "aws_subnet" "subnet-private-1a" {
  availability_zone = "ap-south-1a"
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.1.128/26"
  tags = {
    Name = "private-subnet-ap-south-1a"
  }
}

resource "aws_subnet" "subnet-public-1b" {
  availability_zone = "ap-south-1b"
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.1.64/26"
  tags = {
    Name = "public-subnet-ap-south-1b"
  }
}

resource "aws_subnet" "subnet-private-1b" {
  availability_zone = "ap-south-1b"
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.1.192/26"
  tags = {
    Name = "private-subnet-ap-south-1b"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "task-ig"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "task-public-route-table"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "task-private-route-table"
  }
}

resource "aws_route_table_association" "public-rt-association-1a" {
  subnet_id      = aws_subnet.subnet-public-1a.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-rt-association-1b" {
  subnet_id      = aws_subnet.subnet-public-1b.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private-rt-association-1a" {
  subnet_id      = aws_subnet.subnet-private-1a.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private-rt-association-1b" {
  subnet_id      = aws_subnet.subnet-private-1b.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "task-sg"
  }

  ingress {
    description = "HTTP"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
  }

  ingress {
    description = "SSH"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
  }

  ingress {
    description = "RDP"
    protocol    = "tcp"
    from_port   = 3389
    to_port     = 3389
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2-1" {
  tags = {
    "Name"  = "task-server-1"
    "Admin" = "server-1"
  }
  ami                    = "ami-0cca134ec43cf708f"
  instance_type          = "t2.micro"
  key_name               = "aws_np"
  subnet_id              = aws_subnet.subnet-public-1a.id
  security_groups        = [aws_security_group.sg.id]
  availability_zone      = "ap-south-1a"
}

resource "aws_instance" "ec2-2" {
  tags = {
    "Name"  = "task-server-2"
    "Admin" = "server-2"
  }
  ami                    = "ami-0cca134ec43cf708f"
  instance_type          = "t2.micro"
  key_name               = "aws_np"
  subnet_id              = aws_subnet.subnet-public-1b.id
  security_groups         = [aws_security_group.sg.id]
  availability_zone      = "ap-south-1b"
}



