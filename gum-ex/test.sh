#!/bin/sh

# # Choose
# gum choose Foo Bar Baz
# gum choose Choose One Item --cursor "* " --cursor.foreground 99 --selected.foreground 99
# gum choose Pick Two Items Maximum --limit 2 --cursor "* " --cursor-prefix "(•) " --selected-prefix "(x) " --unselected-prefix "( ) " --cursor.foreground 99 --selected.foreground 99
# gum choose Unlimited Choice Of Items --no-limit --cursor "* " --cursor-prefix "(•) " --selected-prefix "(x) " --unselected-prefix "( ) " --cursor.foreground 99 --selected.foreground 99

# # Confirm
# gum confirm "Testing?"
# gum confirm "No?" --default=false --affirmative "Okay." --negative "Cancel."

# # Filter
# gum filter
# echo {1..500} | sed 's/ /\n/g' | gum filter
# echo {1..500} | sed 's/ /\n/g' | gum filter --indicator ">" --placeholder "Pick a number..." --indicator.foreground 1 --text.foreground 2 --match.foreground 3 --prompt.foreground 4 --height 5

# # Format
# echo "# Header\nBody" | gum format 
# echo 'package main\n\nimport "fmt"\n\nfunc main() {\n\tfmt.Println("Hello, Gum!")\n}\n' | gum format -t code
# echo ":candy:" | gum format -t emoji
# echo '{{ Bold "Bold" }}' | gum format -t template

# # Input
# gum input
# gum input --prompt "Email: " --placeholder "john@doe.com" --prompt.foreground 99 --cursor.foreground 99 --width 50
# gum input --password --prompt "Password: " --placeholder "hunter2" --prompt.foreground 99 --cursor.foreground 99 --width 50

# # Join
# gum join "Horizontal" "Join"
# gum join --vertical "Vertical" "Join"

# gum: error: --spinner must be one of "line","dot","minidot","jump","pulse","points","globe","moon","monkey","meter","hamburger" but got "--help"

# gum spin -- sleep 2
# gum spin --spinner dot --title "dot" --title.foreground 99 -- sleep 2
# gum spin --spinner minidot --title "minidot" --title.foreground 99 -- sleep 2
# gum spin --spinner jump --title "jump" --title.foreground 99 -- sleep 2
# gum spin --spinner pulse --title "pulse" --title.foreground 99 -- sleep 2
# gum spin --spinner points --title "points" --title.foreground 99 -- sleep 2
# gum spin --spinner globe --title "globe" --title.foreground 99 -- sleep 2
# gum spin --spinner moon --title "moon" --title.foreground 99 -- sleep 2
# gum spin --spinner meter --title "meter" --title.foreground 99 -- sleep 2
# gum spin --spinner hamburger --title "hamburger" --title.foreground 99 -- sleep 2
# gum spin --show-output --spinner monkey --title "monkey" --title.foreground 99 -- sh -c 'sleep 3; echo "Hello, Gum!"'

# Spin
gum spin -- sleep 3 --title "Generating commit message..." 
gum spin --spinner dot --title "Generating commit message..." --title.foreground 99 -- sleep 3 
gum spin --spinner minidot --title "Generating commit message..." --title.foreground 99 -- sleep 3 
gum spin --spinner jump --title "Generating commit message..." --title.foreground 99 -- sleep 3 
gum spin --spinner pulse --title "Generating commit message..." --title.foreground 99 -- sleep 3 
gum spin --spinner points --title "Generating commit message..." --title.foreground 99 -- sleep 3 
gum spin --spinner globe --title "Generating commit message..." --title.foreground 99 -- sleep 3 
gum spin --spinner moon --title "Generating commit message..." --title.foreground 99 -- sleep 3 
gum spin --spinner meter --title "Generating commit message..." --title.foreground 99 -- sleep 3 
gum spin --spinner hamburger --title "Generating commit message..." --title.foreground 99 -- sleep 3 
gum spin --show-output --spinner monkey --title "Generating commit message..." --title.foreground 99 -- sh -c 'sleep 3; echo "Hello, Gum!"'

# # Style
# gum style --foreground 99 --border double --border-foreground 99 --padding "1 2" --margin 1 "Hello, Gum."

# # Write
# gum write
# gum write --width 40 --height 6 --placeholder "Type whatever you want" --prompt "| " --show-cursor-line --show-line-numbers --value "Something..." --base.padding 1 --cursor.foreground 99 --prompt.foreground 99

# # Table
# gum table < table/example.csv

# # Pager
# gum pager < README.md

# # File
# gum file
