# This repository contains a collection of helper functions and aliases that will hopefully make your git-driven life easier.

See gitconfig file for useful commands

## Setup Instructions for Zsh

1. Clone the githelpers repository:

    ```zsh
    git clone git@github.com:nbroslawsky/githelpers.git ~/githelpers
    ```

2. Set up your username and email globally. After doing so, you'll have a .gitconfig file in your home directory:

    ```zsh
    git config --global user.name "Your Name"
    git config --global user.email "youremail@yourdomain.com"
    ```

3. Allow git to pull our new configuration (provided that you are using git 1.7.10+):

    ```zsh
    git config --global include.path "~/githelpers/gitconfig"
    ```

4. Update your Zsh profile (~/.zshrc) to include the init.sh script from this repo:

    ```zsh
    echo 'source ~/githelpers/test.sh' >> ~/.zshrc
    ```

5. Optionally, enhance your prompt by including information about the repository that is checked out (e.g., branch, modifications, etc.). 

_PS1 is an environment variable in Unix-like operating systems, including Zsh, Bash, and other shells. It stands for "Prompt String 1" and defines the format of the primary prompt that appears in the command line. The contents of PS1 are used to customize how the shell prompt looks and what information it displays._

_The prompt is the text that appears in the terminal before the cursor, indicating that the shell is ready to accept input. By customizing PS1, you can control the appearance of this prompt, including adding colors, displaying information about the current working directory, showing the username, hostname, and more._

_For example, the PS1 setting: `PS1="%n@%m %1~ $ "`
Breaks down as follows:
```
%n: username.
%m: machine name (hostname).
%1~: abbreviated current working directory.
$: the prompt symbol.
```

   The following example looks good on a darker background (color aliases are defined in `colors`):

    ```zsh
    PS1="${YELLOW}%n@%m ${RESET}%1~ ${CYAN}\$(__git_ps1 '(%s) ')${RESET}\$ "
    ```

   If you already have your PS1 set up the way you like it, the important thing is to add `${CYAN}\$(__git_ps1 '(%s) ')${RESET}` somewhere inside it.
