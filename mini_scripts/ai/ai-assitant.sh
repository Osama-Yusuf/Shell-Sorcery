#!/bin/bash

# check if arguments are less then 4
if [ $# -lt 4 ]; then
    echo "Usage: $0 -yt <youtube url> and -p <pattern>"
    exit 1
fi

# Initialize default LLM
default_llm="llama3"

# Define patterns as variables
wisdom="summery of that meeting ideas out of that meeting to help me improve, topics of that meeting, keypoints, keywords, insights out of that meeting to help me improve, quotes out of that meeting to help me improve, habits out of that meeting to do to be a better person, hot takes, inspiration, discussion questions"

tutorial="give a simplified and detailed well formatted step-by-step tutorial/commands on how to achieve this tutorial transcript goal in a cool and interactive way and add additional tips. and how to make it better and improve it. and your opinion on the subject. and if there's a better alternative"


if [ "$1" == "-yt" ]; then
    youtube_url=$2
    if [ "$3" == "-p" ]; then
        pattern=$4
        if [ "$5" == "-llm" ]; then
            llm=$6
        fi
    fi
fi

usage() {
    echo "Usage: $0 -yt <youtube url> -p <pattern> [-llm <llm>]"
    echo "  -yt  Specify the YouTube URL"
    echo "  -p   Specify the pattern (wisdom or tutorial)"
    echo "  -llm Optional: Specify the LLM (default: $default_llm)"
    exit 1
}

# Check if mandatory arguments are not empty
if [[ -z $youtube_url || -z $pattern ]]; then
    echo "Usage: $0 -yt <youtube url> and -p <pattern>"
    usage
fi

# Set the LLM to default if not provided
if [[ -z $llm ]]; then
    llm="$default_llm"
fi

# Check the pattern and set the variable accordingly
case $pattern in
    wisdom)
        pattern_value="$wisdom"
    ;;
    tutorial)
        pattern_value="$tutorial"
    ;;
    *)
        echo "Invalid pattern: $pattern"
        usage
    ;;
esac

command="yt --transcript '$youtube_url' | ollama run $llm \"$pattern_value\""

# echo "youtube url: $youtube_url"
# echo "pattern: $pattern"
# echo "pattern value: $pattern_value"
# echo "llm: $llm"
# echo "Executing: $command"

eval $command