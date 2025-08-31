#!/bin/bash

# validate_environment.sh
# Validates the directory structure and required files before running AWK analysis commands

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "OK")
            echo -e "${GREEN}✓${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}✗${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠${NC} $message"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ${NC} $message"
            ;;
    esac
}

# Function to check if file exists and is readable
check_file() {
    local file=$1
    local description=$2
    
    if [[ -f "$file" && -r "$file" ]]; then
        print_status "OK" "$description found: $file"
        return 0
    else
        print_status "ERROR" "$description missing or not readable: $file"
        return 1
    fi
}

# Function to check if directory exists
check_directory() {
    local dir=$1
    local description=$2
    
    if [[ -d "$dir" ]]; then
        print_status "OK" "$description found: $dir"
        return 0
    else
        print_status "ERROR" "$description missing: $dir"
        return 1
    fi
}

# Function to check if file is executable
check_executable() {
    local file=$1
    local description=$2
    
    if [[ -f "$file" && -x "$file" ]]; then
        print_status "OK" "$description is executable: $file"
        return 0
    elif [[ -f "$file" ]]; then
        print_status "WARNING" "$description exists but is not executable: $file"
        print_status "INFO" "Run: chmod +x $file"
        return 1
    else
        print_status "ERROR" "$description missing: $file"
        return 1
    fi
}

# Main validation function
validate_environment() {
    local errors=0
    local warnings=0
    
    print_status "INFO" "Starting environment validation..."
    echo
    
    # Check current directory
    local current_dir=$(pwd)
    if [[ "$(basename "$current_dir")" == "hiring-challenge" ]]; then
        print_status "OK" "Current directory: $current_dir"
    else
        print_status "ERROR" "Not in hiring-challenge directory. Current: $current_dir"
        ((errors++))
    fi
    
    # Check required root files
    echo
    print_status "INFO" "Checking root directory files..."
    
    check_file "README.md" "Project README" || ((errors++))
    check_file "mission_challenge.md" "Challenge description" || ((errors++))
    check_file "space_missions.log" "Dataset file" || ((errors++))
    check_file "WARP_AGENT_AWK_ANALYSIS.md" "Solution analysis" || ((errors++))
    
    # Check enhanced_features directory
    echo
    print_status "INFO" "Checking enhanced_features directory..."
    
    check_directory "enhanced_features" "Enhanced features directory" || ((errors++))
    
    if [[ -d "enhanced_features" ]]; then
        # Check AWK scripts
        check_executable "enhanced_features/find_mars_code_pro.awk" "Enhanced AWK script" || ((warnings++))
        check_executable "enhanced_features/run.sh" "Performance wrapper script" || ((warnings++))
        
        # Check documentation
        check_file "enhanced_features/README.md" "Enhanced features README" || ((errors++))
        check_file "enhanced_features/ENHANCED_AWK_USAGE.md" "Usage documentation" || ((errors++))
        check_file "enhanced_features/SPACE_MISSIONS_COMPREHENSIVE_REPORT.md" "Analysis report" || ((errors++))
        
        # Check test directory
        check_directory "enhanced_features/tests" "Test directory" || ((warnings++))
        if [[ -d "enhanced_features/tests" ]]; then
            check_file "enhanced_features/tests/space_missions.sample.log" "Sample test data" || ((warnings++))
        fi
    fi
    
    # Check dataset size and format
    echo
    print_status "INFO" "Validating dataset..."
    
    if [[ -f "space_missions.log" ]]; then
        local line_count=$(wc -l < "space_missions.log" 2>/dev/null || echo "0")
        if [[ $line_count -eq 105032 ]]; then
            print_status "OK" "Dataset has correct line count: $line_count"
        else
            print_status "WARNING" "Dataset line count: $line_count (expected: 105032)"
            ((warnings++))
        fi
        
        # Check if first line looks like header
        local first_line=$(head -n1 "space_missions.log" 2>/dev/null || echo "")
        if [[ "$first_line" == *"MISSION_ID"* ]]; then
            print_status "OK" "Dataset appears to have header row"
        else
            print_status "WARNING" "Dataset may not have expected header format"
            ((warnings++))
        fi
    fi
    
    # Check AWK availability
    echo
    print_status "INFO" "Checking system requirements..."
    
    if command -v awk >/dev/null 2>&1; then
        local awk_version=$(awk --version 2>&1 | head -n1 || echo "Unknown AWK version")
        print_status "OK" "AWK available: $awk_version"
    else
        print_status "ERROR" "AWK not found in PATH"
        ((errors++))
    fi
    
    # Summary
    echo
    print_status "INFO" "Validation Summary:"
    echo "  Errors: $errors"
    echo "  Warnings: $warnings"
    
    if [[ $errors -eq 0 ]]; then
        if [[ $warnings -eq 0 ]]; then
            print_status "OK" "Environment is fully ready!"
        else
            print_status "WARNING" "Environment is ready with minor issues"
        fi
        echo
        print_status "INFO" "You can now run:"
        echo "  ./enhanced_features/find_mars_code_pro.awk space_missions.log"
        echo "  ./enhanced_features/run.sh 0 space_missions.log"
        echo "  or any other analysis commands"
        return 0
    else
        print_status "ERROR" "Environment validation failed!"
        echo
        print_status "INFO" "Please fix the errors above before running analysis commands"
        return 1
    fi
}

# Function to fix common issues
fix_permissions() {
    print_status "INFO" "Fixing file permissions..."
    
    if [[ -f "enhanced_features/find_mars_code_pro.awk" ]]; then
        chmod +x "enhanced_features/find_mars_code_pro.awk"
        print_status "OK" "Made find_mars_code_pro.awk executable"
    fi
    
    if [[ -f "enhanced_features/run.sh" ]]; then
        chmod +x "enhanced_features/run.sh"
        print_status "OK" "Made run.sh executable"
    fi
    
    if [[ -f "validate_environment.sh" ]]; then
        chmod +x "validate_environment.sh"
        print_status "OK" "Made validate_environment.sh executable"
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTION]"
    echo
    echo "Options:"
    echo "  validate    Validate environment (default)"
    echo "  fix         Fix common permission issues"
    echo "  help        Show this help message"
    echo
    echo "Examples:"
    echo "  $0                    # Validate environment"
    echo "  $0 validate          # Validate environment"
    echo "  $0 fix               # Fix file permissions"
}

# Main execution
main() {
    local action=${1:-validate}
    
    case $action in
        "validate"|"")
            validate_environment
            ;;
        "fix")
            fix_permissions
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            print_status "ERROR" "Unknown option: $action"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
