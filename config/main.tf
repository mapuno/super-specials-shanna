# main.tf
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"  # Use the latest version compatible with your setup
    }
  }

  required_version = ">= 1.0.0"
}

provider "github" {
  token = var.github_token
}

# GitHub Repository for the Gatsby Site
resource "github_repository" "gatsby_site" {
  name        = "superspecials-shanna"
  description = "A Gatsby website deployed to GitHub Pages"
  visibility  = "public"
  auto_init   = true  # Initialize the repository with a README file
}

# Deploy Gatsby Site Files to GitHub Pages branch
resource "github_repository_file" "gatsby_site_files" {
  for_each   = fileset("public", "**/*")  # Gets all files in the Gatsby output folder
  repository = github_repository.gatsby_site.name
  branch     = "gh-pages"                 # GitHub Pages branch
  file       = each.value
  content    = filebase64("public/${each.value}")

  # Ensure the branch is created if it doesn't exist
  depends_on = [github_repository.gatsby_site]
}

# Create the gh-pages branch if it does not exist
resource "github_branch" "gh_pages_branch" {
  repository = github_repository.gatsby_site.name
  branch     = "gh-pages"
  source_branch = "main"

  # Only run if the branch does not exist
  lifecycle {
    ignore_changes = [source_branch]
    create_before_destroy = true
  }
}
