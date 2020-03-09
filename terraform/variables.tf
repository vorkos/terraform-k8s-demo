variable "region" {
  default = "us-east-1"
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = [
  ]
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
      
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::083910215161:user/admin"
      username = "admin"
      groups   = ["system:masters"]
    },
  ]
}


# CodeCommit and ECR repo name, also as artifact bucket prefix
variable "repo_name" {
  default = "terraform-k8s-demo"
}

# define default git branch
variable "default_branch" {
  default = "debug/buildspec"
}

# define docker image for build stage
variable "build_image" {
  default = "aws/codebuild/docker:18.09.0"
}

# define build spec for build stage
variable "build_spec" {
  default = "build/buildspec.yaml"
}

# define docker image for deploy stage
variable "deploy_image" {
  default = "aws/codebuild/standard:3.0"
}

# define build spec for deploy stage
variable "deploy_spec" {
  default = "build/deploy.yaml"
}

variable "github_org" {
  default = "vorkos"
}