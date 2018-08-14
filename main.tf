#------------main.tf-------------

provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

#--------IAM-------

#--------S3 access

resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "s3_access"
  role = "${aws_iam_role.s3_access_role.name}"
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_access_policy"
  role = "${aws_iam_role.s3_access_role.id}"

  policy = <<EOF
{
 
  "Version": "2012-10-17",
  "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "s3_access_role" {
  name = "s3_access_role"

  assume_role_policy = <<EOF
{
   
    "Version": "2012-10-17",
    "Statement": [
        {
           "Action": "sts:AssumeRole",
            "principal": {
               "Service": "ec2.amazonaws.com"
          },
            "Effect": "Allow",
            "Sid": ""
    
             }
     ]
}
EOF
}

#------VPC-----

resource "aws_vpc" "pt_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    name = "pt_vpc"
  }
}

#-------internet gateway

resource "aws_internet_gateway" "pt_internet_gateway" {
  vpc_id = "${aws_vpc.pt_vpc.id}"

  tags {
    name = "pt_igw"
  }
}

#---route table

resource "aws_route_table" "pt_public_rt" {
  vpc_id = "${aws_vpc.pt_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.pt_internet_gateway.id}"
  }

  tags {
    name = "pt_public"
  }
}

resource "aws_default_route_table" "pt_private_rt" {
  default_route_table_id = "${aws_vpc.pt_vpc.default_route_table_id}"

  tags {
    name = "pt_private"
  }
}

#---------subnets

resource "aws_subnet" "pt_public1_subnet" {
  vpc_id                  = "${aws_vpc.pt_vpc.id}"
  cidr_block              = "${var.cidrs["public1"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    name = "pt_public1"
  }
}

resource "aws_subnet" "pt_public2_subnet" {
  vpc_id                  = "${aws_vpc.pt_vpc.id}"
  cidr_block              = "${var.cidrs["public2"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    name = "pt_public2"
  }
}

resource "aws_subnet" "pt_private1_subnet" {
  vpc_id                  = "${aws_vpc.pt_vpc.id}"
  cidr_block              = "${var.cidrs["private1"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    name = "pt_private1"
  }
}

resource "aws_subnet" "pt_private2_subnet" {
  vpc_id                  = "${aws_vpc.pt_vpc.id}"
  cidr_block              = "${var.cidrs["private2"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    name = "pt_private2"
  }
}

resource "aws_subnet" "pt_private3_subnet" {
  vpc_id                  = "${aws_vpc.pt_vpc.id}"
  cidr_block              = "${var.cidrs["private3"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[2]}"

  tags {
    name = "pt_private3"
  }
}

#-------subnet and route associations

resource "aws_route_table_association" "pt_public1_assoc" {
  subnet_id      = "${aws_subnet.pt_public1_subnet.id}"
  route_table_id = "${aws_route_table.pt_public_rt.id}"
}

resource "aws_route_table_association" "pt_public2_assoc" {
  subnet_id      = "${aws_subnet.pt_public2_subnet.id}"
  route_table_id = "${aws_route_table.pt_public_rt.id}"
}

resource "aws_route_table_association" "pt_private1_assoc" {
  subnet_id      = "${aws_subnet.pt_private1_subnet.id}"
  route_table_id = "${aws_default_route_table.pt_private_rt.id}"
}

resource "aws_route_table_association" "pt_private2_assoc" {
  subnet_id      = "${aws_subnet.pt_private2_subnet.id}"
  route_table_id = "${aws_default_route_table.pt_private_rt.id}"
}


#-------security group

resource "aws_security_group" "pt_jenk_sg" {
  name        = "pt_jenk_sg"
  description = "Allow access to jenkins server"
  vpc_id      = "${aws_vpc.pt_vpc.id}"

#ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

#http
   ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

#python flask
    ingress {
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }
    
    egress {
       from_port       = 0
       to_port         = 0
       protocol        = "-1"
       cidr_blocks     = ["0.0.0.0/0"]
   }
}

#VPC endpoint for s3

resource "aws_vpc_endpoint" "pt_s3" {
  vpc_id       = "${aws_vpc.pt_vpc.id}"
  service_name = "com.amazonaws.${var.aws_region}.s3"

  route_table_ids = ["${aws_default_route_table.pt_private_rt.id}",
       "${aws_route_table.pt_public_rt.id}"
   ]

  policy = <<POLICY
{
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
POLICY
}


#-------s3 bucket
resource "random_id" "pt_bucket_code" {
  byte_length = 2
}

resource "aws_s3_bucket" "code" {
  bucket = "${var.domain_name}-${random_id.pt_bucket_code.dec}"
  acl           = "private"
  force_destroy = true

  tags {
    name = "pt_bucket"
  }
}

#-----key pair
resource "aws_key_pair" "pt_auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

#-----jenkins server

resource "aws_instance" "pt_jenk" {
   instance_type = "${var.jenk_instance_type}"
   ami           = "${var.jenk_ami}"
   
  tags {
    Name = "pt_jenkins"
  }
  
  key_name = "${aws_key_pair.pt_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.pt_jenk_sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.s3_access_profile.id}"
  subnet.id = "${aws_subnet.pt_public2_subnet.id}"

  provisioner "local-exec" {
     command = <<EOD
cat<<EOF > aws_hosts
[jenkins]
${aws_instance.pt_jenk.public_ip}
[jenkins:vars]
s3code=${aws_s3_bucket.code.bucket}
domain=${var.domain_name}
EOF
EOD
  }

  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.pt_jenk.id} --profile quickee && ansible-playbook -i aws_hosts jenk-serve.yml" 
  }
}





