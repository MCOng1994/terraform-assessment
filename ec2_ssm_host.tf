data "aws_ssm_parameter" "al2023" {
  provider = aws
  name     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

resource "aws_instance" "ssm_host" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.ssm_host_instance_type
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids      = [aws_security_group.ssm_host_sg.id]

  tags = merge(var.tags, { Name = "ssm-host" })

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y awscli
              EOF
}
