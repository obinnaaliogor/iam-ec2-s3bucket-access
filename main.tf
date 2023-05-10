
# CREATE AN IAM_ROLE, LET EC2 INSTANCE ASSUME THAT ROLE AS THE PRINCIPLE USING ASSUME_ROLE_POLICY.
# THEN CREATE AN AWS_IAM_ROLE_POLICY LET THAT POLICY HAVE S3FULL ACCESS.
# LINK THIS ROLE TO THE EC2-INSTANCE SO IT CAN WRITE, CREATE AND LIST A BUCKET.
terraform {
  required_version = "~> 1.4"
  required_providers{
    aws ={
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

##1 Define Provider Block
provider "aws" {
  region = "us-east-2"
}

##2 Create An IAM role and pass an entity that will assume that role.
# Here the role will be Assumed by a resource ec2 instance.
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

##3 Create an iam_role_policy,
##The below Policy will allows EC2 instance to write s3 bucket and other permissions like ec2 instance connect that will allow for ssh
resource "aws_iam_role_policy" "ec2_policy" {
  name = "ec2_policy"
  role = aws_iam_role.ec2_role.name #Required argurment needed in policy creation.

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
          "ec2-instance-connect:SendSSHPublicKey",
          "ec2-instance-connect:SendSerialConsoleSSHPublicKey"
        ]
        Effect   = "Allow"
        Resource = "*"
        #If required that this instance write to a specific bucket. i will modify the Resource argument as follows:
        #  "Resource": [
        #         "arn:aws:s3:::examplebucket", #The arn will represent the amazon resource name of the bucket.
        #         "arn:aws:s3:::examplebucket/*"
        #     
      },
    ]
  })
}

##4 Create an Iam Instance Profile, this is an argument needed to grant/assign more permissions to ec2 instance.
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}

#5 Creating an ec2 instance and add the argument iam_instance Profile and the values.
# This will grant ec2 instance the role and permission in the instance profile
resource "aws_instance" "web" {
  key_name = var.key_pair
  ami = data.aws_ami.ubuntu_user.id
  instance_type = var.instance_type[count.index] #Will iterate and give the number from 0,1,2....
  count = length(var.instance_type) #LENGTH USED TO GET THE NUMBER OF ITEM IN A LIST, CANT BE IN THE SAME LINE OF ARG WITH count.index
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name #This argument is used to assign an IAM role to ec2 instances.
  tags = {
    Name = "prod-${count.index}"
  }
}
#5 Using Datasource to get an AMI to provision an instance.
data "aws_ami" "ubuntu_user" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"] #Gets you amazon linux 2 AMI
    #values = ["ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"] #gets you ubuntu AMI
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  
}
##6 Attribute what you can get out of a resource
#to get the ami it will be data.resourcetype.resourcename.attribute #attribute is id
#This ami id that will be gotten will be passed into the ami fild ofthe instance.
output "ami_id" {
value = data.aws_ami.ubuntu_user.id
}

#So i excluded the iam instance profile and create the instance.
#I Leta added the iam instance profile as part of Ec2 instance argument. Terraform said "aws_instance.web[1] will be updated in-place"