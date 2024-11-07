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
  description = "A Gatsby website deployed to GitHub Pages testing"
  visibility  = "public"
  auto_init   = true  # Initialize the repository with a README file
}

# Upload all files from the "public" directory to GitHub Pages' "gh-pages" branch
resource "github_repository_file" "gatsby_site_files" {
  for_each   = fileset("public", "**/*")  # This fetches all files in the "public" directory
  repository = github_repository.gatsby_site.name
  branch     = "gh-pages"                 # Target GitHub Pages branch
  file       = each.value
  content    = filebase64("public/${each.value}")
  commit_message = "Deploy Gatsby site files including PWA manifest"

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
