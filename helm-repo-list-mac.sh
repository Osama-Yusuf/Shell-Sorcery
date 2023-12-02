if [[ "$(uname)" == "Darwin" ]]; then
  helm search repo aquasec | awk '{print $1}' | grep -v -i NaMe | fzf | pbcopy
elif [[ "$(uname)" == "Linux" ]]; then
  helm search repo aquasec | awk '{print $1}' | grep -v -i NaMe | fzf | xclip -selection clipboard
else
    echo "Unknown operating system."
fi
