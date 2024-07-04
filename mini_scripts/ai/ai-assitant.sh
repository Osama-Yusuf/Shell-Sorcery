#!/bin/bash

# check if arguments are less then 4
if [ $# -lt 4 ]; then
    echo "Usage: $0 -yt <youtube url> and -p <pattern>"
    exit 1
fi

# for e.g. these are types of wisdom and tutorial vids to pass
# wisdom link= https://youtu.be/pdJQ8iVTwj8
# tutorial link= https://youtu.be/bp2eev21Qfo

# Initialize default LLM
default_llm="llama3"

# Define patterns as variables
wisdom="Summary of the meeting, key ideas, topics discussed, main points, essential keywords, valuable insights for improvement, impactful quotes, recommended habits for personal growth, notable opinions, sources of inspiration, and discussion questions in english"

# wisdom_old="summery of that meeting ideas out of that meeting to help me improve, topics of that meeting, keypoints, keywords, insights out of that meeting to help me improve, quotes out of that meeting to help me improve, habits out of that meeting to do to be a better person, hot takes, inspiration, discussion questions"

tutorial="Provide a clear, detailed, step-by-step guide with commands for achieving this tutorial's objectives. Format it in an engaging and interactive manner. Include additional tips for enhancement and your insights on improving the tutorial. Share your perspective on the topic and suggest any superior alternatives if available in english"

# tutorial_old="give a simplified and detailed well formatted step-by-step tutorial/commands on how to achieve this tutorial transcript goal in a cool and interactive way and add additional tips. and how to make it better and improve it. and your opinion on the subject. and if there's a better alternative"

summerize="Please summarize the key topics covered in this video, ensuring the summary is clear and concise. but first Generate a title for this at the top and below list the key points then the fat summery. Additionally, offer tips for improvement on the discussed topic, and share your insights and perspectives"

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
    summerize)
        pattern_value="$summerize"
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
clear
eval $command