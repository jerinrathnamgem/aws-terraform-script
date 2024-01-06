
resource "aws_instance" "this" {

  ami                         = var.amiID
  instance_type               = var.instance_type
  associate_public_ip_address = var.create_eip
  vpc_security_group_ids      = [var.sg_id]
  subnet_id                   = var.subnet_id
  key_name                    = var.private_key_name
  disable_api_termination     = false
  iam_instance_profile        = aws_iam_instance_profile.this.id

  user_data = <<EOF
#!/bin/bash
yum update -y
yum install ruby -y
yum install wget -y
wget https://aws-codedeploy-${var.region}.s3.amazonaws.com/latest/install
chmod +x ./install
./install auto
yum install httpd -y
useradd node
chmod 775 /home/node
mkdir /home/node/public_html
sudo dnf update
sudo dnf install postgresql15.x86_64 postgresql15-server -y
sudo yum install https://rpm.nodesource.com/pub_20.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y
sudo yum install nodejs -y --setopt=nodesource-nodejs.module_hotfixes=1
sudo yum install gcc-c++ make -y
sudo npm install -g pm2
pm2 startup
pm2 save
sudo chown node:node /home/node -R
EOF

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.volume_size
    delete_on_termination = var.volume_termination
    encrypted             = var.volume_encryption
  }

  tags = {
    Name = var.name
  }
}

resource "aws_eip" "this" {
  count    = var.create_eip ? 1 : 0
  instance = aws_instance.this.id
  tags = {
    Name = "${var.name}-ip"
  }
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-profile"
  role = "${var.name}-ec2"
}

############################### EC2 INSTANCE ROLE ######################################

resource "aws_iam_role" "ec2_role" {
  name = "${var.name}-ec2"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "${var.name}-ec2-policy"
  role = aws_iam_role.ec2_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3-object-lambda:Get*",
                "s3-object-lambda:List*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

