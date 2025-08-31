#!/usr/bin/env awk -f

BEGIN {
    FS = "[[:space:]]*\\|[[:space:]]*"
    max_duration = -1
    max_code = ""
}

# Remove Windows line endings if present
{
    sub(/\r$/, "", $0)
}

# Skip comment lines and blank lines
/^[[:space:]]*#/ || /^[[:space:]]*$/ {
    next
}

# Skip header lines that contain "Date" in first field
$1 ~ /Date/ {
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
    
    # Filter for Mars missions with Completed status
    if (tolower(destination) != "mars") next
    if (tolower(status) != "completed") next
    
    # Extract numeric duration (handles "365 days", "approx. 400", etc.)
    if (match(duration_raw, /[0-9]+(\.[0-9]+)?/)) {
        duration = substr(duration_raw, RSTART, RLENGTH) + 0
    } else {
        next
    }
    
    # Update maximum if this duration is longer
    if (duration > max_duration) {
        max_duration = duration
        max_code = security_code
        
        # Extract clean security code (ABC-123-XYZ format)
        if (match(max_code, /[A-Z]{3}-[0-9]{3}-[A-Z]{3}/)) {
            max_code = substr(max_code, RSTART, RLENGTH)
        }
    }
}

END {
    if (max_duration >= 0 && max_code != "") {
        print max_code
    } else {
        print "NO_RESULT" > "/dev/stderr"
        exit 1
    }
}
