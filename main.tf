/*
CREATE A IAM_ROLE LET EC2 INSTANCE ASSUME THAT ROLE AS THE PRINCIPLE USING ASSUME_ROLE_POLICY.
THEN CREATE AN AWS_IAM_ROLE_POLICY LET THAT POLICY HAVE S3FULL ACCESS.
LINK THIS ROLE TO THE EC2-INSTANCE SO IT CAN WRITE, CREATE AND LIST A BUCKET.

*/

# Here we create a iam role policy, the below Policy will allows EC2 instance to execute specific commands for example: S3Full access to s3Bucket.
resource "aws_iam_role_policy" "ec2_policy" {
  name = "ec2_policy"
  role = aws_iam_role.ec2_role.id #Required argurment needed in policy creation.

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

#First method of creating a role and adding an entity that requires that role.
# Here the role will be assumed by a resource ec2 instance.

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

#How do we link this role to our ec2 instance that we have created or will be creating so it can access the bucket?
#We will have to create an EC2 instance Profile and use it to link the role to the instance.

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.id
}

#Creating an instance
resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu_user.id
  instance_type = var.instance_id[count.index] #Will iterate and give the number from 0,1,2....
  count = length(var.instance_id) #LENGTH USED TO GET THE NUMBER OF ITEM IN A LIST, CANT BE IN THE SAME LINE OF ARG WITH count.index
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  tags = {
    Name = "prod-${count.index}"
  }
}
#Using datasource to get an AMI to provision an instance.
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
#Attribute what you can get out of a resource 
#to get the ami it will be data.resourcetype.resourcename.attribute #attribute is id
#This ami id that will be gotten will be passed into the ami fild in the instance
output "ami_id" {
value = data.aws_ami.ubuntu_user.id
}


#WE CAN ALSO CREATE AN S3 BUCKET CALLED "OBINNA" OR ANYNAME IF YOU DO NOT HAVE A BUCKET ALREADY CREATED


/*#second method
#Alternatively Creating a role and adding the entity that will assume the role. 
#It is done in 2 ways by using data source and directly.
data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name               = "instance_role"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}
*/
