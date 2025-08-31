#!/usr/bin/env awk -f

# Usage: ./find_mars_code.awk [-v verbose=1|2|3] space_missions.log
# verbose=1: Show summary stats
# verbose=2: Show each Mars mission found
# verbose=3: Show detailed parsing info

BEGIN {
    FS = "[[:space:]]*\\|[[:space:]]*"
    max_duration = -1
    max_code = ""
    
    # Verbosity counters
    total_lines = 0
    comment_lines = 0
    header_lines = 0
    invalid_lines = 0
    mars_missions = 0
    completed_mars = 0
    
    if (verbose >= 1) {
        print "[INFO] Starting space mission log analysis..." > "/dev/stderr"
        print "[INFO] Verbosity level: " verbose > "/dev/stderr"
    }
}

# Remove Windows line endings if present
{
    sub(/\r$/, "", $0)
    total_lines++
    
    if (verbose >= 3 && total_lines % 10000 == 0) {
        print "[DEBUG] Processed " total_lines " lines..." > "/dev/stderr"
    }
}

# Skip comment lines and blank lines
/^[[:space:]]*#/ || /^[[:space:]]*$/ {
    comment_lines++
    if (verbose >= 3) {
        print "[DEBUG] Line " NR ": Skipping comment/blank: " substr($0, 1, 50) > "/dev/stderr"
    }
    next
}

# Skip header lines that contain "Date" in first field
$1 ~ /Date/ {
    header_lines++
    if (verbose >= 2) {
        print "[DEBUG] Line " NR ": Skipping header: " $0 > "/dev/stderr"
    }
    next
}

# Process data lines with at least 8 fields
NF >= 8 {
    destination = $3
    status = $4
    duration_raw = $6
    security_code = $8
    
    # Trim whitespace from fields
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", destination)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", status)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", duration_raw)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", security_code)
    
    # Track Mars missions
    if (tolower(destination) == "mars") {
        mars_missions++
        if (verbose >= 3) {
            print "[DEBUG] Line " NR ": Mars mission found - " $2 " status: " status > "/dev/stderr"
        }
    }
    
    # Filter for Mars missions with Completed status
    if (tolower(destination) != "mars") next
    if (tolower(status) != "completed") next
    
    completed_mars++
    
    # Extract numeric duration (handles "365 days", "approx. 400", etc.)
    if (match(duration_raw, /[0-9]+(\.[0-9]+)?/)) {
        duration = substr(duration_raw, RSTART, RLENGTH) + 0
    } else {
        if (verbose >= 2) {
            print "[WARN] Line " NR ": Invalid duration format: " duration_raw > "/dev/stderr"
        }
        next
    }
    
    if (verbose >= 2) {
        print "[INFO] Completed Mars mission: " $2 " (" duration " days) - " security_code > "/dev/stderr"
    }
    
    # Update maximum if this duration is longer
    if (duration > max_duration) {
        max_duration = duration
        max_code = security_code
        max_mission_line = NR
        max_mission_id = $2
        max_mission_date = $1
        
        # Extract clean security code (ABC-123-XYZ format)
        if (match(max_code, /[A-Z]{3}-[0-9]{3}-[A-Z]{3}/)) {
            max_code = substr(max_code, RSTART, RLENGTH)
        }
        
        if (verbose >= 2) {
            print "[INFO] New longest mission found: " max_mission_id " (" duration " days)" > "/dev/stderr"
        }
    }
}

# Handle invalid lines
NF < 8 && !/^[[:space:]]*#/ && !/^[[:space:]]*$/ && !($1 ~ /Date/) {
    invalid_lines++
    if (verbose >= 3) {
        print "[WARN] Line " NR ": Invalid format (" NF " fields): " substr($0, 1, 50) > "/dev/stderr"
    }
}

END {
    if (verbose >= 1) {
        print "" > "/dev/stderr"
        print "=== PROCESSING SUMMARY ===" > "/dev/stderr"
        print "Total lines processed: " total_lines > "/dev/stderr"
        print "Comment/blank lines: " comment_lines > "/dev/stderr"
        print "Header lines: " header_lines > "/dev/stderr"
        print "Invalid format lines: " invalid_lines > "/dev/stderr"
        print "Data lines: " (total_lines - comment_lines - header_lines - invalid_lines) > "/dev/stderr"
        print "" > "/dev/stderr"
        print "Mars missions found: " mars_missions > "/dev/stderr"
        print "Completed Mars missions: " completed_mars > "/dev/stderr"
        
        if (completed_mars > 0) {
            completion_rate = (completed_mars / mars_missions) * 100
            print "Mars completion rate: " sprintf("%.1f%%", completion_rate) > "/dev/stderr"
        }
        print "" > "/dev/stderr"
    }
    
    if (max_duration >= 0 && max_code != "") {
        if (verbose >= 1) {
            print "=== LONGEST MARS MISSION ===" > "/dev/stderr"
            print "Mission ID: " max_mission_id > "/dev/stderr"
            print "Date: " max_mission_date > "/dev/stderr"
            print "Duration: " max_duration " days" > "/dev/stderr"
            print "Security Code: " max_code > "/dev/stderr"
            print "Found at line: " max_mission_line > "/dev/stderr"
            print "" > "/dev/stderr"
            print "Answer: " max_code > "/dev/stderr"
        }
        print max_code
    } else {
        print "NO_RESULT" > "/dev/stderr"
        if (verbose >= 1) {
            print "[ERROR] No completed Mars missions found in the dataset" > "/dev/stderr"
        }
        exit 1
    }
}
