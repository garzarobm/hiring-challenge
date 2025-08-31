#!/usr/bin/env sh
set -eu

# Run the AWK script to find the longest Mars mission security code
LC_ALL=C ./find_mars_code.awk "${1:-space_missions.log}"
