#!/usr/bin/env bash

commandHistoryFilespec="${1?}"; shift
outputHistory="${1?}"; shift
if [ $# -eq 0 ]; then
    shellcommand="$(tmux show-options -gv @queried_command)"
elif [ "$1" = '-' ]; then
    shellcommand="$(< /dev/stdin)"
else
    shellcommand="${1?}"; shift
fi
[ -n "$shellcommand" ] || exit 99

workingDirspec="$(tmux display-message -p "#{pane_current_path}")"
capturedOutput="$(cd "$workingDirspec" && eval "$shellcommand" 2>&1)"

if [ -n "$commandHistoryFilespec" -o -n "$outputHistory" ]; then
    escapeNewline()
    {
	sed ':a; s/\\/\\\\/g; x; G; 1s/\n//; s/\n/\\n/; h; N; s/.*\n//; ta' <<<"${1:?}"
    }
    storeHistory()
    {
	local filespec="${1?}"; shift
	local output="${1?}"; shift

	if [ -n "$filespec" -a -n "$output" ]; then
	    printf '%s\n' "$(escapeNewline "$output")" >> "$filespec"

	    if [ -n "$history_size" ]; then
		TMPFILE="$(mktemp --tmpdir "$(basename -- "$0")-XXXXXX" 2>/dev/null || echo "${TMPDIR:-/tmp}/$(basename -- "$0").$$$RANDOM")"
		tail -n "$history_size" "$1" > "$TMPFILE" \
		    && cp --force -- "$TMPFILE" "$filespec" \
		    && rm -- force -- "$TMPFILE"
	    fi
	fi
    }

    default_history_size=100
    history_size="$(tmux show-option -gv '@shellcommand_history_size' 2>/dev/null)"
    history_size="${history_size:-$default_history_size}"

    storeHistory "$commandHistoryFilespec" "$shellcommand"
    storeHistory "$outputHistory" "$capturedOutput"
fi

if [ -z "$capturedOutput" ]; then
    exec tmux display-message 'No output'
else
    exec tmux set-buffer -b shellcommand "$capturedOutput" \; paste-buffer -b shellcommand
fi
