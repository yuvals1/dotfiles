# Add these to your .zshrc file

# Diff content utilities
alias gdcopy='git diff | pbcopy'
alias gdshow='git diff'
alias gdscopy='git diff --staged | pbcopy'
alias gdsshow='git diff --staged'
gdpcopy() {
  local commits=${1:-1}
  git diff HEAD~$commits HEAD | pbcopy
  echo "Copied diff of last $commits commit(s) to clipboard"
}
gdpshow() {
  local commits=${1:-1}
  git diff HEAD~$commits HEAD
}

# Changed files names utilities
alias gfcopy='git diff --name-only | pbcopy'
alias gfshow='git diff --name-only'
alias gfscopy='git diff --staged --name-only | pbcopy'
alias gfsshow='git diff --staged --name-only'
gfpcopy() {
  local commits=${1:-1}
  git diff --name-only HEAD~$commits HEAD | pbcopy
  echo "Copied names of files changed in last $commits commit(s) to clipboard"
}
gfpshow() {
  local commits=${1:-1}
  git diff --name-only HEAD~$commits HEAD
}

# Full content of changed files utilities
gccopy() {
  git diff --name-only | xargs cat | pbcopy
  echo "Copied content of unstaged changed files to clipboard"
}
gcshow() {
  git diff --name-only | xargs cat
}
gcscopy() {
  git diff --staged --name-only | xargs cat | pbcopy
  echo "Copied content of staged changed files to clipboard"
}
gcsshow() {
  git diff --staged --name-only | xargs cat
}
gcpcopy() {
  local commits=${1:-1}
  git diff --name-only HEAD~$commits HEAD | xargs cat | pbcopy
  echo "Copied content of files changed in last $commits commit(s) to clipboard"
}
gcpshow() {
  local commits=${1:-1}
  git diff --name-only HEAD~$commits HEAD | xargs cat
}
