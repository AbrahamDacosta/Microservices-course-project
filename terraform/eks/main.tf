# =============================================================================
# LOCALS - Bloc de DÉFINITION des variables
# =============================================================================
locals {
  # Configuration du cluster
  ami_types       = "AL2_x86_64"
  cluster_name    = "microservice-proj"
  cluster_version = "1.29"

  # Configuration des nœuds
  capacity_type     = "SPOT"
  disk_size         = 30
  instance_types    = ["t3.medium"]
  node_desired_size = 3
  node_max_size     = 5
  node_min_size     = 1

  # Configuration réseau
  vpc_cidr = "10.0.0.0/16"

  # ⚡ Calcul dynamique des zones de disponibilité (prend les 3 premières)
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  # Sous-réseaux
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  intra_subnets   = ["10.0.51.0/24", "10.0.52.0/24", "10.0.53.0/24"]

  # Configuration NAT
  enable_nat_gateway = true
  single_nat_gateway = true

  # Configuration d'accès
  enable_cluster_creator = true
  enable_public_access   = true
}

# =============================================================================
# DATA SOURCES - Récupération d'informations AWS
# =============================================================================
data "aws_availability_zones" "available" {
  state = "available"
}

# =============================================================================
# MODULES - Utilisation avec local. (RÉFÉRENCE)
# =============================================================================
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name               = "${local.cluster_name}-vpc"
  azs                = local.azs
  cidr               = local.vpc_cidr
  private_subnets    = local.private_subnets
  public_subnets     = local.public_subnets
  intra_subnets      = local.intra_subnets
  enable_nat_gateway = local.enable_nat_gateway
  single_nat_gateway = local.single_nat_gateway

  # Tags pour EKS
  public_subnet_tags = {
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"             = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  # Tags généraux
  tags = {
    Environment = "development"
    Project     = "microservice-course"
    ManagedBy   = "terraform"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name                             = local.cluster_name
  cluster_version                          = local.cluster_version
  cluster_endpoint_public_access           = local.enable_public_access
  enable_cluster_creator_admin_permissions = local.enable_cluster_creator

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # Structure du node group avec nom cohérent
  eks_managed_node_groups = {
    main = { # COHÉRENT: nom simple et court
      ami_type       = local.ami_types
      capacity_type  = local.capacity_type
      instance_types = local.instance_types

      min_size     = local.node_min_size
      max_size     = local.node_max_size
      desired_size = local.node_desired_size

      # Tags pour les instances
      launch_template_tags = {
        Name = "${local.cluster_name}-node"

      }

      #   # Labels Kubernetes pour identifier les nœuds
      #   labels = {
      #     Environment = "development"
      #     NodeGroup   = "main"
      #   }
    }
  }
}
# =============================================================================
# OUTPUTS - Pour récupérer les valeurs après déploiement
# =============================================================================
# output "cluster_name" {
#   description = "Nom du cluster EKS"
#   value       = local.cluster_name
# }

# output "vpc_id" {
#   description = "ID du VPC créé"
#   value       = module.vpc.vpc_id
# }

# output "private_subnet_ids" {
#   description = "IDs des sous-réseaux privés"
#   value       = module.vpc.private_subnets
# }

# output "cluster_endpoint" {
#   description = "Endpoint du cluster EKS"
#   value       = module.eks.cluster_endpoint
# }

# output "cluster_security_group_id" {
#   description = "Security group du cluster"
#   value       = module.eks.cluster_security_group_id
# }