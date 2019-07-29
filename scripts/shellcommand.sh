#!/usr/bin/env bash

commandHistory="${1?}"; shift
outputHistory="${1?}"; shift
if [ $# -eq 0 -o "$1" = '-' ]; then
    shellcommand="$(< /dev/stdin)"
else
    shellcommand="${1?}"; shift
fi
[ "$shellcommand" ] || exit 0

escapeNewline()
{
    sed ':a; s/\\/\\\\/g; x; G; 1s/\n//; s/\n/\\n/; h; N; s/.*\n//; ta' <<<"${1:?}"
}
storeHistory()
{
    [ -n "$1" -a -n "$2" ] && printf '%s\n' "$(escapeNewline "$2")" >> "$1"
}

capturedOutput="$(eval "$shellcommand" 2>&1)"
storeHistory "$commandHistory" "$shellcommand"
storeHistory "$outputHistory" "$capturedOutput"

if [ -z "$capturedOutput" ]; then
    exec tmux display-message 'No output'
else
    exec tmux set-buffer -b shellcommand "$capturedOutput" \; paste-buffer -b shellcommand
fi
