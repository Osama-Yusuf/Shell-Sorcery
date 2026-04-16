#!/bin/bash

# set -x

# Function to check if the current directory is a Git repository
check_git_init() {
    # Try to get the root directory of the current Git repository
    git rev-parse --show-toplevel > /dev/null 2>&1
    # Check if the command was successful
    if [ $? -ne 0 ]; then
        echo "The current directory is not a Git repository."
        exit 1
    else
        echo "" > /dev/null 2>&1
    fi
}

link() {
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    github_link=$(git remote get-url origin)

    # Normalize SSH URL to HTTPS and strip .git suffix

    github_link=$(echo "$github_link" \
        | sed 's|git@github.com:|https://github.com/|' \
        | sed 's|\.git$||')

    github_link="${github_link}/tree/${current_branch}"


    OS=$(uname -s)
    if [ "$OS" = "Darwin" ]; then
        open "$github_link"
    elif [ "$OS" = "Linux" ]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
                xdg-open "$github_link"
            fi
        fi
    fi
}

push() {
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    current_remote_name=$(git config --get "branch.${current_branch}.remote" || echo "origin")
    shift  # remove "push" from $@
    if [ $# -ge 1 ]; then
        commit_message="$*"
        # The first argument(push) will be there in the commit we need to remove it
        commit_message=${commit_message:5}
        echo -e "Commit message: "$commit_message"\n"
        echo -e "You are currently in: ${PWD}. ${current_remote_name}/${current_branch}"
        read -p "Press Enter to continue or CTRL+C to abort..."
        git add . && git commit -m "$commit_message" && git push $current_remote_name $current_branch
    else
        echo "Please pass commit message"
    fi
}

pull() {
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    current_remote_name=$(git config --get "branch.${current_branch}.remote" || echo "origin")
    echo "Pulling updates from $current_remote_name/$current_branch..."
    git pull $current_remote_name $current_branch
}

pr() {
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    github_link=$(git remote get-url origin)

    # Normalize SSH URL to HTTPS and strip .git suffix
    github_link=$(echo "$github_link" \
        | sed 's|git@github.com:|https://github.com/|' \
        | sed 's|\.git$||')

    # Extract org/repo from the URL
    repo_path=$(echo "$github_link" | sed 's|https://github.com/||')

    # echo "Looking for PR on branch: $current_branch..."

    # Query GitHub API for open PR matching current branch
    pr_number=$(curl -s \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/${repo_path}/pulls?head=${repo_path%%/*}:${current_branch}&state=open" \
        | grep -o '"number": *[0-9]*' | head -1 | grep -o '[0-9]*')

    if [ -z "$pr_number" ]; then
        echo "No open PR found for branch '$current_branch'."
        exit 1
    fi

    pr_link="${github_link}/pull/${pr_number}"
    # echo "Opening: $pr_link"

    OS=$(uname -s)
    if [ "$OS" = "Darwin" ]; then
        open "$pr_link"
    elif [ "$OS" = "Linux" ]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
                xdg-open "$pr_link"
            fi
        fi
    fi
}


if [ "$1" == "push" ]; then
    check_git_init
    push $*
elif [ "$1" == "link" ]; then
    check_git_init
    link
elif [ "$1" == "pr" ]; then
    check_git_init
    pr
elif [ "$1" == "pull" ]; then
    check_git_init
    pull
else
    git fetch > /dev/null 2>&1
    git status
    echo
    echo "Usage: get.sh {push | link | pull}"
    # exit 1
fi
