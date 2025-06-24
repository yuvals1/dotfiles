# Set up cd alias after zoxide is initialized
# Only alias cd to z if we're in an interactive shell with zoxide available
if [[ $- == *i* ]] && command -v z &> /dev/null; then
    alias cd='z'
fi