#! /usr/bin/env bash

function call {
    if [[ ${DEBUG_CALL} == YES ]]; then
        call_print "${@}"
    fi
    "${@}"
    return $?
}


function call_print {
    echo "Command:"
    echo -n "  $1"
    if [[ $# -gt 1 ]]; then
        echo " \\"
        local -r call_tb=$'\t'
        local -a -r args=("${@}")
        local -i i=0
        local -i n=0
        local -i continue=0
        local -i params=0
        local v=
        for (( i=1 ; i < $# ; i++ )); do
            v="${args[i]}"
            n=$(( i + 1 ))
            if [[ $continue -eq 0 ]]; then
                echo -n "    "
            else
                continue=0
            fi
            if [[ "$v" =~ (\ |\"|$call_tb|\*|\?|\(|\)|\[|\]|\{|\}|\~|\&|\||\#|\'|\`|\\|\$|\!|\;|\') ]]; then
                v="${v//\\/\\\\}"
                v="${v//\"/\\\"}"
                v="${v//${call_tb}/\\\t}"
                echo -n "\"$v\""
            else
                echo -n "$v"
            fi
            if [[ $n -lt $# ]]; then
                if [[ $params -eq 0 ]] && [[ "${args[n]}" =~ ^- ]]; then
                    echo " \\"
                elif [[ $params -eq 0 ]] && [[ "${args[i]}" == "--" ]]; then
                    params=1
                    echo " \\"
                else
                    echo -n " "
                    continue=1
                fi
            else
                echo
            fi
        done
    else
        echo
    fi
    echo
}
