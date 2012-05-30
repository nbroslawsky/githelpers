Here is an example prompt with coloring. Put this in your ~/.bash_profile, and feel free to modify the colors to work with your terminal (This works well for a dark background)

```
# git_bin is the suggested folder for checking this code out
source 'git_bin/init.sh'
PS1="${YELLOW}\u@\h ${RESET}\W ${CYAN}\$(__git_ps1 '(%s) ')${RESET}\$ "
```
