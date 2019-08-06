# Tmux shellcommand

_Tmux plugin for inserting captured shell command output inside the current pane._

This plugin prompts for a Bash shell command(-line), executes that command, and inserts the captured command output inside the current pane. So this is like shell _command substitution_ (e.g. `echo $(date)`), but it can be inserted into _any_ running application, and is executed on the tmux server even if the pane is connected to a remote system (e.g. via SSH). The last output can be reinserted, and if _fzf_ is installed, any previous command and output can be recalled as well.

### Key bindings

- <kbd>prefix</kbd> <kbd>~</kbd> <br>
  Prompt for a shell command-line, and insert the captured (stdout and stderr) output inside the current pane. In the command-line, double quotes need to be escaped (`echo \"foo bar\"`).
- <kbd>prefix</kbd> <kbd>g</kbd> <kbd>~</kbd> <br>
  Insert the last captured output inside the current pane again.

If _fzf_ is installed, the following additional commands are available:
- <kbd>prefix</kbd> <kbd>G</kbd> <kbd>~</kbd> <br>
  Recall a command-line from any previously entered command-lines via fuzzy search. If one has been selected, re-execute the command and insert the captured output inside the current pane.
- <kbd>prefix</kbd> <kbd>Ctrl</kbd>+<kbd>g</kbd> <kbd>~</kbd> <br>
  Recall an output from any previously captured outputs via fuzzy search, and insert it inside the current pane.

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

### Dependencies

- Optional: [command-line fuzzy finder](https://github.com/junegunn/fzf) (in particular its `fzf-tmux` command) to recall any previous command-line / captured output

### Configuration

- `@shellcommand_command_history` &mdash; filespec (default `~/.local/share/tmux-shellcommand/commands`) where the entered command-lines are stored; if empty, nothing is stored
- `@shellcommand_output_history` &mdash; filespec (default `~/.local/share/tmux-shellcommand/output`) where the captured outputs are stored; if empty, nothing is stored
- `@shellcommand_key` &mdash; tmux key to which the main plugin functionality of prompting for a command-line is bound
- `@shellcommand_table` &mdash; tmux client key table for `@shellcommand_key`; you can use this to define a sequence of keys to trigger the command
- `@shellcommand_repeat_key` &mdash; tmux key for inserting the last captured output again
- `@shellcommand_repeat_table` &mdash; tmux client key table for `@shellcommand_repeat_key`; you can use this to define a sequence of keys to trigger the command; the default mappings require this definition: `bind-key g switch-client -T gtable`
- `@shellcommand_recall_command_key` &mdash; tmux key for recalling a command-line from any previously entered one via fuzzy search
- `@shellcommand_recall_command_table` &mdash; tmux client key table for `@shellcommand_recall_command_key`; you can use this to define a sequence of keys to trigger the command; the default mappings require this definition: `bind-key G switch-client -T Gtable`
- `@shellcommand_recall_output_key` &mdash; tmux key for recalling an output from any previously captured one via fuzzy search
- `@shellcommand_recall_output_table` &mdash; tmux client key table for `@shellcommand_recall_output_key`; you can use this to define a sequence of keys to trigger the command; the default mappings require this definition: `bind-key M-g switch-client -T Mgtable`

### License

[GPLv3](LICENSE)
