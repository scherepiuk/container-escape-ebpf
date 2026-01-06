output "instance_ip" {
  value = aws_instance.vm.public_ip
}

output "ssh_command" {
  value = "ssh -i ${var.ssh_private_key_path} ubuntu@${aws_instance.vm.public_ip}"
}
