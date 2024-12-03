#! /usr/bin/env bash

function type.is_integer {
    [[ "${1:-0}" =~ ^-?([1-9][0-9]*|0)$ ]] && return 0 || return 1
}

function type.is_positive_integer {
    [[ "${1:-0}" =~ ^([1-9][0-9]*|0)$ ]] && return 0 || return 1
}

function type.is_strictly_positive_integer {
    [[ "${1:-0}" =~ ^([1-9][0-9]*)$ ]] && return 0 || return 1
}
