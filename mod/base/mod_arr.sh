#! /usr/bin/env bash

set -u

if [[ -z "${ARR_MOD_FILE:-}" ]]; then

    declare -r ARR_MOD_FILE="mod_arr.sh"

    arr_zip () {
        local -n l_arr_1=$1
        local -n l_arr_2=$2
        local -n l_arr_3=$3
        if [[ ${#l_arr_1[@]} != ${#l_arr_2[@]} ]]; then
            echo "Error, arr_zip, len(l_arr_1)==${#l_arr_1[@]} != len(l_arr_2)==${#l_arr_2[@]}" >&2
            return 1
        fi
        l_arr_3=()
        for (( i = 0; i < ${#l_arr_1[@]}; i++ )); do
            l_arr_3+=("${l_arr_1[i]}" "${l_arr_2[i]}")
        done
        return 0
    }

    arr_merge () {
        local -n l_arr_1=$1
        local -n l_arr_2=$2
        local l_merge_str="$3"
        local -n l_arr_3=$4
        if [[ ${#l_arr_1[@]} != ${#l_arr_2[@]} ]]; then
            echo "Error, arr_zip, len(l_arr_1)==${#l_arr_1[@]} != len(l_arr_2)==${#l_arr_2[@]}" >&2
            return 1
        fi
        l_arr_3=()
        for (( i = 0; i < ${#l_arr_1[@]}; i++ )); do
            l_arr_3+=("${l_arr_1[i]}${l_merge_str}${l_arr_2[i]}")
        done
        return 0
    }

    arr_2_str () {
        local -n l_arr=$1
        local l_sep="$2"
        local -n l_str=$3
        l_arr_2=()
        for (( i = 0; i < ${#l_arr[@]}; i++ )); do
            l_str+="${l_str:+${l_sep}}${l_arr[i]}"
        done
    }

    arr_remove_last () {
        local -n l_arr=$1
        unset "l_arr[${#l_arr[@]}-1]"
        # l_arr=("${l_arr[@]:0:${#l_arr[@]}-1}")
    }

    test_arr_zip () {
        local -a arr_1=(a b c)
        local -a arr_2=(x y z)
        local -a arr_3=()
        local str=
        echo "arr_1 def is: ${arr_1[*]@A}"
        echo "arr_2 def is: ${arr_2[*]@A}"
        arr_zip arr_1 arr_2 arr_3
        echo "arr_3 after zip def is: ${arr_3[*]@A}"
        arr_merge arr_1 arr_2 ":" arr_3
        echo "arr_3 after merge def is: ${arr_3[*]@A}"
        arr_2_str arr_1 ":" str
        echo "str after 2 str def is: ${str@A}"
        arr_remove_last arr_3
        echo "arr_3 after remove last def is: ${arr_3[*]@A}"
    }

    if [[ "${0##*/}" == "$ARR_MOD_FILE" ]]; then
        echo "Module: <$0>"
        test_arr_zip
    fi

fi
