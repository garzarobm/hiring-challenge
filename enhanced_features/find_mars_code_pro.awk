#!/usr/bin/env awk -f

# Professional Mars Mission Security Code Finder
# Version: 3.0 - Fully compatible with macOS system AWK
# Enhanced features with multiple output formats and comprehensive analysis
# 
# Usage: ./find_mars_code_pro.awk [-v option=value] space_missions.log
# 
# Options:
#   verbose=0      Silent mode (default - only outputs security code)
#   verbose=1      Summary statistics  
#   verbose=2      Show each mission found + detailed analysis
#   verbose=3      Debug mode with parsing details
#   format=text    Default format (security code only)
#   format=json    Output results in JSON format
#   format=csv     Output results in CSV format  
#   format=table   Output results in formatted table
#   top=N          Show top N longest missions (default: 1)
#   destination=X  Filter by destination (default: mars)
#   status=X       Filter by status (default: completed)
#   showstats=1    Show destination and status statistics

BEGIN {
    # Field separator for pipe-delimited data with variable whitespace
    FS = "[[:space:]]*\\|[[:space:]]*"
    
    # Set defaults
    if (!verbose) verbose = 0
    if (!format) format = "text"
    if (!top) top = 1
    if (!destination) destination = "mars"
    if (!status) status = "completed"
    if (!showstats) showstats = 0
    
    # Initialize tracking variables
    max_duration = -1
    max_code = ""
    mission_count = 0
    
    # Line counters
    total_lines = 0
    comment_lines = 0
    header_lines = 0
    invalid_lines = 0
    valid_data_lines = 0
    target_missions = 0
    completed_target = 0
    
    # Arrays for storing mission data (using simple indexed arrays)
    delete mission_dates
    delete mission_ids
    delete mission_durations
    delete mission_codes
    delete mission_crews
    delete mission_rates
    delete mission_lines
    
    # Statistics tracking
    delete destinations
    delete statuses
    
    if (verbose >= 1) {
        print "[INFO] Professional Mars Mission Analysis v3.0" > "/dev/stderr"
        print "[INFO] Target: " destination " missions with " status " status" > "/dev/stderr"
        print "[INFO] Output format: " format > "/dev/stderr"
        print "[INFO] Top missions to show: " top > "/dev/stderr"
        print "[INFO] Starting analysis..." > "/dev/stderr"
    }
}

# Process each line
{
    # Remove Windows line endings
    sub(/\r$/, "", $0)
    total_lines++
    
    # Progress indicator for large files
    if (verbose >= 3 && total_lines % 20000 == 0) {
        print "[DEBUG] Processed " total_lines " lines..." > "/dev/stderr"
    }
}

# Skip comment lines and blank lines
/^[[:space:]]*#/ || /^[[:space:]]*$/ {
    comment_lines++
    if (verbose >= 3) {
        print "[DEBUG] Line " NR ": Skipping comment/blank" > "/dev/stderr"
    }
    next
}

# Skip header lines that contain "Date" in first field
$1 ~ /Date/ {
    header_lines++
    if (verbose >= 3) {
        print "[DEBUG] Line " NR ": Skipping header" > "/dev/stderr"
    }
    next
}

# Process valid data lines (must have at least 8 fields)
NF >= 8 {
    valid_data_lines++
    
    # Extract fields
    date = $1
    mission_id = $2
    dest = $3
    stat = $4
    crew = $5
    duration_raw = $6
    success_rate = $7
    security_code = $8
    
    # Clean whitespace from all fields
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", date)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", mission_id)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", dest)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", stat)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", crew)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", duration_raw)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", success_rate)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", security_code)
    
    # Track statistics for all missions
    if (showstats || verbose >= 2) {
        destinations[tolower(dest)]++
        statuses[tolower(stat)]++
    }
    
    # Count missions to our target destination
    if (tolower(dest) == tolower(destination)) {
        target_missions++
        if (verbose >= 3) {
            print "[DEBUG] Line " NR ": Found " destination " mission " mission_id " status: " stat > "/dev/stderr"
        }
    }
    
    # Apply filters: destination and status
    if (tolower(dest) != tolower(destination)) next
    if (tolower(stat) != tolower(status)) next
    
    completed_target++
    
    # Extract numeric duration from potentially mixed text
    duration = 0
    if (match(duration_raw, /[0-9]+(\.[0-9]+)?/)) {
        duration = substr(duration_raw, RSTART, RLENGTH) + 0
    } else {
        if (verbose >= 2) {
            print "[WARN] Line " NR ": Cannot parse duration '" duration_raw "'" > "/dev/stderr"
        }
        next
    }
    
    if (verbose >= 2) {
        printf "[INFO] %s mission: %s (%d days) crew=%s rate=%s code=%s\n", destination, mission_id, duration, crew, success_rate, security_code > "/dev/stderr"
    }
    
    # Store this mission's data
    mission_count++
    mission_dates[mission_count] = date
    mission_ids[mission_count] = mission_id
    mission_durations[mission_count] = duration
    mission_codes[mission_count] = security_code
    mission_crews[mission_count] = crew
    mission_rates[mission_count] = success_rate
    mission_lines[mission_count] = NR
    
    # Track maximum for backward compatibility
    if (duration > max_duration) {
        max_duration = duration
        max_code = security_code
        max_mission_line = NR
        max_mission_id = mission_id
        max_mission_date = date
        
        # Clean security code to extract ABC-123-XYZ pattern
        if (match(max_code, /[A-Z]{3}-[0-9]{3}-[A-Z]{3}/)) {
            max_code = substr(max_code, RSTART, RLENGTH)
        }
        
        if (verbose >= 2) {
            print "[INFO] New longest " destination " mission: " max_mission_id " (" duration " days)" > "/dev/stderr"
        }
    }
}

