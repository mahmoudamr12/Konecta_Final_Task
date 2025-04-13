resource "aws_instance" "ci_cd_instance" {
  ami           = "ami-084568db4383264d4" # ubuntu 24.04
  instance_type = var.instance_type
  key_name     = aws_key_pair.ci_cd_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  tags = {
    Name = "ci-cd-server"
  }
  
  provisioner "local-exec" {
    command = "bash ./script.sh ${self.public_ip}"
  }
}



resource "aws_key_pair" "ci_cd_key" {
  key_name   = "ci_cd_key"
  public_key = file("~/.ssh/ci_cd_key.pub")
}
