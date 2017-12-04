#!/bin/bash

tmux new-session -d 'htop'
sudo --validate
tmux new-window -n '**ROOT**' 'sudo -i'
tmux new-window 'bash'
tmux attach-session -d

