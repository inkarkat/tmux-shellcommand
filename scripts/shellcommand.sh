#!/bin/bash

capturedOutput="$(eval "$@" 2>&1)"
tmux set-buffer -b shellcommand "$capturedOutput" \; paste-buffer -b shellcommand
