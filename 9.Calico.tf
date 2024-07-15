# resource "null_resource" "delete_aws_node" {
#   provisioner "local-exec" {
#     command = "kubectl delete daemonset -n kube-system aws-node"
#   }

#   depends_on = [aws_eks_cluster.my_eks_cluster]
# }

# resource "null_resource" "install_calico_operator" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml"
#   }

#   depends_on = [null_resource.delete_aws_node]
# }

# resource "null_resource" "configure_calico" {
#   provisioner "local-exec" {
#     command = <<EOF
# cat <<EOT | kubectl apply -f -
# kind: Installation
# apiVersion: operator.tigera.io/v1
# metadata:
#   name: default
# spec:
#   kubernetesProvider: EKS
#   cni:
#     type: Calico
#   calicoNetwork:
#     bgp: Disabled
# EOT
# EOF
#   }

#   depends_on = [null_resource.install_calico_operator]
# }


