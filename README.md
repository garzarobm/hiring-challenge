# Warp Hiring Challenge

## About
This is a programming challenge for candidates who are interested in applying to Warp. It's meant to be short and fun -- we highly encourage you to use Agent Mode in Warp to solve the challenge! There will be fields in the application for you to share your answer and a link to Warp Shared Block containing the command you used to solve the problem.

Participation in the challenge is optional. You can still submit an application without doing the hiring challenge.

Get started by reading the [challenge description](docs/project/mission_challenge.md). Good luck!

## Project Structure

### Core Files
- `README.md` - This file
- `space_missions.log` - Dataset (105,032 lines, ~9.7MB)
- `validate_environment.sh` - Environment validation script

### Scripts & Tools ([`enhanced_features/`](enhanced_features/))
Professional AWK solutions and performance tools:
- `find_mars_code_pro.awk` - Enhanced AWK script with multiple output formats
- `run.sh` - Performance-optimized wrapper script
- `tests/` - Test data and validation

### Documentation ([`docs/`](docs/))
Comprehensive documentation organized by category:
- **[`docs/analysis/`](docs/analysis/)** - Solution analysis and dataset reports
- **[`docs/usage/`](docs/usage/)** - Technical usage guides
- **[`docs/project/`](docs/project/)** - Original challenge materials

See [`docs/README.md`](docs/README.md) for complete documentation index.

## Environment Validation

Before running any commands, validate your environment:

```bash
# Check if all files and directories are correct
./validate_environment.sh

# Fix any permission issues if needed
./validate_environment.sh fix
```

## Quick Solution

**Answer**: `XRT-421-ZQP`

```bash
# Run the professional AWK solution:
./enhanced_features/find_mars_code_pro.awk space_missions.log
```

Output: `XRT-421-ZQP`

## Enhanced Features

For detailed usage, multiple output formats, comprehensive analysis, and professional documentation, see the [`enhanced_features/`](enhanced_features/) folder.
