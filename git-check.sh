#!/bin/bash

# --- Configuration ---
DEFAULT_BRANCH="main" # Or "master". Script will try to use upstream if configured.
LOG_FILE="git_repo_check_$(date +%Y%m%d_%H%M%S).log" # Log file name with timestamp
DRY_RUN=false         # Set to true for a dry run (no actual deletions)
FORCE_DELETE=false    # Set to true to bypass individual deletion prompts (use with EXTREME CAUTION with DRY_RUN=false)

# --- Colors for better terminal output ---
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Variables for summary ---
UP_TO_DATE_COUNT=0
BEHIND_COUNT=0
AHEAD_COUNT=0
HAS_CHANGES_COUNT=0
DELETED_COUNT=0
SKIPPED_COUNT=0
ERROR_COUNT=0

# --- Function to log messages ---
log_message() {
    local message="$1"
    echo -e "$message" | tee -a "$LOG_FILE" # Print to console and append to log file
}

# --- Function to ask for deletion confirmation ---
confirm_delete() {
    local repo_name="$1"
    if [ "$FORCE_DELETE" = true ]; then
        log_message "${YELLOW}    ↪ Force deleting '$repo_name' (FORCE_DELETE is true).${NC}"
        return 0 # Auto-confirm
    fi

    if [ "$DRY_RUN" = true ]; then
        log_message "${BLUE}    ↪ DRY RUN: Would delete '$repo_name'.${NC}"
        return 1 # Do not delete in dry run
    fi

    read -p "    Do you want to delete this folder? (y/N): " delete_choice
    if [[ "$delete_choice" =~ ^[Yy]$ ]]; then
        return 0 # Confirmed
    else
        return 1 # Not confirmed
    fi
}

# --- Main Script Logic ---
log_message "${BLUE}----------------------------------------------------${NC}"
log_message "${BLUE} Starting Git Repository Cleanup Script${NC}"
log_message "${BLUE} Log file: $LOG_FILE${NC}"
log_message "${BLUE} Dry Run Mode: $DRY_RUN${NC}"
log_message "${BLUE} Force Delete Mode: $FORCE_DELETE${NC}"
log_message "${BLUE}----------------------------------------------------${NC}"

# Ensure current directory is the one containing the repositories
if [ "$(pwd)" = "/" ] || [ "$(pwd)" = "$HOME" ]; then
    log_message "${RED}Error: It's recommended to run this script from a directory containing your Git projects, not the root or home directory.${NC}"
    log_message "${RED}Please navigate to the appropriate parent directory.${NC}"
    exit 1
fi

