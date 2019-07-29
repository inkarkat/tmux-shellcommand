#!/usr/bin/env bash

commandHistory="${1?}"; shift
outputHistory="${1?}"; shift
shellcommand="${1?}"; shift
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

exec tmux set-buffer -b shellcommand "$capturedOutput" \; paste-buffer -b shellcommand
