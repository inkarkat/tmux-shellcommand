#!/usr/bin/env bash

fail() {
    tmux display-message "ERROR: tmux-shellcommand ${1:-encountered an unspecified problem.}"
    exit 3
}

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

readonly projectDir="$([ "${BASH_SOURCE[0]}" ] && cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
[ -d "$projectDir" ] || fail 'cannot determine script directory!'
printf -v quotedScriptDir '%q' "${projectDir}/scripts"

readonly historyDirspec="${XDG_DATA_HOME:-$HOME/.local/share}/tmux-shellcommand"
[ -d "$historyDirspec" ] || mkdir --parents -- "$historyDirspec" || fail "cannot initialize data store at $historyDirspec"
printf -v quotedCommandHistory %q "$(get_tmux_option '@shellcommand_command_history' "${historyDirspec}/commands")"
printf -v quotedOutputHistory %q "$(get_tmux_option '@shellcommand_output_history' "${historyDirspec}/outputs")"


shellcommand_key="$(get_tmux_option '@shellcommand_key' '~' t)"
shellcommand_table="$(get_tmux_option '@shellcommand_table' '' t)"
keydef "$shellcommand_table" "$shellcommand_key" \
    command-prompt -p '$' \
	"set -g @queried_command \"%%%\" ; run-shell \"${quotedScriptDir}/shellcommand.sh ${hasRecall:+$quotedCommandHistory} ${hasRecall:+$quotedOutputHistory}\""


shellcommand_repeat_key="$(get_tmux_option '@shellcommand_repeat_key' '~' t)"
shellcommand_repeat_table="$(get_tmux_option '@shellcommand_repeat_table' 'gtable' t)"
keydef "$shellcommand_repeat_table" "$shellcommand_repeat_key" paste-buffer -b shellcommand

[ "$hasRecall" ] || exit
shellcommand_recall_command_key="$(get_tmux_option '@shellcommand_recall_command_key' '~' t)"
shellcommand_recall_command_table="$(get_tmux_option '@shellcommand_recall_command_table' 'Gtable' t)"
keydef "$shellcommand_recall_command_table" "$shellcommand_recall_command_key" \
    run-shell -b "tmux set-buffer -b shellcommand \"\$(${quotedScriptDir}/recall.sh $quotedCommandHistory t)\"; tmux paste-buffer -b shellcommand 2>/dev/null || true"

shellcommand_recall_output_key="$(get_tmux_option '@shellcommand_recall_output_key' '~' t)"
shellcommand_recall_output_table="$(get_tmux_option '@shellcommand_recall_output_table' 'Mgtable' t)"
keydef "$shellcommand_recall_output_table" "$shellcommand_recall_output_key" \
    run-shell -b "tmux set-buffer -b shellcommand \"\$(${quotedScriptDir}/recall.sh $quotedOutputHistory '')\"; tmux paste-buffer -b shellcommand 2>/dev/null || true"
