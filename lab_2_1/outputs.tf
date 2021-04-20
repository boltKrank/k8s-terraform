#k8s master
output "public_instance_id" {
  value = aws_instance.k8s_master.id
}

output "public_instance_ip" {
  value = aws_instance.k8s_master.public_ip
}

#k8s worker 1
output "public_instance_id" {
  value = aws_instance.k8s_worker1.id
}

output "public_instance_ip" {
  value = aws_instance.k8s_worker1.public_ip
}

#k8s worker 2
output "public_instance_id" {
  value = aws_instance.k8s_worker2.id
}

output "public_instance_ip" {
  value = aws_instance.k8s_worker2.public_ip
}