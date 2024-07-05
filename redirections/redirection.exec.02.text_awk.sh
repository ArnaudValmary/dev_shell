#! /usr/bin/env bash

# Outputs before redirections
echo "Before redirection 1"
echo "Before redirection 2" >&2

declare -r log_timestamp_format="%Y-%m-%dT%H:%M:%S"
declare -r logger_id="the_logger"
declare -r log_filename="./the_log.log"

# Format function with awk
print_log_awk () {
    awk \
        -v timestamp_format="$log_timestamp_format" \
        -v logger_id="$logger_id" \
        '
            {
                printf("%s %s %s\n", logger_id, strftime(timestamp_format), $0)
            }
        ' \
    > "$log_filename"
}

# Redirections
exec 3>&1 4>&2 &> >(print_log_awk)

# Outputs after redirections
echo "STDOUT message"
sleep 3
echo "STDERR message" >&2

# Restorations
exec 1>&3 2>&4

# Outputs after restorations
echo "End of redirection 1"
echo "End of redirection 2" >&2
