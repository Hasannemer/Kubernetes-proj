# resource "aws_eks_node_group" "linux_nodes" {
#   # Name of the EKS Cluster.
#   cluster_name = aws_eks_cluster.my_eks_cluster.name

#   # Name of the EKS Node Group.
#   node_group_name = "linux_nodes"

#   # Amazon Resource Name (ARN) of the IAM Role that provides permissions for the EKS Node Group.
#   node_role_arn = aws_iam_role.nodes_general.arn

#   # Identifiers of EC2 Subnets to associate with the EKS Node Group. 
#   # These subnets must have the following resource tag: kubernetes.io/cluster/CLUSTER_NAME 
#   # (where CLUSTER_NAME is replaced with the name of the EKS Cluster).
#   subnet_ids = [aws_subnet.public_subnet.id]

#   # Configuration block with scaling settings
#   scaling_config {
#     # Desired number of worker nodes.
#     desired_size = 4

#     # Maximum number of worker nodes.
#     max_size = 6

#     # Minimum number of worker nodes.
#     min_size = 4
#   }

#   # List of instance types associated with the EKS Node Group
#   instance_types = ["t2.micro"]

#   labels = {
#     role = "nodes-general"
#   }

#   # Kubernetes version
#   version = "1.28"

#   # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
#   # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#   depends_on = [
#     aws_iam_role_policy_attachment.amazon_eks_worker_node_policy_general,
#     aws_iam_role_policy_attachment.amazon_eks_cni_policy_general,
#     aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
#     null_resource.delete_aws_node,
#     null_resource.install_calico_operator,
#     null_resource.configure_calico
#   ]
# }