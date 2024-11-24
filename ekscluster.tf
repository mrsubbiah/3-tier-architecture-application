#Create EKS Cluster
# IAM role for eks

resource "aws_iam_role" "bdirole" {
  name = "eks-cluster-bdiplus"
  tags = {
    tag-key = "eks-cluster-bdiplus"
  }

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "eks.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

# eks policy attachment

resource "aws_iam_role_policy_attachment" "bdiplus-AmazonEKSClusterPolicy" {
  role       = aws_iam_role.bdirole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# bare minimum requirement of eks

resource "aws_eks_cluster" "bdiplus" {
  name     = "bdiplus"
  role_arn = aws_iam_role.bdirole.arn

  vpc_config {
    subnet_ids = flatten([
      aws_subnet.public[*].id,
      aws_subnet.private[*].id
    ])
  }

  depends_on = [aws_iam_role_policy_attachment.bdiplus-AmazonEKSClusterPolicy]
}

# Fetch the EKS cluster's security group automatically created by EKS
data "aws_eks_cluster" "bdiplus" {
  name = aws_eks_cluster.bdiplus.name
}

# Retrieve the security group ID associated with the EKS cluster
data "aws_security_group" "eks_sg" {
  id = data.aws_eks_cluster.bdiplus.vpc_config[0].cluster_security_group_id
}

# Add inbound rule for HTTP (port 80)
resource "aws_security_group_rule" "allow_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  cidr_blocks             = ["0.0.0.0/0"]
  security_group_id       = data.aws_security_group.eks_sg.id

  depends_on = [aws_eks_cluster.bdiplus]
}

# Add inbound rule for HTTPS (port 443)
resource "aws_security_group_rule" "allow_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  cidr_blocks             = ["0.0.0.0/0"]
  security_group_id       = data.aws_security_group.eks_sg.id

  depends_on = [aws_eks_cluster.bdiplus]
}

# Add inbound rule for Kubernetes NodePort range (ports 31000 to 31001)
resource "aws_security_group_rule" "allow_nodeport_range" {
  type                     = "ingress"
  from_port                = 31000
  to_port                  = 31001
  protocol                 = "tcp"
  cidr_blocks             = ["0.0.0.0/0"]
  security_group_id       = data.aws_security_group.eks_sg.id

  depends_on = [aws_eks_cluster.bdiplus]
}

# Add inbound rule for SSH (port 22)
resource "aws_security_group_rule" "allow_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  cidr_blocks             = ["0.0.0.0/0"]  # Or restrict to a specific range if needed
  security_group_id       = data.aws_security_group.eks_sg.id

  depends_on = [aws_eks_cluster.bdiplus]
}
