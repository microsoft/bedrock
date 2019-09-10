#!/bin/bash
IDENTITY_ID=$1
WAIT_TIME_SECONDS=2
TIMEOUT_SECONDS=360

FOUND=0
echo "waiting for identity to propagate -- $IDENTITY_ID"
while true; do
    result=$( az ad sp show --id $1 2>&1 1>/dev/null )
    echo "$result"
    if [[ $? -eq 0 ]] || [[ "$result" == "Insufficient privileges to complete the operation." ]]; then
        FOUND=1
	break
    fi
    TIMEOUT_SECONDS="$(($TIMEOUT_SECONDS-$WAIT_TIME_SECONDS))"
    if [ $TIMEOUT_SECONDS -le 0 ]; then
        break;
    fi
    sleep $WAIT_TIME_SECONDS
done

if [ $FOUND -eq 0 ]; then
    echo "waiting for identity timed out - $IDENTITY_ID"
    exit 1
fi

exit 0
