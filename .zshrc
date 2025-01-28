# Enable Powerlevel10k instant prompt
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source all .zsh files in the ~/.zsh directory, except plugins.zsh
for config_file (~/.zsh/*.zsh(N)); do
  if [[ $config_file != *plugins.zsh ]]; then
    source $config_file
  fi
done

# Source all .zsh files in the ~/.zsh/tools directory
for tool_file (~/.zsh/tools/*.zsh); do
  source $tool_file
done

# Source plugins.zsh after instant prompt initialization
source ~/.zsh/plugins.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH="/usr/local/bin:$PATH"

# if ping -c 1 google.com &> /dev/null; then
#     kitty +kitten themes --reload-in=all Catppuccin-Frappe
# fi
# export PATH="$HOME/.rbenv/shims:$PATH"
# eval "$(rbenv init -)"
# export PATH=$PATH:/opt/X11/bin
# # Start clipper if it's not already running
# if ! brew services list | grep clipper | grep started > /dev/null; then
#     brew services start clipper
# fi
#

export EDITOR=nvim
# Add to ~/.zshrc:
[ -f $HOMEBREW_PREFIX/share/forgit/forgit.plugin.zsh ] && source $HOMEBREW_PREFIX/share/forgit/forgit.plugin.zsh

compdef _git_diff forgit::diff


