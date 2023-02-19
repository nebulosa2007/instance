#!/bin/bash

OLDLOG=$HOME/.cache/oldjournal.log
NOWLOG=$HOME/.cache/journal.log

JRNLLOG=$(journalctl --no-pager -b0 -p4 | cut -d" " -f5- | grep -Ev "(rotating|TSC)")
echo "$JRNLLOG" | sort > $NOWLOG

NOWDIFF=$(diff $OLDLOG $NOWLOG  | grep -E '^>')

if [ "$NOWDIFF"  != "" ]
then
	echo -n "Changes in system journal:"
	echo $NOWDIFF | tr ">" "\n"
	#cp $OLDLOG $OLDLOG.backup
	echo "$JRNLLOG" | sort > $OLDLOG
fi
