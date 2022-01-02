resource "aws_iam_policy" "route53-external-policy" {
    name = "route53-external-policy"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

## WorkerNode IAM Role ##

resource "aws_iam_role" "eks_node_group_iam_role" {
    name = "eks-node-group-iam-role"

    assume_role_policy = <<POLICY
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
POLICY
}

data "aws_iam_policy_document" "route53-externaldns-policy" {
    statement {
        effect = "Allow"
        actions = ["sts:AssumeRole"]
        principals {
          type = "Service"
          identifiers = ["ec2.amazonaws.com"]
        }
    }

    statement {
      effect = "Allow"
      actions = ["sts:AssumeRole"]
      principals {
        type = "AWS"
        identifiers = ["${aws_iam_role.eks_node_group_iam_role.arn}"]
      }
    }
}

resource "aws_iam_role" "route53-externaldns-controller" {
    name = "route53-externaldns-controller"
    assume_role_policy = data.aws_iam_policy_document.route53-externaldns-policy.json
}

resource "aws_iam_role_policy_attachment" "route53-externaldns-attachment" {
    role = aws_iam_role.route53-externaldns-controller.name
    policy_arn = aws_iam_policy.route53-external-policy.arn
}
