#!/usr/bin/env bash

historyFilespec="${1:?}"; shift
isReexecute="${1?}"; shift

echo "****" "$historyFilespec" "$isReexecute"
