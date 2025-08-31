#!/usr/bin/env sh
set -eu

# Run the AWK script to find the longest Mars mission security code
# Usage: ./run.sh [verbose_level] [logfile]
# verbose_level: 0=silent, 1=summary, 2=missions, 3=debug (default: 0)
# logfile: path to space missions log (default: space_missions.log)

VERBOSE=${1:-0}
LOGFILE=${2:-../space_missions.log}

if [ "$VERBOSE" -eq 0 ]; then
    LC_ALL=C ./find_mars_code_pro.awk "$LOGFILE"
else
    LC_ALL=C ./find_mars_code_pro.awk -v verbose="$VERBOSE" "$LOGFILE"
fi
