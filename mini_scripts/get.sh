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
    github_link=$(git remote -v | awk 'NR==1{print $2}')
    OS=$(uname -s)
    if [ "$OS" = "Darwin" ]; then
        open $github_link
    elif [ "$OS" = "Linux" ]; then
        # Check if we are on Ubuntu or Debian
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
                xdg-open $github_link
            fi
        fi
    fi
}

push() {
    current_branch=$(git branch | awk '{print $2}')
    current_remote_name=$(git remote -v | awk 'NR==1{print $1}')
    if [ $# -gt 1 ]; then
        commit_message=$*
        # The first argument(push) will be there in the commit we need to remove it
        commit_message=${commit_message:5}
        echo -e "Commit message: "$commit_message"\n"
        echo -e "You are currently in: ${PWD}."
        read -p "Press Enter to continue or CTRL+C to abort..."
        git add . && git commit -m "$commit_message" && git push $current_remote_name $current_branch
    else
        echo "Please pass commit message"
    fi
}

pull() {
    current_branch=$(git branch | awk '{print $2}')
    current_remote_name=$(git remote -v | awk 'NR==1{print $1}')
    echo "Pulling updates from $current_remote_name/$current_branch..."
    git pull $current_remote_name $current_branch
}

if [ "$1" == "push" ]; then
    check_git_init
    push $*
elif [ "$1" == "link" ]; then
    check_git_init
    link
elif [ "$1" == "pull" ]; then
    check_git_init
    pull
else
    git status
    echo
    echo "Usage: get.sh {push | link | pull}"
    # exit 1
fi