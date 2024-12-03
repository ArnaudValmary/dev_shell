#! /usr/bin/env bash
# shellcheck disable=SC2034

# https://en.wikipedia.org/wiki/Byte

declare -r -i byte_ki=$(( 2 ** 10 ))
declare -r -i byte_mi=$(( byte_ki * byte_ki ))
declare -r -i byte_gi=$(( byte_mi * byte_ki ))
declare -r -i byte_ti=$(( byte_gi * byte_ki ))
declare -r -i byte_pi=$(( byte_ti * byte_ki ))