# Handle lines that don't meet the field count requirement
NF > 0 && NF < 8 && !/^[[:space:]]*#/ && !/^[[:space:]]*$/ && !($1 ~ /Date/) {
    invalid_lines++
    if (verbose >= 3) {
        print "[WARN] Line " NR ": Invalid format (" NF " fields): " substr($0, 1, 60) "..." > "/dev/stderr"
    }
}

# Sort missions by duration in descending order
function sort_missions_desc(    i, j, temp) {
    for (i = 1; i <= mission_count; i++) {
        for (j = i + 1; j <= mission_count; j++) {
            if (mission_durations[i] < mission_durations[j]) {
                # Swap all parallel arrays
                temp = mission_dates[i]; mission_dates[i] = mission_dates[j]; mission_dates[j] = temp
                temp = mission_ids[i]; mission_ids[i] = mission_ids[j]; mission_ids[j] = temp
                temp = mission_durations[i]; mission_durations[i] = mission_durations[j]; mission_durations[j] = temp
                temp = mission_codes[i]; mission_codes[i] = mission_codes[j]; mission_codes[j] = temp
                temp = mission_crews[i]; mission_crews[i] = mission_crews[j]; mission_crews[j] = temp
                temp = mission_rates[i]; mission_rates[i] = mission_rates[j]; mission_rates[j] = temp
                temp = mission_lines[i]; mission_lines[i] = mission_lines[j]; mission_lines[j] = temp
            }
        }
    }
}

# Enhanced output functions
function output_json() {
    print "{"
    print "  \"analysis\": {"
    print "    \"destination\": \"" destination "\","
    print "    \"status\": \"" status "\","
    print "    \"total_missions_found\": " completed_target ","
    print "    \"processing_summary\": {"
    print "      \"total_lines\": " total_lines ","
    print "      \"valid_data_lines\": " valid_data_lines ","
    print "      \"target_missions\": " target_missions
    print "    },"
    if (mission_count > 0) {
        print "    \"longest_mission\": {"
        print "      \"security_code\": \"" mission_codes[1] "\","
        print "      \"mission_id\": \"" mission_ids[1] "\","
        print "      \"date\": \"" mission_dates[1] "\","
        print "      \"duration_days\": " mission_durations[1] ","
        print "      \"crew_size\": \"" mission_crews[1] "\","
        print "      \"success_rate\": \"" mission_rates[1] "\","
        print "      \"line_number\": " mission_lines[1]
        print "    },"
        if (top > 1) {
            print "    \"top_missions\": ["
            for (i = 1; i <= top && i <= mission_count; i++) {
                printf "      {\"rank\": %d, \"security_code\": \"%s\", \"mission_id\": \"%s\", \"duration_days\": %d}", i, mission_codes[i], mission_ids[i], mission_durations[i]
                if (i < top && i < mission_count) print ","
                else print ""
            }
            print "    ]"
        }
    } else {
        print "    \"longest_mission\": null"
    }
    print "  }"
    print "}"
}

function output_csv() {
    print "rank,security_code,mission_id,date,duration_days,crew_size,success_rate,line_number"
    for (i = 1; i <= top && i <= mission_count; i++) {
        printf "%d,%s,%s,%s,%d,%s,%s,%d\n", i, mission_codes[i], mission_ids[i], mission_dates[i], mission_durations[i], mission_crews[i], mission_rates[i], mission_lines[i]
    }
}

