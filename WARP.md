# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview
This repository contains a Warp hiring challenge focused on analyzing space mission log files using AWK. The goal is to find the security code of the longest successful Mars mission from a large dataset (~105K lines) using efficient text processing.

## Quick Start

### Running the Solution
```bash
# Run with the main dataset
./run.sh space_missions.log

# Or call the AWK script directly
./find_mars_code.awk space_missions.log

# Test with sample data
./find_mars_code.awk tests/space_missions.sample.log
```

### Setup Requirements
```bash
# Check AWK version (macOS system awk works fine for this project)
awk --version

# For performance-critical use, install GNU AWK if needed
brew install gawk  # macOS
sudo apt-get install gawk  # Ubuntu/Debian
```

## Architecture

### Core Components
- **`find_mars_code.awk`**: Main AWK script that parses mission logs and finds the longest successful Mars mission
- **`run.sh`**: Shell wrapper that invokes the AWK script with optimal environment settings
- **`space_missions.log`**: Primary dataset (~105K lines of mission data)
- **`tests/space_missions.sample.log`**: Sample dataset for testing and development

### AWK Script Architecture

#### BEGIN Block
- Sets field separator to handle pipe-delimited format with variable whitespace: `FS = "[[:space:]]*\\|[[:space:]]*"`
- Initializes tracking variables for maximum duration and corresponding security code

#### Record Processing
- **Filtering**: Skips comment lines (`#`), blank lines, and header rows containing "Date"
- **Field Extraction**: Extracts destination, status, duration, and security code from pipe-separated fields
- **Normalization**: Trims whitespace from all fields using `gsub()`
- **Validation**: Only processes Mars missions with "Completed" status (case-insensitive)
- **Duration Parsing**: Extracts numeric values from duration field that may contain text like "365 days" or "approx. 400"

#### END Block
- Outputs the security code of the longest mission, or error message if none found
- Performs final security code pattern validation (ABC-123-XYZ format)

### Data Format
```
Date | Mission ID | Destination | Status | Crew Size | Duration (days) | Success Rate | Security Code
```

Key parsing challenges:
- Inconsistent whitespace around pipe separators
- Duration field contains mixed text and numbers
- Comment lines and system checkpoint records mixed in data
- Case variations in destination and status fields

## Development Commands

### Testing and Validation
```bash
# Run with sample data for quick testing
./find_mars_code.awk tests/space_missions.sample.log

# Test with different input methods
cat tests/space_missions.sample.log | ./find_mars_code.awk

# Performance measurement with timing
/usr/bin/time -l ./find_mars_code.awk space_missions.log
```

### Development and Debugging
```bash
# Add debug output by modifying the script temporarily
# (The script is designed for clean output - modify cautiously)

# Check field parsing on first few lines
head -20 space_missions.log | ./find_mars_code.awk

# Validate field separator handling
awk -F '[[:space:]]*\|[[:space:]]*' 'NR<=10 {print NF, "|", $0}' tests/space_missions.sample.log
```

### Performance Optimization
```bash
# Run with optimal environment for performance
LC_ALL=C ./find_mars_code.awk space_missions.log

# For GNU AWK if available
LC_ALL=C gawk -O -f find_mars_code.awk space_missions.log

# Memory and timing analysis
/usr/bin/time -l ./find_mars_code.awk space_missions.log
```

## Expected Results

### Sample Data
- Input: `tests/space_missions.sample.log`
- Expected output: `GHI-789-JKL`

### Full Dataset
- Input: `space_missions.log` (~105K lines)
- Expected output: `XRT-421-ZQP`
- Corresponding mission: WGU-0200 (1629 days)

## Performance Characteristics
- **Processing Speed**: ~172K lines per second on Apple M2
- **Memory Usage**: ~2MB peak resident set
- **Execution Time**: ~0.6 seconds for 105K line dataset
- **Algorithm**: Single-pass streaming with constant memory usage

## Cross-Platform Notes

### macOS
- Uses system AWK (version 20200816) - works fine for this project
- BSD awk handles the regex patterns and field operations correctly

### Linux
- GNU AWK recommended for optimal performance
- Use `LC_ALL=C` environment for faster string operations

### AWK Compatibility
- Script uses POSIX-compatible AWK features
- No GNU AWK-specific extensions required
- Regex patterns use standard POSIX character classes
