# Create a Node
# role for nodegroup

resource "aws_iam_role" "bdiplusnode" {
  name = "eks-node-group-bdiplusnode"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# IAM policy attachment to nodegroup

resource "aws_iam_role_policy_attachment" "bdiplusnode-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.bdiplusnode.name
}

resource "aws_iam_role_policy_attachment" "bdiplusnode-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.bdiplusnode.name
}

resource "aws_iam_role_policy_attachment" "bdiplusnode-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.bdiplusnode.name
}

# Create a Security Group for the node group
resource "aws_security_group" "bdiplusnode_sg" {
  name        = "bdiplusnode-sg"
  description = "Allow inbound HTTP, HTTPS, and Kubernetes traffic"
  vpc_id      = aws_vpc.bdiplusvpc.id

  # Inbound rules to allow traffic on ports 80, 443 and 22 from anywhere (IPv4)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow from anywhere IPv4
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow from anywhere IPv4
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # You can adjust this to your specific IP range
  }

  # Allow internal EKS node communication (kubelet communication)
ingress {
  from_port   = 10250
  to_port     = 10250
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # Adjust CIDR range to your VPC
}
# Allow internal communication on other required ports for EKS
  ingress {
    from_port   = 10255
    to_port     = 10255
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow from anywhere, or restrict to the VPC CIDR range
  }

  # Outbound rules (by default, AWS allows all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EKS Node Group
resource "aws_eks_node_group" "bdiplusnode" {
  cluster_name    = aws_eks_cluster.bdiplus.name
  node_group_name = "bdiplusnode"
  node_role_arn   = aws_iam_role.bdiplusnode.arn

  subnet_ids = aws_subnet.public[*].id

  capacity_type = "ON_DEMAND"
  instance_types = var.instance_types

  remote_access {
    source_security_group_ids = [aws_security_group.bdiplusnode_sg.id]
    ec2_ssh_key = "subbiahkeypair" 
  }

  scaling_config {
    desired_size = 1
    max_size     = 10
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    node = "bdiplusnode1"
  }


  depends_on = [
    aws_iam_role_policy_attachment.bdiplusnode-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.bdiplusnode-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.bdiplusnode-AmazonEC2ContainerRegistryReadOnly,
    aws_security_group.bdiplusnode_sg,
  ]
}
