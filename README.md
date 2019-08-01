# Tmux shellcommand

This plugin prompts for a Bash shell command(-line), executes that command, and inserts the captured command output inside the current pane. So this is like shell _command substitution_ (e.g. `echo $(date)`), but it can be inserted into _any_ running application, and is executed on the tmux server even if the pane is connected to a remote system (e.g. via SSH). The last output can be reinserted, and if _fzf_ is installed, any previous command and output can be recalled as well.

### Key bindings

- <kbd>prefix</kbd> <kbd>~</kbd> Prompt for a shell command-line, and insert the captured (stdout and stderr) output inside the current pane. In the command-line, double quotes need to be escaped (`echo \"foo bar\"`).
- <kbd>prefix</kbd> <kbd>g</kbd> <kbd>~</kbd> Insert the last captured output inside the current pane again.

If _fzf_ is installed, the following additional commands are available:
- <kbd>prefix</kbd> <kbd>G</kbd> <kbd>~</kbd> Recall a command-line from any previously entered command-lines via fuzzy search. If one has been selected, re-execute the command and insert the captured output inside the current pane.
- <kbd>prefix</kbd> <kbd>Ctrl</kbd>+<kbd>g</kbd> <kbd>~</kbd> Recall an output from any previously captured outputs via fuzzy search, and insert it inside the current pane.

### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

Add plugin to the list of TPM plugins in `.tmux.conf`:

    set -g @plugin 'inkarkat/tmux-shellcommand'

Hit `prefix + I` to fetch the plugin and source it. You should now be able to use the plugin.

### Manual Installation

Clone the repo:

    $ git clone https://github.com/inkarkat/tmux-shellcommand ~/clone/path

Add this line to the bottom of `.tmux.conf`:

    run-shell ~/clone/path/shellcommand.tmux

Reload tmux environment with: `$ tmux source-file ~/.tmux.conf`. You should now be able to use the plugin.

### License

[GPLv3](LICENSE)
