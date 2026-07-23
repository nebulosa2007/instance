#!/bin/env bash

# shellcheck source=/dev/null
source /etc/profile.d/instance.sh 2>/dev/null
: "${PATHINSTANCE:?Please set \$PATHINSTANCE env variable!}"

"$PATHINSTANCE"/scripts/tgsay.sh
