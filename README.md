# Tmux shellcommand

This plugin prompts for a Bash shell commandline when triggered, executes that command, and inserts the captured command output inside the current pane. So this is like shell _command substitution_ (e.g. `echo $(date)`), but it can be inserted into _any_ running application, and is executed on the tmux server even if the pane is connected to a remote system (e.g. via SSH). The last output can be reinserted, and if _fzf_ is installed, previous commands and outputs can be recalled as well.
