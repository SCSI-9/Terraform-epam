
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.stack}-vpc"
  }
}

resource "aws_subnet" "my_subnet" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 8, count.index)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "my-subnet-${count.index}"
  }
}

resource "aws_db_subnet_group" "mysql" {
  name       = "db-subngroup"
  subnet_ids = ["${aws_subnet.my_subnet.*.id[0]}", "${aws_subnet.my_subnet.*.id[1]}"]

  tags = {
    Name = "${var.stack}-subnetGroup"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.stack}-igw"
  }
}


resource "aws_eip" "eip" {

  vpc = true

  tags = {
    Name = "${var.stack}-nat-ip"
  }
}



resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


}


# # #
resource "aws_route_table_association" "private1" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.my_subnet.*.id[0]
}

resource "aws_route_table_association" "private2" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.my_subnet.*.id[1]
}





