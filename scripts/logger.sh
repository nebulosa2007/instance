#!/bin/env bash

# https://wiki.archlinux.org/title/Systemd/Journal#Priority_level
## From 0: Emergency, 1: Alert, 2: Critical, 3: Error, 4: Warning, 5: Notice, 6: Informational, 7: Debug
LEVELTILL=3
SKIPWORDS="(TSC)"


OLDLOG=$HOME/.cache/oldjournal.log
NOWLOG=$HOME/.cache/journal.log

[ -z "$OLDLOG" ] || touch "$OLDLOG"

JRNLLOG=$(journalctl --no-pager -b0 -p"$LEVELTILL" | cut -d" " -f5- | grep -Ev "$SKIPWORDS")
echo "$JRNLLOG" | sort | uniq -u > "$NOWLOG"

NOWDIFF=$(diff "$OLDLOG" "$NOWLOG"  | grep -E '^>')

if [ "$NOWDIFF"  != "" ]
then
    echo -n " Changes in system journal:"
    echo "$NOWDIFF" | tr ">" "\n" | sed -E 's/\[[0-9]+\]//g;s/ *$//g' | sort | uniq
    #cp $OLDLOG $OLDLOG.backup
    echo "$JRNLLOG" | sort |uniq -u > "$OLDLOG"
fi
