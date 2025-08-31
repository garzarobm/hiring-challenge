#!/usr/bin/env sh
set -eu

# Enhanced AWK Analysis Runner for Warp Hiring Challenge
# Finds the longest Mars mission security code with comprehensive analysis options
#
# Usage: ./run.sh [OPTIONS] [logfile]
# 
# OPTIONS:
#   help, -h, --help     Show this help message
#   answer               Show just the answer (default)
#   verbose              Show detailed analysis
#   analysis             Show comprehensive mission analysis
#   top10                Show top 10 longest missions
#   challenge            Show challenge-specific analysis
#   all                  Show everything (verbose + analysis + top missions)
#
# EXAMPLES:
#   ./run.sh                           # Just the answer: XRT-421-ZQP
#   ./run.sh answer                    # Same as above with clear formatting
#   ./run.sh verbose ../space_missions.log  # Detailed analysis
#   ./run.sh analysis                  # Comprehensive mission statistics
#   ./run.sh top10                     # Top 10 longest missions
#   ./run.sh challenge                 # Challenge-specific breakdown
#   ./run.sh all                       # Complete analysis

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Default values
MODE=${1:-answer}
LOGFILE=${2:-../space_missions.log}

# Determine script directory for proper AWK script path
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AWK_SCRIPT="$SCRIPT_DIR/find_mars_code_pro.awk"

# Function to print colored output
print_header() {
    printf "\033[1m\033[0;34m%s\033[0m\n" "$1"
    printf "\033[0;34m%s\033[0m\n" "$(echo "$1" | sed 's/./=/g')"
}

print_answer() {
    printf "\033[1m\033[0;32m%s\033[0m\n" "$1"
}

print_section() {
    printf "\n\033[1m\033[0;36m%s\033[0m\n" "$1"
    printf "\033[0;36m%s\033[0m\n" "$(echo "$1" | sed 's/./-/g')"
}

# Function to show help
show_help() {
    echo "Enhanced AWK Analysis Runner for Warp Hiring Challenge"
    echo "Finds the longest Mars mission security code with comprehensive analysis"
    echo ""
    echo "Usage: $0 [OPTIONS] [logfile]"
    echo ""
    echo "OPTIONS:"
    echo "  help, -h, --help     Show this help message"
    echo "  answer               Show just the answer (default)"
    echo "  verbose              Show detailed analysis with statistics"
    echo "  analysis             Show comprehensive mission analysis"
    echo "  top10                Show top 10 longest missions"
    echo "  challenge            Show challenge-specific analysis"
    echo "  all                  Show everything (verbose + analysis + top missions)"
    echo ""
    echo "EXAMPLES:"
    echo "  $0                           # Just the answer: XRT-421-ZQP"
    echo "  $0 answer                    # Same as above with clear formatting"
    echo "  $0 verbose ../space_missions.log  # Detailed analysis"
    echo "  $0 analysis                  # Comprehensive mission statistics"
    echo "  $0 top10                     # Top 10 longest missions"
    echo "  $0 challenge                 # Challenge-specific breakdown"
    echo "  $0 all                       # Complete analysis"
    echo ""
    echo "Default logfile: ../space_missions.log"
}

# Function to run analysis
run_analysis() {
    local mode=$1
    local logfile=$2
    
    case $mode in
        "help"|"--help"|"-h")
            show_help
            ;;
        "answer")
            print_header "WARP HIRING CHALLENGE - MARS MISSION ANALYSIS"
            printf "\033[1mChallenge:\033[0m Find the security code of the longest Mars mission\n"
            printf "\033[1mDataset:\033[0m %s\n" "$logfile"
            echo ""
            
            print_section "ANSWER"
            local answer=$(LC_ALL=C "$AWK_SCRIPT" "$logfile")
            print_answer "Security Code: $answer"
            
            echo ""
            printf "\033[1mFor External Coders:\033[0m\n"
            echo "• This is the security code of the Mars mission with the longest duration"
            echo "• The code was extracted from a dataset of 105,032 space missions"
            echo "• Analysis performed using optimized AWK processing"
            echo ""
            printf "\033[1mUsage:\033[0m Run './run.sh verbose' for detailed analysis\n"
            ;;
        "verbose")
            print_header "VERBOSE MARS MISSION ANALYSIS"
            LC_ALL=C "$AWK_SCRIPT" -v verbose=1 "$logfile"
            ;;
        "analysis")
            print_header "COMPREHENSIVE MISSION ANALYSIS"
            LC_ALL=C "$AWK_SCRIPT" -v format=table -v top=15 -v verbose=1 "$logfile"
            ;;
        "top10")
            print_header "TOP 10 LONGEST MISSIONS"
            print_section "Mission Rankings by Duration"
            LC_ALL=C "$AWK_SCRIPT" -v format=table -v top=10 "$logfile"
            ;;
        "challenge")
            print_header "WARP HIRING CHALLENGE - COMPREHENSIVE BREAKDOWN"
            
            print_section "Challenge Requirements"
            echo "• Find the Mars mission with the longest duration"
            echo "• Extract the security code from that mission"
            echo "• Process dataset: $logfile"
            
            print_section "Solution Analysis"
            LC_ALL=C "$AWK_SCRIPT" -v verbose=1 "$logfile"
            
            print_section "Top Mars Missions by Duration"
            LC_ALL=C "$AWK_SCRIPT" -v format=table -v top=5 "$logfile"
            
            print_section "Dataset Statistics"
            LC_ALL=C "$AWK_SCRIPT" -v format=json -v verbose=1 "$logfile" | grep -E '(total_missions|mars_missions|processing_time)'
            ;;
        "all")
            print_header "COMPLETE MARS MISSION ANALYSIS SUITE"
            
            print_section "1. Challenge Answer"
            local answer=$(LC_ALL=C "$AWK_SCRIPT" "$logfile")
            print_answer "Security Code: $answer"
            
            print_section "2. Detailed Analysis"
            LC_ALL=C "$AWK_SCRIPT" -v verbose=1 "$logfile"
            
            print_section "3. Top 15 Longest Missions"
            LC_ALL=C "$AWK_SCRIPT" -v format=table -v top=15 "$logfile"
            
            print_section "4. JSON Export Data"
            LC_ALL=C "$AWK_SCRIPT" -v format=json -v top=5 "$logfile"
            
            print_section "5. CSV Export Sample"
            echo "Mission ID,Destination,Duration (days),Launch Date,Status,Security Code"
            LC_ALL=C "$AWK_SCRIPT" -v format=csv -v top=3 "$logfile" | tail -n +2
            ;;
        *)
            echo "Error: Unknown option '$mode'"
            echo "Run '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Validate logfile exists
if [ ! -f "$LOGFILE" ]; then
    printf "\033[0;31mError: Logfile not found: %s\033[0m\n" "$LOGFILE"
    echo "Please ensure the dataset exists or provide a valid path"
    exit 1
fi

# Run the analysis
run_analysis "$MODE" "$LOGFILE"
