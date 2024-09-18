# Add these to your .zshrc file

# Diff content utilities
alias gdcopy='git diff | pbcopy'
alias gdshow='git diff'
alias gdscopy='git diff --staged | pbcopy'
alias gdsshow='git diff --staged'
gdpcopy() {
  if [ $# -eq 0 ]; then
    git diff HEAD~1 HEAD | pbcopy
    echo "Copied diff of the last commit to clipboard"
  else
    git diff HEAD~$1 HEAD | pbcopy
    echo "Copied diff of last $1 commit(s) to clipboard"
  fi
}
gdpshow() {
  if [ $# -eq 0 ]; then
    git diff HEAD~1 HEAD
  else
    git diff HEAD~$1 HEAD
  fi
}

# Changed files names utilities
alias gfcopy='git diff --name-only | pbcopy'
alias gfshow='git diff --name-only'
alias gfscopy='git diff --staged --name-only | pbcopy'
alias gfsshow='git diff --staged --name-only'
gfpcopy() {
  if [ $# -eq 0 ]; then
    git diff --name-only HEAD~1 HEAD | pbcopy
    echo "Copied names of files changed in the last commit to clipboard"
  else
    git diff --name-only HEAD~$1 HEAD | pbcopy
    echo "Copied names of files changed in last $1 commit(s) to clipboard"
  fi
}
gfpshow() {
  if [ $# -eq 0 ]; then
    git diff --name-only HEAD~1 HEAD
  else
    git diff --name-only HEAD~$1 HEAD
  fi
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
  if [ $# -eq 0 ]; then
    git diff --name-only HEAD~1 HEAD | xargs cat | pbcopy
    echo "Copied content of files changed in the last commit to clipboard"
  else
    git diff --name-only HEAD~$1 HEAD | xargs cat | pbcopy
    echo "Copied content of files changed in last $1 commit(s) to clipboard"
  fi
}
gcpshow() {
  if [ $# -eq 0 ]; then
    git diff --name-only HEAD~1 HEAD | xargs cat
  else
    git diff --name-only HEAD~$1 HEAD | xargs cat
  fi
}
