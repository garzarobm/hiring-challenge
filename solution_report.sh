#!/usr/bin/env bash
set -euo pipefail

# solution_report.sh — Lists all Markdown, prints their content, and compiles a summary report.

REPO_ROOT="${1:-.}"
cd "$REPO_ROOT"

timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
echo "Report generated: $timestamp"
echo

# 1) List all markdown files
echo "=============================="
echo "Markdown files in repository:"
echo "=============================="
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  MD_FILES_RAW=$(git ls-files -- '*.md' '*.MD' '*.markdown' | sort -f)
else
  MD_FILES_RAW=$(find . -type f \( -iname '*.md' -o -iname '*.markdown' \) | sed 's|^\./||' | sort -f)
fi

# Convert to array (macOS compatible)
MD_FILES=()
while IFS= read -r line; do
  [ -n "$line" ] && MD_FILES+=("$line")
done <<< "$MD_FILES_RAW"

if [ "${#MD_FILES[@]}" -eq 0 ]; then
  echo "(No Markdown files found.)"
else
  printf '%s\n' "${MD_FILES[@]}"
fi

# 2) Display content of each markdown file with headers
echo
echo "===================================="
echo "Markdown file contents (verbatim):"
echo "===================================="
for f in "${MD_FILES[@]}"; do
  echo
  echo "----- BEGIN FILE: $f -----"
  echo
  cat "$f"
  echo
  echo "----- END FILE: $f -----"
done

# Helper: print section from a Markdown file between a start heading and before the next same-or-higher heading
md_section() {
  local file="$1"
  local start_pat="$2"   # e.g., '^## Expected Results'
  awk -v start="$start_pat" '
    BEGIN{sec=0; lvl=0}
    function heading_level(s,   n){ n=match(s,/^#+/); return n?n:0 }
    {
      if($0 ~ start){
        sec=1
        lvl=heading_level($0)
        print $0
        next
      }
      if(sec){
        # If we hit a heading with level <= lvl, stop
        if($0 ~ /^#+[[:space:]]/){
          if(heading_level($0) <= lvl){ exit }
        }
        print
      }
    }
  ' "$file"
}

echo
echo "============================="
echo "Comprehensive Summary Report"
echo "============================="

# 3) Challenge overview and objective
echo
echo "## Challenge overview and objective"
if [ -f "WARP.md" ]; then
  md_section "WARP.md" "^##[[:space:]]+Project Overview"
elif [ -f "mission_challenge.md" ]; then
  # Fallback: show first section of mission_challenge.md
  awk 'NR==1, /^##[[:space:]]/' mission_challenge.md
elif [ -f "README.md" ]; then
  awk 'NR==1, /^##[[:space:]]/' README.md
else
  echo "Overview not found in repository Markdown."
fi

# 4) Solution approach and techniques used
echo
echo "## Solution approach and techniques used"
if [ -f "SOLUTION_README.md" ]; then
  # Prefer the first major section(s) from SOLUTION_README.md
  awk 'NR==1, /^##[[:space:]]/' SOLUTION_README.md
fi
if [ -f "WARP.md" ]; then
  md_section "WARP.md" "^##[[:space:]]+Architecture"
  md_section "WARP.md" "^###[[:space:]]+AWK Script Architecture"
fi

# 5) Performance metrics and analysis
echo
echo "## Performance metrics and analysis"
if [ -f "WARP.md" ]; then
  md_section "WARP.md" "^##[[:space:]]+Performance Characteristics"
fi

# 6) File structure and components
echo
echo "## File structure and components"
echo
echo "### Core components (from WARP.md)"
if [ -f "WARP.md" ]; then
  md_section "WARP.md" "^###[[:space:]]+Core Components"
fi
echo
echo "### Repository tree (depth 3)"
if command -v tree >/dev/null 2>&1; then
  tree -L 3 -a -I .git
else
  # Lightweight tree substitute
  find . -maxdepth 3 ! -path "./.git/*" -print | sed "s|^\.\/||" | awk -F/ '
    {
      indent=""
      for(i=1;i<NF;i++){ indent=indent "  " }
      name=$NF==""?".":$NF
      print indent name
    }
  '
fi

# 7) Expected results and validation
echo
echo "## Expected results and validation"
if [ -f "WARP.md" ]; then
  md_section "WARP.md" "^##[[:space:]]+Expected Results"
  echo
  echo "### How to validate (from WARP.md Quick Start)"
  md_section "WARP.md" "^###[[:space:]]+Running the Solution"
fi

# 8) Development timeline
echo
echo "## Development timeline"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo
  echo "### Recent commits"
  git log --date=short --pretty=format:"- %ad %h %s (%an)" | sed -n '1,30p'
  echo
  echo "### Contributors"
  git shortlog -sne
else
  echo "No git repository detected; timeline unavailable."
fi

echo
echo "Report complete."