function output_table() {
    printf "%-4s %-15s %-12s %-12s %-8s %-5s %-12s\n", "Rank", "Security Code", "Mission ID", "Date", "Duration", "Crew", "Success Rate"
    printf "%-4s %-15s %-12s %-12s %-8s %-5s %-12s\n", "----", "-------------", "----------", "----------", "--------", "-----", "------------"
    for (i = 1; i <= top && i <= mission_count; i++) {
        printf "%-4d %-15s %-12s %-12s %-8d %-5s %-12s\n", i, mission_codes[i], mission_ids[i], mission_dates[i], mission_durations[i], mission_crews[i], mission_rates[i]
    }
}

function output_text() {
    if (mission_count > 0) {
        print mission_codes[1]
    } else {
        print "NO_RESULT"
    }
}

# Show destination/status statistics
function show_statistics() {
    if (verbose >= 2 || showstats) {
        print "=== DESTINATION STATISTICS ===" > "/dev/stderr"
        for (dest in destinations) {
            printf "  %-15s: %6d missions\n", dest, destinations[dest] > "/dev/stderr"
        }
        print "" > "/dev/stderr"
        
        print "=== STATUS STATISTICS ===" > "/dev/stderr"
        for (stat in statuses) {
            printf "  %-15s: %6d missions\n", stat, statuses[stat] > "/dev/stderr"
        }
        print "" > "/dev/stderr"
    }
}

END {
    # Sort missions by duration (longest first)
    if (mission_count > 0) {
        sort_missions_desc()
    }
    
    # Enhanced summary reporting
    if (verbose >= 1) {
        print "" > "/dev/stderr"
        print "=== PROFESSIONAL ANALYSIS SUMMARY ===" > "/dev/stderr"
        printf "Target: %s missions with %s status\n", toupper(destination), toupper(status) > "/dev/stderr"
        printf "Total lines processed: %d\n", total_lines > "/dev/stderr"
        printf "Valid data lines: %d (%.1f%%)\n", valid_data_lines, (valid_data_lines/total_lines*100) > "/dev/stderr"
        printf "Comment/blank lines: %d (%.1f%%)\n", comment_lines, (comment_lines/total_lines*100) > "/dev/stderr"
        printf "Invalid lines: %d\n", invalid_lines > "/dev/stderr"
        print "" > "/dev/stderr"
        
        print "=== TARGET MISSION ANALYSIS ===" > "/dev/stderr"
        printf "%s missions found: %d\n", destination, target_missions > "/dev/stderr"
        printf "%s %s missions: %d\n", status, destination, completed_target > "/dev/stderr"
        if (target_missions > 0) {
            completion_rate = (completed_target / target_missions) * 100
            printf "%s %s rate: %.1f%%\n", destination, status, completion_rate > "/dev/stderr"
        }
        print "" > "/dev/stderr"
        
        show_statistics()
        
        if (mission_count > 0) {
            print "=== TOP " top " LONGEST " toupper(destination) " MISSION(S) ===" > "/dev/stderr"
            for (i = 1; i <= top && i <= mission_count; i++) {
                print "Rank " i ":" > "/dev/stderr"
                print "  Mission ID: " mission_ids[i] > "/dev/stderr"
                print "  Date: " mission_dates[i] > "/dev/stderr"
                print "  Duration: " mission_durations[i] " days (" sprintf("%.1f", mission_durations[i]/365) " years)" > "/dev/stderr"
                print "  Crew Size: " mission_crews[i] > "/dev/stderr"
                print "  Success Rate: " mission_rates[i] > "/dev/stderr"
                print "  Security Code: " mission_codes[i] > "/dev/stderr"
                print "  Found at line: " mission_lines[i] > "/dev/stderr"
                if (i < top && i < mission_count) print "" > "/dev/stderr"
            }
            print "" > "/dev/stderr"
            
            if (format == "text") {
                print "FINAL ANSWER: " mission_codes[1] > "/dev/stderr"
            }
        } else {
            print "[ERROR] No " status " " destination " missions found in dataset" > "/dev/stderr"
        }
    }
    
    # Generate output in requested format
    if (mission_count > 0) {
        if (format == "json") {
            output_json()
        } else if (format == "csv") {
            output_csv()
        } else if (format == "table") {
            output_table()
        } else {
            output_text()
        }
    } else {
        if (format == "json") {
            print "{\"error\": \"No results found\", \"missions_found\": 0}"
        } else {
            print "NO_RESULT" > "/dev/stderr"
        }
        exit 1
    }
}
