# basic-Infra-terraform-AWS

Infraestructura básica en AWS usando Terraform: VPC con subnets pública/privada, Internet Gateway, NAT Gateway y una instancia EC2.

## Arquitectura

```
                         INTERNET
                            │
                    ┌───────┴────────┐
                    │ Internet GW    │
                    └───────┬────────┘
                            │
              ┌─────────────┴─────────────┐
              │     VPC  10.0.0.0/16      │
              │                           │
  ┌───────────┴──────────┐  ┌─────────────┴─────────┐
  │  Subred Pública      │  │  Subred Privada        │
  │  10.0.1.0/24         │  │  10.0.2.0/24           │
  │                      │  │                        │
  │  ┌─────────────┐     │  │  ┌──────────────┐      │
  │  │ NAT Gateway │     │  │  │ EC2 (t2.micro)│     │
  │  │ + Elastic IP│     │  │  │ Amazon Linux  │     │
  │  └─────────────┘     │  │  └──────────────┘      │
  │                      │  │                        │
  │  Ruta: 0.0.0.0/0→IGW│  │  Ruta: 0.0.0.0/0→NAT  │
  └──────────────────────┘  └────────────────────────┘
```

## Recursos creados

| Recurso | Nombre | Descripción |
|---------|--------|-------------|
| VPC | `basic-infra-vpc` | Red virtual `10.0.0.0/16` |
| Internet Gateway | `basic-infra-igw` | Acceso a internet para la subred pública |
| Subred pública | `basic-infra-public-subnet` | `10.0.1.0/24` en `us-east-1a` |
| Subred privada | `basic-infra-private-subnet` | `10.0.2.0/24` en `us-east-1a` |
| NAT Gateway | `basic-infra-nat-gw` | Permite tráfico saliente desde la subred privada |
| Elastic IP | `basic-infra-nat-eip` | IP pública estática para el NAT Gateway |
| EC2 | `basic-infra-ec2` | Instancia `t2.micro` en la subred privada |
| Security Group | `basic-infra-ec2-sg` | Permite todo tráfico saliente |

## Estructura del proyecto

```
deploy/
├── main.tf          # Provider, VPC, subnets, gateways, route tables
├── variables.tf     # Variables de configuración
├── outputs.tf       # Valores de salida tras el despliegue
└── ec2.tf           # Instancia EC2, AMI data source, security group
```

## Variables

| Variable | Descripción | Default |
|----------|-------------|---------|
| `region` | Región de AWS | `us-east-1` |
| `vpc_cidr` | CIDR de la VPC | `10.0.0.0/16` |
| `public_subnet_cidr` | CIDR de la subred pública | `10.0.1.0/24` |
| `private_subnet_cidr` | CIDR de la subred privada | `10.0.2.0/24` |
| `availability_zone` | Zona de disponibilidad | `us-east-1a` |

## Outputs

| Output | Descripción |
|--------|-------------|
| `vpc_id` | ID de la VPC |
| `public_subnet_id` | ID de la subred pública |
| `private_subnet_id` | ID de la subred privada |
| `ec2_private_ip` | IP privada de la instancia EC2 |
| `nat_gateway_public_ip` | IP pública del NAT Gateway |

## Requisitos

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- AWS CLI configurado con credenciales
- Bucket S3 `basic-infra-terraform-state` para el backend

## Uso

```bash
cd deploy
terraform init
terraform plan
terraform apply
```

## Tecnologías

- Terraform (~> 5.0 AWS Provider)
- AWS (VPC, EC2, NAT Gateway, Internet Gateway)