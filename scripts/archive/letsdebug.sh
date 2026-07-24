#!/bin/env bash

set -xveou pipefail

PS4='\033[0;33mLine ${LINENO}:\033[0m ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
