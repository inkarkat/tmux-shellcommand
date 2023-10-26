#!/usr/bin/env bash

get_tmux_option() {
	local option="${1:?}"; shift
	local default_value="${1?}"; shift
	local isAllowEmpty="$1"; shift
	local option_value
	if ! option_value="$(tmux show-option -gv "$option" 2>/dev/null)"; then
	    # tmux fails if the user option is unset.
	    echo "$default_value"
	elif [ -z "$option_value" ] && [ "$isAllowEmpty" ]; then
	    # XXX: tmux 3.0a returns an empty string for a user option that is unset, but does not fail any longer.
	    tmux show-options -g | grep --quiet --fixed-strings --line-regexp "$option " && return
	    printf %s "$default_value"
	else
	    printf %s "${option_value:-$default_value}"
	fi
}

keydef()
{
    local table="$1"; shift
    local key="$1"; shift
    [ "$key" ] || return 0

    tmux bind-key ${table:+-T "$table"} "$key" "$@"
}

hasRecall=; type -t fzf-tmux >/dev/null && hasRecall=t
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
printf -v SCRIPTS_DIR_QUOTED %q "${CURRENT_DIR}/scripts"

HISTORY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux-shellcommand"
printf -v command_history_quoted %q "$(get_tmux_option '@shellcommand_command_history' "${HISTORY_DIR}/commands")"
printf -v output_history_quoted %q "$(get_tmux_option '@shellcommand_output_history' "${HISTORY_DIR}/outputs")"


shellcommand_key="$(get_tmux_option '@shellcommand_key' '~' t)"
shellcommand_table="$(get_tmux_option '@shellcommand_table' '' t)"
keydef "$shellcommand_table" "$shellcommand_key" \
    command-prompt -p '$' \
	"set -g @queried_command \"%%%\" ; run-shell \"${SCRIPTS_DIR_QUOTED}/shellcommand.sh ${hasRecall:+$command_history_quoted} ${hasRecall:+$output_history_quoted}\""


shellcommand_repeat_key="$(get_tmux_option '@shellcommand_repeat_key' '~' t)"
shellcommand_repeat_table="$(get_tmux_option '@shellcommand_repeat_table' 'gtable' t)"
keydef "$shellcommand_repeat_table" "$shellcommand_repeat_key" paste-buffer -b shellcommand

[ "$hasRecall" ] || exit
shellcommand_recall_command_key="$(get_tmux_option '@shellcommand_recall_command_key' '~' t)"
shellcommand_recall_command_table="$(get_tmux_option '@shellcommand_recall_command_table' 'Gtable' t)"
keydef "$shellcommand_recall_command_table" "$shellcommand_recall_command_key" \
    run-shell "tmux set-buffer -b shellcommand \"\$(${SCRIPTS_DIR_QUOTED}/recall.sh $command_history_quoted t)\"; tmux paste-buffer -b shellcommand 2>/dev/null || true"

shellcommand_recall_output_key="$(get_tmux_option '@shellcommand_recall_output_key' '~' t)"
shellcommand_recall_output_table="$(get_tmux_option '@shellcommand_recall_output_table' 'Mgtable' t)"
keydef "$shellcommand_recall_output_table" "$shellcommand_recall_output_key" \
    run-shell "tmux set-buffer -b shellcommand \"\$(${SCRIPTS_DIR_QUOTED}/recall.sh $output_history_quoted '')\"; tmux paste-buffer -b shellcommand 2>/dev/null || true"
