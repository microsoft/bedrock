#!/usr/bin/env bash

# Note: the omission of the `pipefail` flag is intentional. It allows this
#       step to succeede in the case that there are no `*.go` files in the 
#       infrastructure repository.
set -euox

echo "Linting Go Files... If this fails, run 'go fmt ./...' to fix"

# This runs a go fmt on each file without using the 'go fmt ./...' syntax.
# This is advantageous because it avoids having to download all of the go
# dependencies that would have been triggered by using the './...' syntax.
FILES_WITH_FMT_ISSUES=$(find . -name "*.go" | grep -v '.terraform' | xargs gofmt -l | wc -l)

# convert to integer...
FILES_WITH_FMT_ISSUES=$(($FILES_WITH_FMT_ISSUES + 0))

# set exit code accordingly
exit $FILES_WITH_FMT_ISSUES
