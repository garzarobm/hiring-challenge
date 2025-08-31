```plaintext
Enhanced AWK Script Usage Guide
```

## Overview

`find_mars_code_pro.awk` is a professional-grade enhancement of the original Mars mission security code finder. It provides multiple output formats, comprehensive analysis, and flexible filtering options while maintaining full compatibility with macOS system AWK.

## Quick Start

```plaintext
# Basic usage (same as original script)
./find_mars_code_pro.awk space_missions.log
# Output: XRT-421-ZQP

# With comprehensive analysis
./find_mars_code_pro.awk -v verbose=1 space_missions.log

# JSON format for API integration
./find_mars_code_pro.awk -v format=json space_missions.log
```

## Command Line Options

### Verbosity Levels

*   `verbose=0` - Silent mode (default) - outputs only the security code
*   `verbose=1` - Summary statistics and basic analysis
*   `verbose=2` - Show each mission found + detailed analysis + destination statistics
*   `verbose=3` - Debug mode with parsing details and progress indicators

### Output Formats

*   `format=text` - Default format (security code only)
*   `format=json` - Structured JSON output for APIs/automation
*   `format=csv` - CSV format for spreadsheet import
*   `format=table` - Formatted table for human reading

### Analysis Options

*   `top=N` - Show top N longest missions (default: 1)
*   `destination=X` - Filter by destination (default: mars)
*   `status=X` - Filter by status (default: completed)
*   `showstats=1` - Show destination and status statistics

## Usage Examples

### 1\. Basic Challenge Solution

```plaintext
./find_mars_code_pro.awk space_missions.log
```

Output: `XRT-421-ZQP`

### 2\. Comprehensive Analysis

```plaintext
./find_mars_code_pro.awk -v verbose=1 space_missions.log
```

Provides:

*   Processing summary (105,032 lines processed)
*   Mars mission statistics (5,832 total, 975 completed)
*   Completion rate (16.7%)
*   Longest mission details

### 3\. Top 5 Longest Mars Missions (Table Format)

```plaintext
./find_mars_code_pro.awk -v format=table -v top=5 space_missions.log
```

Output:

```plaintext
Rank Security Code   Mission ID   Date         Duration Crew  Success Rate
---- -------------   ----------   ----------   -------- ----- ------------
1    XRT-421-ZQP     WGU-0200     2065-06-05   1629     4     98.82       
2    WCN-103-DVD     AJV-3533     2047-07-31   1482     2     97.61       
3    ZCA-027-KCP     LBS-1848     2041-01-14   1479     3     51.49       
4    DHA-730-NYP     LTZ-4413     2045-12-13   1422     5     95.45       
5    NQT-363-IFR     PGQ-7628     2043-01-15   1417     2     78.82       
```

### 4\. JSON Output for API Integration

```plaintext
./find_mars_code_pro.awk -v format=json space_missions.log
```

Output:

```plaintext
{
  "analysis": {
    "destination": "mars",
    "status": "completed",
    "total_missions_found": 975,
    "processing_summary": {
      "total_lines": 105032,
      "valid_data_lines": 100000,
      "target_missions": 5832
    },
    "longest_mission": {
      "security_code": "XRT-421-ZQP",
      "mission_id": "WGU-0200",
      "date": "2065-06-05",
      "duration_days": 1629,
      "crew_size": "4",
      "success_rate": "98.82",
      "line_number": 5448
    }
  }
}
```

### 5\. CSV Export for Spreadsheet Analysis

```plaintext
./find_mars_code_pro.awk -v format=csv -v top=10 space_missions.log &gt; mars_missions.csv
```

### 6\. Analyze Different Destinations

```plaintext
# Venus missions
./find_mars_code_pro.awk -v destination=venus -v verbose=1 space_missions.log

# Jupiter missions  
./find_mars_code_pro.awk -v destination=jupiter -v verbose=1 space_missions.log
```

### 7\. Different Mission Status Types

```plaintext
# Failed missions
./find_mars_code_pro.awk -v destination=mars -v status=failed -v top=5 -v format=table space_missions.log

# In Progress missions
./find_mars_code_pro.awk -v status="in progress" -v top=3 -v verbose=1 space_missions.log
```

### 8\. Comprehensive Audit with Statistics

```plaintext
./find_mars_code_pro.awk -v verbose=2 -v showstats=1 space_missions.log
```

Shows:

*   Complete processing summary
*   Destination statistics (all planets)
*   Status statistics (all mission outcomes)
*   Detailed mission information

## Advanced Features

### Performance Analysis

The enhanced script provides detailed performance metrics:

*   Processing rate: ~178K lines/second
*   Memory usage: Constant space complexity
*   Progress indicators for large files (verbose=3)

### Error Handling

*   Robust parsing of mixed text/numeric duration fields
*   Handles inconsistent whitespace around pipe separators
*   Validates field count and skips malformed records
*   Reports parsing warnings in verbose modes

### Flexibility

*   Case-insensitive destination and status matching
*   Configurable top-N analysis
*   Multiple output formats for different use cases
*   Statistics tracking for any destination/status combination

## Output Validation

All outputs have been validated against the original requirements:

*   **Sample dataset**: `GHI-789-JKL` ✅
*   **Full dataset**: `XRT-421-ZQP` ✅
*   **Mission details**: WGU-0200, 1629 days, launched 2065-06-05 ✅

## Integration Examples

### Shell Script Integration

```plaintext
#!/bin/bash
RESULT=$(./find_mars_code_pro.awk space_missions.log)
echo "Mars mission security code: $RESULT"

# JSON API endpoint
ANALYSIS=$(./find_mars_code_pro.awk -v format=json space_missions.log)
curl -X POST -H "Content-Type: application/json" -d "$ANALYSIS" https://api.example.com/missions
```

### Data Pipeline Integration

```plaintext
# Process and export to different formats
./find_mars_code_pro.awk -v format=csv -v top=100 space_missions.log &gt; top_100_mars_missions.csv
./find_mars_code_pro.awk -v format=json space_missions.log &gt; mars_analysis.json
```

## Compatibility

*   **macOS**: Full compatibility with system AWK (version 20200816)
*   **Linux**: Compatible with GNU AWK and other POSIX-compliant AWK implementations
*   **Performance**: Optimized for single-pass processing with minimal memory usage
*   **Dependencies**: No external dependencies beyond standard AWK

## Comparison with Original

| Feature | Original | Enhanced |
| --- | --- | --- |
| Basic functionality | ✅ | ✅ |
| Output formats | Text only | Text, JSON, CSV, Table |
| Analysis depth | Basic | Comprehensive |
| Top-N missions | No | Yes (configurable) |
| Destination flexibility | Mars only | Any destination |
| Status flexibility | Completed only | Any status |
| Statistics | Limited | Detailed |
| Performance | Fast | Fast + metrics |
| Error handling | Basic | Comprehensive |

The enhanced version maintains 100% backward compatibility while adding powerful new features for comprehensive mission log analysis.