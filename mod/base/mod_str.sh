#! /usr/bin/env bash

function str.mult () {
    [[ $2 -le 0 ]] && return
    local -i local_s_m_nb="$2"
    local local_s_m_result=""
    while [[ $local_s_m_nb -gt 0 ]]; do
        local_s_m_nb+=-1
        local_s_m_result+="$1"
    done
    printf "%s" "${local_s_m_result}"
}

function str.shrink_left () {
    [[ $2 -le 0 ]] && return
    printf "%s" "${1:0:$2}"
}

function str.shrink_right () {
    [[ $2 -le 0 ]] && return
    printf "%s" "${1: -$2}"
}

function str.reverse () {
    local -i local_s_r_idx="${#1}"
    local local_s_r_result=""
    while [[ ${local_s_r_idx} -gt 0 ]]; do
        local_s_r_idx+=-1
        local_s_r_result+="${1:local_s_r_idx:1}"
    done
    printf "%s" "${local_s_r_result}"
}

function str.pad_left () {
    printf "%s%*s" "$1" $(( $2 - ${#1} )) ""
}

function str.pad_right () {
    printf "%*s%s" $(( $2 - ${#1} )) "" "$1"
}

function str.center () {
    local local_s_c_result=""
    local -i local_s_c_pad=$(( ( $2 - ${#1} ) / 2 ))
    if [[ $local_s_c_pad -gt 0 ]] && [[ $(( local_s_c_pad * 2 + ${#1} )) -lt $2 ]]; then
        local_s_c_result=" "
    fi
    printf "%*s%s%s%*s" $local_s_c_pad "" "${1}" "${local_s_c_result}" $local_s_c_pad ""
}
