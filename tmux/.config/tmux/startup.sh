#!/bin/bash

# Function to create a new session if it doesn't exist
create_session() {
  session_name=$1
  window_name=$2
  command=$3

  if ! tmux has-session -t $session_name 2>/dev/null; then
    tmux new-session -d -s $session_name -n $window_name
    if [ -n "$command" ]; then
      tmux send-keys -t $session_name "$command" C-m
    fi
  fi
}

# Create the Notes session
#
create_session "notes" "notes" "nvim ~/Projekte/personal/Knowledge/"

# Create the Personal session
create_session "personal" "home" ""

# Create the Work session
create_session "work" "tasks" ""

# Attach to the tmux session (default to notes)
if [ -z "$TMUX" ]; then
  tmux attach-session -t notes
fi
