#!/usr/bin/env bash

historyFilespec="${1:?}"; shift
isReexecute="${1?}"; shift

if ! recalled="$(fzf-tmux < "$historyFilespec")"; then
    # As the pasting is unconditional, clear the paste buffer to avoid that the
    # previous results are pasted again.
    tmux delete-buffer -b shellcommand
    exit 0
fi

if [ "$isReexecute" ]; then
    eval "$(echo -en "${recalled/#-/\x2d}")"
else
    echo -en "${recalled/#-/\x2d}"
fi
