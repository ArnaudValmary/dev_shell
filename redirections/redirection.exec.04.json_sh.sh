#! /usr/bin/env bash

# Outputs before redirections
echo "Before redirection 1"
echo "Before redirection 2" >&2

declare -r log_timestamp_format="%Y-%m-%dT%H:%M:%S%:z"
declare -r logger_id="the_logger"
declare -r log_filename="./the_log.log"

declare -r bs=$'\b'
declare -r ff=$'\f'
declare -r lf=$'\n'
declare -r cr=$'\r'
declare -r tb=$'\t'

txt_2_json () {
    local txt="$1"
    local -n json="$2"
    json="$txt"
    json="${json//\\/\\\\}"
    json="${json//\"/\\\"}"
    json="${json//\//\\/}"
    json="${json//$bs/\\b}"
    json="${json//$ff/\\f}"
    json="${json//$lf/\\n}"
    json="${json//$cr/\\r}"
    json="${json//$tb/\\t}"
}

if which gdate >/dev/null 2>&1; then
    cmd_date="gdate"
else
    cmd_date="date"
fi

# Format function with jq
print_log_sh () {
    local json_txt=
    txt_2_json "$(cat)" json_txt
    # shellcheck disable=SC2155
    local timestamp=$($cmd_date +"$log_timestamp_format")
    local file_name=
    txt_2_json "${BASH_SOURCE[1]}" file_name
    local func_name=
    txt_2_json "${FUNCNAME[1]}" func_name
    local line_no=
    txt_2_json "${BASH_LINENO[0]}" line_no
    printf "{\"@timestamp\": \"%s\", \"logger\": \"%s\", \"path\": \"%s\", \"filename\": \"%s\", \"func_name\": \"%s\", \"lineno\": \"%s\", \"message\": \"%s\"}\n" "$timestamp" "$logger_id" "$file_name" "${file_name##*/}" "$func_name" "$line_no" "$json_txt" >> "$log_filename"
}

f () {
    echo "IN 'f'" | print_log_sh
}

f

g ()  {
    f
}

g

# Outputs after redirections
echo "STDOUT message" | print_log_sh
sleep 3
echo "STDERR message" | print_log_sh

# Outputs after restorations
echo "End of redirection 1"
echo "End of redirection 2" >&2
