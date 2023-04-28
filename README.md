IAM stands for Identity and Access Management. It refers to a set of policies, technologies, and practices that help organizations manage digital identities and control access to resources. IAM is used to ensure that the right people have the right access to the right resources at the right time, and for the right reasons.

In other words, IAM is the process of managing digital identities and their associated permissions to ensure that only authorized users have access to an organization's resources. IAM solutions typically include authentication, authorization, and user management capabilities, as well as tools for managing access to cloud-based applications, databases, and other resources.

IAM is a critical component of security in modern IT environments, as it helps organizations protect sensitive data and systems from unauthorized access and data breaches. It also helps organizations comply with regulations and industry standards, such as HIPAA, PCI-DSS, and GDPR.

WE HAVE 2 TYPES OF POLICY
RESOURCE BASED POLICY AND IDENTITY BASED POLICY..
Here are some examples of Identity-Based Policies (IBPs) and Resource-Based Policies (RBPs) in AWS:

1. Identity-Based Policy Example:
   This policy allows any user with an IP address within the specified range to perform any S3 action (such as creating, listing, and deleting objects) on the specified bucket.
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::examplebucket",
                "arn:aws:s3:::examplebucket/*"
            ],
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": [
                        "203.0.113.0/24",
                        "203.0.113.1/32"
                    ]
                }
            }
        }
    ]
}

2. This policy grants public read access to all objects in the specified bucket. The principal is set to "*" which means all users, including anonymous users, are granted this permission. The Sid ("AllowPublicRead") is a human-readable identifier for this policy statement.
 {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowPublicRead",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::examplebucket/*"
        }
    ]
}
3. The AssumeRole policy is an Identity-Based Policy (IBP) in AWS that specifies who can assume a particular AWS Identity and Access Management (IAM) role. When a user or application assumes a role, they temporarily receive the permissions associated with that role.

The AssumeRole policy can be defined in the role's Trust Policy. The Trust Policy is a resource-based policy that defines which principals (such as IAM users, roles, or AWS services) are allowed to assume the role. It is used to establish trust between the role and the trusted entity that is assuming the role.

Here is an example AssumeRole policy in a role's Trust Policy:
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::123456789012:user/Bob"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
This policy allows the IAM user "Bob" (with the specified ARN) to assume the role. When "Bob" assumes this role, he will receive the permissions associated with the role for the duration of the session.

Note that the policy also specifies the "sts:AssumeRole" action, which is required for assuming a role. Additionally, the Trust Policy can also specify other conditions, such as requiring Multi-Factor Authentication (MFA) for assuming the role.

THE MAIN GOAL IS IN MY TERRAFORM CODE:

CREATE A IAM_ROLE LET EC2 INSTANCE ASSUME THAT ROLE AS THE PRINCIPLE USING ASSUME_ROLE_POLICY.
THEN CREATE AN AWS_IAM_ROLE_POLICY LET THAT POLICY HAVE S3FULL ACCESS.
LINK THIS ROLE TO THE EC2-INSTANCE SO IT CAN WRITE, CREATE AND LIST A BUCKET.
