#k8s master
output "k8s_master_id" {
  value = aws_instance.k8s_master.id
}

output "k8s_master_public_ip" {
  value = aws_instance.k8s_master.public_ip
}

#k8s worker 1
output "k8s_worker1_id" {
  value = aws_instance.k8s_worker1.id
}

output "k8s_worker1_public_ip" {
  value = aws_instance.k8s_worker1.public_ip
}

#k8s worker 2
output "k8s_worker2_id" {
  value = aws_instance.k8s_worker2.id
}

output "k8s_worker2_public_ip" {
  value = aws_instance.k8s_worker2.public_ip
}