#!/usr/bin/env bash

hasRecall=; type -t fzf-tmux >/dev/null && hasRecall=t
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
printf -v SCRIPTS_DIR_QUOTED %q "${CURRENT_DIR}/scripts"

HISTORY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux-shellcommand"
default_command_history="${HISTORY_DIR}/commands"
command_history="$(tmux show-option -gqv '@shellcommand_command_history')"
printf -v command_history_quoted %q "${command_history:-$default_command_history}"
default_output_history="${HISTORY_DIR}/outputs"
output_history="$(tmux show-option -gqv '@shellcommand_output_history')"
printf -v output_history_quoted %q "${output_history:-$default_output_history}"


default_shellcommand_key='~'
shellcommand_key="$(tmux show-option -gqv '@shellcommand_key')"
shellcommand_key="${shellcommand_key:-$default_shellcommand_key}"
default_shellcommand_table=''
shellcommand_table="$(tmux show-option -gqv '@shellcommand_table')"
shellcommand_table="${shellcommand_table:-$default_shellcommand_table}"
# XXX: tmux doesn't offer shell escaping for the prompt responses, so handling
# of quoting is difficult. Best we can do is embedding the response in a literal
# here-document; this preserves single quotes. Double-quotes have to be manually
# escaped, presumably because of the run-shell wrapper: $ echo \"foo bar\"
tmux bind-key ${shellcommand_table:+-T "$shellcommand_table"} "$shellcommand_key" \
    command-prompt -p '$' "run-shell \"${SCRIPTS_DIR_QUOTED}/shellcommand.sh ${hasRecall:+$command_history_quoted} ${hasRecall:+$output_history_quoted} <<'EOF'
%1
EOF
\""


default_shellcommand_repeat_key='~'
shellcommand_repeat_key="$(tmux show-option -gqv '@shellcommand_repeat_key')"
shellcommand_repeat_key="${shellcommand_repeat_key:-$default_shellcommand_repeat_key}"
default_shellcommand_repeat_table='gtable'
shellcommand_repeat_table="$(tmux show-option -gqv '@shellcommand_repeat_table')"
shellcommand_repeat_table="${shellcommand_repeat_table:-$default_shellcommand_repeat_table}"
tmux bind-key ${shellcommand_repeat_table:+-T "$shellcommand_repeat_table"} "$shellcommand_repeat_key" paste-buffer -b shellcommand

[ "$hasRecall" ] || exit
default_shellcommand_recall_command_key='~'
shellcommand_recall_command_key="$(tmux show-option -gqv '@shellcommand_recall_command_key')"
shellcommand_recall_command_key="${shellcommand_recall_command_key:-$default_shellcommand_recall_command_key}"
default_shellcommand_recall_command_table='Gtable'
shellcommand_recall_command_table="$(tmux show-option -gqv '@shellcommand_recall_command_table')"
shellcommand_recall_command_table="${shellcommand_recall_command_table:-$default_shellcommand_recall_command_table}"
tmux bind-key ${shellcommand_recall_command_table:+-T "$shellcommand_recall_command_table"} "$shellcommand_recall_command_key" \
    run-shell "tmux set-buffer -b shellcommand \"\$(${SCRIPTS_DIR_QUOTED}/recall.sh $command_history_quoted t)\"; tmux paste-buffer -b shellcommand 2>/dev/null || true"

default_shellcommand_recall_output_key='~'
shellcommand_recall_output_key="$(tmux show-option -gqv '@shellcommand_recall_output_key')"
shellcommand_recall_output_key="${shellcommand_recall_output_key:-$default_shellcommand_recall_output_key}"
default_shellcommand_recall_output_table='Mgtable'
shellcommand_recall_output_table="$(tmux show-option -gqv '@shellcommand_recall_output_table')"
shellcommand_recall_output_table="${shellcommand_recall_output_table:-$default_shellcommand_recall_output_table}"
tmux bind-key ${shellcommand_recall_output_table:+-T "$shellcommand_recall_output_table"} "$shellcommand_recall_output_key" \
    run-shell "tmux set-buffer -b shellcommand \"\$(${SCRIPTS_DIR_QUOTED}/recall.sh $output_history_quoted '')\"; tmux paste-buffer -b shellcommand 2>/dev/null || true"
