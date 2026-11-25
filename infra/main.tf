terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Trafico web de la aplicacion"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface" "app" {
  subnet_id       = "subnet-0123456789abcdef0"
  security_groups = [aws_security_group.web.id]
}

resource "aws_ebs_volume" "datos" {
  #checkov:skip=CKV_AWS_189:La cuenta de laboratorio no tiene cuota para una CMK dedicada y el volumen guarda datos de prueba. Se acepta el cifrado con la clave administrada aws/ebs. Aprobacion: MasterJD (dueno del repo), acta LAB-EXC-001 del 2026-11-25. Vence: 2027-06-30.
  availability_zone = "us-east-1a"
  size              = 20
  encrypted         = true
}

resource "aws_iam_policy" "soporte" {
  name = "soporte-app"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "*"
      Resource = "*"
    }]
  })
}
