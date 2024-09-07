# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source all .zsh files in the ~/.zsh directory
for config_file (~/.zsh/*.zsh); do
  source $config_file
done

# Source all .zsh files in the ~/.zsh/tools directory
for tool_file (~/.zsh/tools/*.zsh); do
  source $tool_file
done

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="/opt/homebrew/bin:$PATH"
