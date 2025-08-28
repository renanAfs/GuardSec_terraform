output "fortigate_primary_ip" { value = aws_instance.fortigate_primary.public_ip }
output "fortigate_secondary_ip" { value = aws_instance.fortigate_secondary.public_ip }
output "fortimanager_ip" { value = aws_instance.fortimanager.public_ip }