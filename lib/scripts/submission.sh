#!/usr/bin/env bash

# submission.sh - Shared helpers for submission readiness and certificate generation
# This library handles the final steps of verification: checking git status and generating the proof of completion.

# -----------------------------------------------------------------------------
# Git Helper Functions
# -----------------------------------------------------------------------------

# Current branch name
git_current_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null
}

# Short commit SHA
git_commit_short() {
  git rev-parse --short HEAD 2>/dev/null
}

# Get remote URL (origin)
git_remote_url() {
  git remote get-url origin 2>/dev/null
}

# Check if working tree is clean (no unstaged or staged changes)
git_is_working_tree_clean() {
  git diff --quiet && git diff --cached --quiet
}

# Check if HEAD is pushed to its remote tracking branch
git_is_head_pushed() {
  local branch
  branch=$(git_current_branch)
  if [[ -z "$branch" || "$branch" == "HEAD" ]]; then
    return 1
  fi

  # Determine upstream
  local upstream
  upstream=$(git rev-parse --abbrev-ref --symbolic-full-name "${branch}@{upstream}" 2>/dev/null || true)
  if [[ -z "$upstream" ]]; then
    return 1
  fi

  # Fetch minimal refs
  git fetch --quiet --depth=1 "${upstream%%/*}" "$branch" 2>/dev/null || true

  local head_sha remote_sha
  head_sha=$(git rev-parse "$branch" 2>/dev/null || echo "")
  remote_sha=$(git rev-parse "$upstream" 2>/dev/null || echo "")

  [[ -n "$head_sha" && "$head_sha" == "$remote_sha" ]]
}

# -----------------------------------------------------------------------------
# Certificate Generation
# -----------------------------------------------------------------------------

generate_certificate() {
  local adventure=$1
  local level=$2

  # Construct commit URL
  # Assumes standard GitHub URL format: https://github.com/user/repo.git or git@github.com:user/repo.git
  local remote_url
  remote_url=$(git_remote_url)

  # Clean up URL to be https base
  # Remove .git suffix
  remote_url=${remote_url%.git}
  # Convert SSH to HTTPS if needed
  remote_url=${remote_url/git@github.com:/https://github.com/}

  local commit_url="${remote_url}/commit/$(git_commit_short)"

  echo "--- CERTIFICATE START ---"
  echo "Adventure: $adventure"
  echo "Level: $level"
  echo "User: $(git config user.name)"
  echo "Repo: ${GITHUB_REPOSITORY:-unknown}"
  echo "Date: $(date)"
  echo "Url: $commit_url"
  echo "--- CERTIFICATE END ---"
}

# -----------------------------------------------------------------------------
# Submission Readiness Check
# Usage: check_submission_readiness "adventure-id" "level-id"
# -----------------------------------------------------------------------------
check_submission_readiness() {
  local adventure=$1
  local level=$2

  print_header "Claim Your Success"

  local all_ready=true

  print_test_section "Checking repository status..."

  # Check Working Tree
  if git_is_working_tree_clean; then
     print_success_indent "No uncommitted changes"
  else
     print_error_indent "You have uncommitted changes"
     all_ready=false
  fi

  # Check Push Status
  if git_is_head_pushed; then
     print_success_indent "All commits are pushed to remote"
  else
     print_error_indent "Not all commits are pushed to remote"
     all_ready=false
  fi

  print_new_line

  if [ "$all_ready" = true ]; then
      gum style --bold "🏆 Challenge Completed!"
      print_info_indent "Congratulations! You've successfully completed the challenge."
      print_info_indent "Copy the certificate below and paste it into the Open Ecosystem to claim your points."
      print_new_line
      generate_certificate "$adventure" "$level"
  else
      gum style --bold "📝 Action Required"
      print_info_indent "Please commit and push your changes to complete the challenge."
      print_info_indent "git add . && git commit -m 'Solved Challenge' && git push"
  fi
}