# Loop through all subdirectories in the current directory
for dir in */; do
    REPO_NAME=$(basename "$dir")
    log_message "" # Add a blank line for readability
    log_message "${BLUE}🚀 Checking repository: $REPO_NAME${NC}"

    # Check if it's a directory and if it contains a .git folder
    if [ -d "$dir" ] && [ -d "$dir/.git" ]; then
        cd "$dir" || { log_message "${RED}    ❌ Error: Could not enter directory '$REPO_NAME'. Skipping.${NC}"; ((ERROR_COUNT++)); continue; }

        log_message "    Fetching updates from origin..."
        git fetch origin >/dev/null 2>&1 # Suppress output unless there's an error
        if [ $? -ne 0 ]; then
            log_message "${YELLOW}    ⚠️ Warning: 'git fetch origin' failed for '$REPO_NAME'. Check network or repo access. Skipping further checks.${NC}"
            ((ERROR_COUNT++))
            cd ..
            continue
        fi

        # Get the current local branch and its remote tracking branch
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        remote_branch=$(git for-each-ref --format='%(upstream:short)' refs/heads/"$current_branch")

        if [ -z "$remote_branch" ]; then
            log_message "${YELLOW}    ⚠️ Warning: No upstream branch configured for '$current_branch' in '$REPO_NAME'. Cannot determine if up-to-date with remote. Skipping deletion.${NC}"
            ((SKIPPED_COUNT++))
            cd ..
            continue
        fi

        # Check the status for local changes
        status_output=$(git status --porcelain)

        # Get commit hashes
        local_commit=$(git rev-parse HEAD)
        remote_commit=$(git rev-parse "$remote_branch")

        # Determine the relationship between local and remote
        commits_behind=$(git rev-list --count "$local_commit".."$remote_commit" 2>/dev/null || echo 0)
        commits_ahead=$(git rev-list --count "$remote_commit".."$local_commit" 2>/dev/null || echo 0)

        # --- Decision Logic ---
        if [ -z "$status_output" ] && [ "$local_commit" == "$remote_commit" ]; then
            # Case 1: Local is perfectly up to date and clean
            log_message "${GREEN}    ✅ Folder '$REPO_NAME' is up to date with remote '$remote_branch'.${NC}"
            ((UP_TO_DATE_COUNT++))
            if confirm_delete "$REPO_NAME"; then
                log_message "${RED}    🗑️  Deleting folder '$REPO_NAME'...${NC}"
                cd .. # Go back up one directory before deleting
                if [ "$DRY_RUN" = false ]; then
                    rm -rf "$REPO_NAME"
                    if [ $? -eq 0 ]; then
                        log_message "${GREEN}    ✅ Folder '$REPO_NAME' deleted successfully.${NC}"
                        ((DELETED_COUNT++))
                    else
                        log_message "${RED}    ❌ Error deleting '$REPO_NAME'.${NC}"
                        ((ERROR_COUNT++))
                    fi
                fi
            else
                log_message "${YELLOW}    ↪ Folder '$REPO_NAME' not deleted.${NC}"
                ((SKIPPED_COUNT++))
            fi
        elif [ "$commits_behind" -gt 0 ]; then
            # Case 2: Remote is ahead of local
            log_message "${YELLOW}    ➡️  Folder '$REPO_NAME' is BEHIND the remote by $commits_behind commit(s).${NC}"
            log_message "${YELLOW}    This might indicate work done on a different path (another clone or machine).${NC}"
            ((BEHIND_COUNT++))
            if confirm_delete "$REPO_NAME"; then
                log_message "${RED}    🗑️  Deleting folder '$REPO_NAME'...${NC}"
                cd .. # Go back up one directory before deleting
                if [ "$DRY_RUN" = false ]; then
                    rm -rf "$REPO_NAME"
                    if [ $? -eq 0 ]; then
                        log_message "${GREEN}    ✅ Folder '$REPO_NAME' deleted successfully.${NC}"
                        ((DELETED_COUNT++))
                    else
                        log_message "${RED}    ❌ Error deleting '$REPO_NAME'.${NC}"
                        ((ERROR_COUNT++))
                    fi
                fi
            else
                log_message "${YELLOW}    ↪ Folder '$REPO_NAME' not deleted.${NC}"
                ((SKIPPED_COUNT++))
            fi
        elif [ "$commits_ahead" -gt 0 ] || [ ! -z "$status_output" ]; then
            # Case 3: Local is ahead or has local changes (or both)
            log_message "${BLUE}    🚧 Folder '$REPO_NAME' is NOT up to date with remote.${NC}"
            if [ "$commits_ahead" -gt 0 ]; then
                log_message "${BLUE}    Local is AHEAD of remote by $commits_ahead commit(s).${NC}"
                ((AHEAD_COUNT++))
            fi
            if [ ! -z "$status_output" ]; then
                log_message "${YELLOW}    Local uncommitted changes detected:${NC}"
                log_message "$(echo "$status_output" | sed 's/^/        /')" # Indent status output
                ((HAS_CHANGES_COUNT++))
            fi
            log_message "${BLUE}    Keeping folder '$REPO_NAME' due to local work.${NC}"
            ((SKIPPED_COUNT++)) # Counted as skipped because it wasn't deleted
        else
            # Fallback for unexpected states
            log_message "${YELLOW}    ❓ Folder '$REPO_NAME' is in an unusual or unhandled state. Keeping it.${NC}"
            ((SKIPPED_COUNT++))
        fi

        cd .. # Navigate back to the parent directory
    else
        # Not a Git repo or not a directory
        log_message "${BLUE}    ➡️  Skipping '$REPO_NAME' (not a Git repository or not a directory).${NC}"
        ((SKIPPED_COUNT++)) # Not a repo, so skipped for processing
    fi
done

# --- Summary ---
log_message ""
log_message "${BLUE}----------------------------------------------------${NC}"
log_message "${BLUE} Script Finished - Summary${NC}"
log_message "${BLUE}----------------------------------------------------${NC}"
log_message "${GREEN} Total Repositories Up to Date: $UP_TO_DATE_COUNT${NC}"
log_message "${YELLOW} Total Repositories Behind Remote: $BEHIND_COUNT${NC}"
log_message "${BLUE} Total Repositories Ahead of Remote: $AHEAD_COUNT${NC}"
log_message "${YELLOW} Total Repositories with Local Changes: $HAS_CHANGES_COUNT${NC}"
log_message "${RED} Total Repositories Deleted: $DELETED_COUNT${NC}"
log_message "${BLUE} Total Repositories Skipped (kept or not git repo): $SKIPPED_COUNT${NC}"
log_message "${RED} Total Errors Encountered: $ERROR_COUNT${NC}"
log_message "${BLUE} For detailed logs, see: $LOG_FILE${NC}"
log_message "${BLUE}----------------------------------------------------${NC}"

# Exit with success status
exit 0