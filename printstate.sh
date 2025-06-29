#!/bin/bash

# Script to recursively print contents of .jsx, .js, .html, .scss, and .css files
# to understand the state of the repository, excluding node_modules, boilerplate directories,
# package.json, and *.sh files
# ----------------------------------
# Usage: ./printstate.sh > state.txt
# Outputs file paths and contents for relevant files

set -o pipefail
LOG_FILE="printstate.log"
echo "🚀 Generating repository state - $(date)" | tee -a $LOG_FILE

# Function to log and execute commands
run_command() {
  echo "🔧 Executing: $*" | tee -a $LOG_FILE
  if ! "$@" 2>&1 | tee -a $LOG_FILE; then
    echo "⚠️ Warning: Error executing: $*" | tee -a $LOG_FILE
    return 1
  fi
  return 0
}

# 1. Change to project directory
cd /home/davis/Desktop/3dwebsite || { echo "❌ Error: Could not enter project directory" | tee -a $LOG_FILE; exit 1; }
echo "📂 Working in: $(pwd)" | tee -a $LOG_FILE

# 2. Print repository state to stdout (for redirection to state.txt)
echo "📝 Printing repository state..." | tee -a $LOG_FILE
{
  echo "===== Repository State: $(date) ====="
  echo "Directory: $(pwd)"
  echo ""

  # List relevant file types: .jsx, .js, .html, .scss, .css
  # Exclude node_modules, dist, build, and package.json
  find . -type d \( -name "node_modules" -o -name "dist" -o -name "build" \) -prune -o \
    -type f \( -name "*.jsx" -o -name "*.js" -o -name "*.html" -o -name "*.scss" -o -name "*.css" \) \
    ! -name "package.json" | sort | while read -r file; do
    echo "===== $file ====="
    if [ "${file##*.}" = "html" ]; then
      # Escape HTML content to preserve tags
      sed 's/</\&lt;/g; s/>/\&gt;/g' "$file"
    else
      cat "$file"
    fi
    echo ""
  done

  # Include package-lock.json summary if it exists (for dependency state)
  if [ -f "package-lock.json" ]; then
    echo "===== package-lock.json (summary) ====="
    echo "Showing package-lock.json summary (full file omitted due to size)"
    jq '.name, .version, .dependencies | keys' package-lock.json 2>/dev/null || echo "⚠️ jq not installed, skipping package-lock.json summary"
    echo ""
  fi

  # Include git status if repository is a git repo
  if git rev-parse --git-dir >/dev/null 2>&1; then
    echo "===== Git Status ====="
    git status
    echo ""
  fi
} > state.txt

# 3. Verify output
if [ -f "state.txt" ]; then
  echo "✅ Repository state written to state.txt" | tee -a $LOG_FILE
  echo "📄 Run 'cat state.txt' to view or redirect as needed" | tee -a $LOG_FILE
else
  echo "❌ Failed to create state.txt" | tee -a $LOG_FILE
  exit 1
fi

echo "DONE" | tee -a $LOG_FILE
