output "jenkins_server_ip" {
  value = aws_instance.ci_cd_instance.public_ip
  description = "Public IP of the Jenkins server"
}
