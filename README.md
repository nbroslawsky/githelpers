This repository contains a collection of helper functions and aliases that will hopefully make your git-driven life easier.

First, ```git clone git@git.corp.yahoo.com:nbroslaw/githelpers.git ~/githelpers```
After you set up your username and email globally, you'll have a .gitconfig file in your home directory:
```
git config --global user.name "Your Name"
git config --global user.email "youremail@yahoo-inc.com"
```

In that file, include the following (provided that you are using git 1.7.10+):
```
[include]
    path = ~/githelpers/gitconfig
```

Also, update your bash profile (~/.bash_profile) to include the init.sh script from this repo:
``` bash
source 'githelpers/init.sh'
```

From there, a really handy way of decorating your prompt is to include the information about the repository that is checked out (eg. which branch, if there are modified files waiting to be staged, if there are staged changes, rebasing/merging status, etc.). The following looks good on a darker background (the color aliases are defined in ```colors```).
``` bash
PS1="${YELLOW}\u@\h ${RESET}\W ${CYAN}\$(__git_ps1 '(%s) ')${RESET}\$ "
```

(if you already have your PS1 set up the way you like it, the important thing in there is to add ```${CYAN}\$(__git_ps1 '(%s) ')${RESET}``` somewhere inside of it)