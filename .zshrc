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

kitty +kitten themes --reload-in=all Catppuccin-Frappe

# export PATH="$HOME/.rbenv/shims:$PATH"
# eval "$(rbenv init -)"
# export PATH=$PATH:/opt/X11/bin
# # Start clipper if it's not already running
# if ! brew services list | grep clipper | grep started > /dev/null; then
#     brew services start clipper
# fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export EDITOR=nvim
