#OAuthToken
data "aws_ssm_parameter" "github_key" {
  name = "/dev/github_key"
}

# create a 3 stage pipeline
resource "aws_codepipeline" "tf-eks-pipeline" {
  name     = var.repo_name
  role_arn = aws_iam_role.tf-eks-pipeline.arn

  artifact_store {
    location = aws_s3_bucket.build_artifact_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.artifact_encryption_key.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts =  ["source"]

      configuration = {
        Owner                = var.github_org
        Repo                 = var.repo_name
        PollForSourceChanges = "true"
        Branch               = var.default_branch
        OAuthToken           = data.aws_ssm_parameter.github_key.value
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.tf-eks-build.name
      }
    }
  }

  stage {
    name = "StagingDeploy"

    action {
      name             = "StagingDeploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.tf-eks-deploy-staging.name
      }
    }
  }

  stage {
    name = "PromoteToProd"

    action {
      name             = "PromoteToProd"
      category         = "Approval"
      owner            = "AWS"
      provider         = "Manual"
      version          = "1"
    }
  }

  stage {
    name = "ProdDeploy"

    action {
      name             = "ProdDeploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.tf-eks-deploy-prod.name
      }
    }
  }

}

