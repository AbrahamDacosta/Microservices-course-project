# =============================================================================
# LOCALS - Bloc de DÉFINITION des variables
# =============================================================================
locals {
  # Configuration du cluster
  ami_types           = "AL2_x86_64"
  cluster_name        = "microservice_course_project"
  cluster_version     = "1.29"
  
  # Configuration des nœuds
  capacity_type       = "SPOT"
  disk_size          = 30
  instance_types     = ["t3.medium"]
  node_desired_size  = 3
  node_max_size      = 5
  node_min_size      = 1
  
  # Configuration réseau
  vpc_cidr           = "172.31.32.0/20"
  
  # ⚡ Calcul dynamique des zones de disponibilité (prend les 3 premières)
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
  
  # Sous-réseaux (CORRIGÉ: ajout du "10" manquant)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  intra_subnets   = ["10.0.51.0/24", "10.0.52.0/24", "10.0.53.0/24"]
  
  # Configuration NAT
  enable_nat_gateway  = true
  single_nat_gateway  = true
  
  # Configuration d'accès
  enable_cluster_creator = true
  enable_public_access   = true
}

# =============================================================================
# DATA SOURCES - Récupération d'informations AWS
# =============================================================================
# CORRIGÉ: "availability" au lieu de "avaibility"
data "aws_availability_zones" "available" {
  state = "available"
}

# =============================================================================
# MODULES - Utilisation avec local. (RÉFÉRENCE)
# =============================================================================
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"
  
  # 👆 ICI on UTILISE les valeurs avec local.
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
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
  
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

# =============================================================================
# OUTPUTS - Pour récupérer les valeurs après déploiement
# =============================================================================
output "cluster_name" {
  description = "Nom du cluster EKS"
  value       = local.cluster_name
}

output "vpc_id" {
  description = "ID du VPC créé"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs des sous-réseaux privés"
  value       = module.vpc.private_subnets
}