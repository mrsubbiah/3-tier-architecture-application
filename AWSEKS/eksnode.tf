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

# EKS Node Group
resource "aws_eks_node_group" "bdiplusnode" {
  cluster_name    = aws_eks_cluster.bdiplus.name
  node_group_name = "bdiplusnode"
  node_role_arn   = aws_iam_role.bdiplusnode.arn

  subnet_ids = aws_subnet.public[*].id

  capacity_type = "ON_DEMAND"
  instance_types = var.instance_types

  remote_access {
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
  ]
}
