# A Jetson login starts in its repo when sshd or `su -` places it in $HOME.
# Preserve explicit working directories, nested shells, and non-Jetson hosts.
if [[ -o interactive && -o login && -f /etc/nv_tegra_release \
      && "$PWD" == "$HOME" && -d "$HOME/robopilot" ]]; then
  builtin cd -- "$HOME/robopilot"
fi
