#!/usr/bin/env bash

commandHistory="${1?}"; shift
outputHistory="${1?}"; shift

capturedOutput="$(eval "$@" 2>&1)"
exec tmux set-buffer -b shellcommand "$capturedOutput" \; paste-buffer -b shellcommand
