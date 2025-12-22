# Fix nvim-treesitter (from claude jetson18 dotfiles dir)

## The Problem
Your config uses the old API (`require('nvim-treesitter.configs')`).
This only exists on `master` branch, not `main`.

## Check
```bash
cd ~/.local/share/nvim/lazy/nvim-treesitter && git branch
```
Should show `* master`.

## Fix
Option 1 - Use lazy:
```
:Lazy restore nvim-treesitter
```

Option 2 - Manual:
```bash
cd ~/.local/share/nvim/lazy/nvim-treesitter
git checkout master
git pull origin master
```

Option 3 - Fresh install:
```bash
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter
# restart nvim
```
