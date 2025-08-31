# Space Mission Log Analysis - AWK Solution

## Goal
Find the security code of the longest successful Mars mission from a large log file containing space mission data.

## Dataset Format
The log file `space_missions.log` contains ~105K lines with the following format:
```
Date | Mission ID | Destination | Status | Crew Size | Duration (days) | Success Rate | Security Code
```

### Constraints
- Fields are pipe-separated with inconsistent whitespace
- Comments start with `#` and should be ignored
- Header lines contain "Date" and should be skipped
- Only consider missions with:
  - Destination: "Mars" (case-insensitive)
  - Status: "Completed" (case-insensitive)
- Duration field may contain extra text like "365 days" or "approx. 400"
- Security codes follow pattern ABC-123-XYZ

## Approach
Use AWK to parse the file, filter for completed Mars missions, extract numeric durations, and track the maximum to find the corresponding security code.

## AWK Techniques Used

### Field Separator with Regex
```awk
FS = "[[:space:]]*\\|[[:space:]]*"
```
Handles pipes with variable surrounding whitespace.

### Skipping Comments and Headers
```awk
/^[[:space:]]*#/ || /^[[:space:]]*$/ { next }  # Skip comments/blank lines
$1 ~ /Date/ { next }                            # Skip headers
```

### Field Trimming
```awk
gsub(/^[[:space:]]+|[[:space:]]+$/, "", field)
```
Removes leading and trailing whitespace from each field.

### Case-Insensitive Filtering
```awk
if (tolower(destination) != "mars") next
if (tolower(status) != "completed") next
```

### Robust Numeric Extraction
```awk
if (match(duration_raw, /[0-9]+(\.[0-9]+)?/)) {
    duration = substr(duration_raw, RSTART, RLENGTH) + 0
}
```
Extracts the first number from text like "365 days" or "approx. 400".

### Security Code Pattern Extraction
```awk
if (match(max_code, /[A-Z]{3}-[0-9]{3}-[A-Z]{3}/)) {
    max_code = substr(max_code, RSTART, RLENGTH)
}
```
Extracts clean ABC-123-XYZ pattern from noisy fields.

## Why This Solution Works

### Correctness
- **Proper Filtering**: Only processes Mars missions with "Completed" status
- **Robust Parsing**: Handles inconsistent spacing and extra text in fields
- **Header Resilience**: Skips comment lines and headers containing "Date"
- **Tie Handling**: Returns the first mission encountered with maximum duration

### Performance
- **Single Pass**: Reads the file once, processing ~105K lines
- **Minimal Memory**: Uses constant space (only tracks maximum values)
- **Optimized**: Uses `LC_ALL=C` for faster string processing

## Performance Analysis

**Test Environment**: Apple M2, macOS Darwin 24.6.0

**Measurements** (3 runs):
- Run 1: 0.62 real, 0.59 user, 0.01 sys
- Run 2: 0.59 real, 0.58 user, 0.00 sys  
- Run 3: 0.62 real, 0.60 user, 0.01 sys

**Median**: ~0.61 seconds elapsed time

**Memory Usage**: ~2.1MB peak resident set

The script processes approximately 172K lines per second, making it highly efficient for log analysis tasks.

## Script Walkthrough

### BEGIN Block
```awk
BEGIN {
    FS = "[[:space:]]*\\|[[:space:]]*"  # Set field separator
    max_duration = -1                    # Initialize tracking variables
    max_code = ""
}
```

### Line Processing
1. **Sanitization**: Remove Windows line endings
2. **Filtering**: Skip comments, blanks, and headers
3. **Field Extraction**: Get destination, status, duration, security code
4. **Normalization**: Trim whitespace from all fields
5. **Validation**: Check for Mars + Completed combination
6. **Duration Parsing**: Extract numeric value from duration field
7. **Maximum Tracking**: Update if current duration exceeds maximum

### END Block
```awk
END {
    if (max_duration >= 0 && max_code != "") {
        print max_code
    } else {
        print "NO_RESULT" > "/dev/stderr"
        exit 1
    }
}
```
Outputs the security code or error if no valid missions found.

## How to Run

### Method 1: Script File
```bash
./find_mars_code.awk space_missions.log
```

### Method 2: One-liner
```bash
LC_ALL=C awk -F '[[:space:]]*\|[[:space:]]*' 'BEGIN{max=-1} /^[[:space:]]*#/||/^[[:space:]]*$/ {next} $1 ~ /Date/ {next} NF >= 8 { dest=$3; status=$4; dur=$6; code=$8; gsub(/^[[:space:]]+|[[:space:]]+$/, "", dest); gsub(/^[[:space:]]+|[[:space:]]+$/, "", status); gsub(/^[[:space:]]+|[[:space:]]+$/, "", dur); gsub(/^[[:space:]]+|[[:space:]]+$/, "", code); if (tolower(dest)!="mars" || tolower(status)!="completed") next; if (match(dur, /[0-9]+(\.[0-9]+)?/)) { d=substr(dur,RSTART,RLENGTH)+0; if (d>max) { max=d; mc=code; if (match(mc, /[A-Z]{3}-[0-9]{3}-[A-Z]{3}/)) mc=substr(mc,RSTART,RLENGTH) } } } END{ if (max>=0 && mc!="") print mc; else { print "NO_RESULT" > "/dev/stderr"; exit 1 } }' space_missions.log
```

### Method 3: Run Script
```bash
./run.sh
```

## Output
For the provided dataset, the longest successful Mars mission has a duration of **1629 days** and the security code is:

**XRT-421-ZQP**

## Mission Details
The longest successful Mars mission was:
- Date: 2065-06-05
- Mission ID: WGU-0200  
- Destination: Mars
- Status: Completed
- Crew Size: 4
- Duration: 1629 days
- Success Rate: 98.82%
- Security Code: XRT-421-ZQP

## Development Time
This solution was implemented and tested in approximately **15-20 minutes**, including:
- Dataset analysis and exploration (5 min)
- AWK script development and debugging (8 min)
- Performance testing and validation (3 min)  
- Documentation (4 min)
