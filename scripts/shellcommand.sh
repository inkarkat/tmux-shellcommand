#!/usr/bin/env bash

commandHistory="${1?}"; shift
outputHistory="${1?}"; shift
if [ $# -eq 0 -o "$1" = '-' ]; then
    shellcommand="$(< /dev/stdin)"
else
    shellcommand="${1?}"; shift
fi
[ "$shellcommand" ] || exit 0

capturedOutput="$(eval "$shellcommand" 2>&1)"

if [ -n "$commandHistory" -o -n "$outputHistory" ]; then
    escapeNewline()
    {
	sed ':a; s/\\/\\\\/g; x; G; 1s/\n//; s/\n/\\n/; h; N; s/.*\n//; ta' <<<"${1:?}"
    }
    storeHistory()
    {
	if [ -n "$1" -a -n "$2" ]; then
	    printf '%s\n' "$(escapeNewline "$2")" >> "$1"
	    if [ "$history_size" ]; then
		TMPFILE="$(mktemp --tmpdir "$(basename -- "$0")-XXXXXX" 2>/dev/null || echo "${TEMP:-/tmp}/$(basename -- "$0").$$$RANDOM")"
		tail -n "$history_size" "$1" > "$TMPFILE" && cp --force -- "$TMPFILE" "$1" && rm -- force -- "$TMPFILE"
	    fi
	fi
    }

    default_history_size=100
    history_size="$(tmux show-option -gqv '@shellcommand_history_size')"
    history_size="${history_size-$default_history_size}"

    storeHistory "$commandHistory" "$shellcommand"
    storeHistory "$outputHistory" "$capturedOutput"
fi

if [ -z "$capturedOutput" ]; then
    exec tmux display-message 'No output'
else
    exec tmux set-buffer -b shellcommand "$capturedOutput" \; paste-buffer -b shellcommand
fi
