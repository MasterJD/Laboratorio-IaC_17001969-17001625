# Caso que FALLA: recursos sin las etiquetas de la organizacion.
# Uso: checkov -d politicas/ejemplos/falla --external-checks-dir politicas \
#        --check CKV2_ORG_101,CKV2_ORG_102

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_security_group" "sin_etiquetas" {
  name        = "ejemplo-sin-etiquetas"
  description = "Caso de ejemplo que incumple la politica"

  ingress {
    description = "HTTPS interno"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_ebs_volume" "sin_etiquetas" {
  availability_zone = "us-east-1a"
  size              = 10
}
