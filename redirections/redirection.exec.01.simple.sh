#! /usr/bin/env bash

# Outputs before redirections
echo "Before redirection 1"
echo "Before redirection 2" >&2

declare -r log_filename="./the_log.log"

# Redirections
exec 3>&1 4>&2 &>"$log_filename"

# Outputs after redirections
echo "STDOUT message"
sleep 3
echo "STDERR message" >&2

# Restorations
exec 1>&3 2>&4

# Outputs after restorations
echo "End of redirection 1"
echo "End of redirection 2" >&2
