#! /usr/bin/env bash

set -u

if [[ -z "${INPUT_STD_MOD_FILE:-}" ]]; then

    declare -r INPUT_STD_MOD_FILE="mod_std.sh"
    declare -r INPUT_STD_NULL_VALUE="__NULL__"
    declare -r INPUT_STD_MULTI_VALUE_OTHER="__OTHER__"
    declare -r INPUT_STD_MULTI_DISP_OTHER="other value"
    declare -r INPUT_STD_MULTI_VALUE_SEP=":::"

    std_ask () {
        local l_var_name=$1
        local -n l_var_value=$1
        shift
        local -a read_with_options=("read" "-r")
        local -i flag_prompt=0
        local prompt=
        local -i flag_silent=0
        local -i flag_print_value=1
        local -i flag_accept_empty_value=1
        local -i flag_use_default_value_if_empty=0
        local -i flag_multi=0
        local -a values_real=()
        local -a values_disp=()
        local default_value=
        local multi_sep_value="$INPUT_STD_MULTI_VALUE_SEP"
        local multi_disp_other="$INPUT_STD_MULTI_DISP_OTHER"
        local -i choice_int=0
        local -i flag_choice_other=0
        local -i flag_check=0
        while [[ $# -gt 0 ]]; do
            arg="$1"
            shift
            case "$arg" in
                "--no_check")
                    flag_check=0
                ;;
                "-c"|"--check")
                    flag_check=1
                ;;
                "--no_empty")
                    flag_accept_empty_value=0
                ;;
                "--accept_empty")
                    flag_accept_empty_value=1
                ;;
                "--no_print_value")
                    flag_print_value=0
                ;;
                "--print_value")
                    flag_print_value=1
                ;;
                "-p"|"--prompt")
                    if [[ $# -eq 0 ]]; then
                        echo "Option '$arg' for '${FUNCNAME[0]}' function require a parameter" >&2
                        exit 1
                    fi
                    prompt="$1"
                    read_with_options+=("-p" "$prompt")
                    flag_prompt=1
                    shift
                ;;
                "--sep_value")
                    if [[ $# -eq 0 ]]; then
                        echo "Option '$arg' for '${FUNCNAME[0]}' function require a parameter" >&2
                        exit 1
                    fi
                    multi_sep_value="$1"
                    shift
                ;;
                "--no_default")
                    default_value=
                    flag_use_default_value_if_empty=0
                ;;
                "-d"|"--default")
                    if [[ $# -eq 0 ]]; then
                        echo "Option '$arg' for '${FUNCNAME[0]}' function require a parameter" >&2
                        exit 1
                    fi
                    default_value="$1"
                    flag_use_default_value_if_empty=1
                    shift
                ;;
                "--do_not_use_default_value_if_empty")
                    flag_use_default_value_if_empty=0
                ;;
                "--use_default_value_if_empty")
                    flag_use_default_value_if_empty=1
                ;;
                "--view_entry")
                    flag_silent=0
                ;;
                "-s"|"--silent_entry")
                    flag_silent=1
                ;;
                "-m"|"--multi")
                    if [[ $# -eq 0 ]]; then
                        echo "Option '$arg' for '${FUNCNAME[0]}' function require a parameter" >&2
                        exit 1
                    fi
                    flag_multi=1
                    values_real=("${@}")
                    shift ${#@}
                ;;
                "-o"|"--other")
                    flag_choice_other=1
                ;;
                "--other_disp")
                    if [[ $# -eq 0 ]]; then
                        echo "Option '$arg' for '${FUNCNAME[0]}' function require a parameter" >&2
                        exit 1
                    fi
                    multi_disp_other="$1"
                    shift
                ;;
                *)
                    echo "Unknown paramater '$arg' for '${FUNCNAME[0]}' function" >&2
                    exit 1
                ;;
            esac
        done
        local l_input=
        local -i flag_res_ok=0
        [[ $flag_silent -eq 1 ]] && read_with_options+=("-s")
        if [[ $flag_multi -eq 1 ]]; then
            local -i i=0
            local ps3_saved="${PS3:-${INPUT_STD_NULL_VALUE}}"
            if [[ $flag_choice_other -eq 1 ]]; then
                values_real+=("${INPUT_STD_MULTI_VALUE_OTHER}${multi_sep_value}${multi_disp_other}")
            fi
            for (( i = 0; i < ${#values_real[@]}; i++ )); do
                tmp_value_real="${values_real[i]}"
                if [[ "$tmp_value_real" =~ ^.*${multi_sep_value}.*$ ]]; then
                    values_disp[i]="${tmp_value_real#*${multi_sep_value}}"
                    values_real[i]="${tmp_value_real%%${multi_sep_value}*}"
                else
                    values_disp[i]="$tmp_value_real"
                fi
            done
            local -i arr_size="${#values_real[@]}"
            if [[ $flag_prompt -eq 1 ]]; then
                PS3="$prompt"
            fi
        fi
        while [[ $flag_res_ok -eq 0 ]]; do
            if [[ $flag_multi -eq 0 ]]; then
                while true; do
                    "${read_with_options[@]}" l_input
                    if [[ -n "$l_input" ]] || [[ $flag_use_default_value_if_empty -eq 1 ]] || [[ $flag_accept_empty_value -eq 1 ]]; then
                        if [[ -z "$l_input" ]] && [[ $flag_use_default_value_if_empty -eq 1 ]]; then
                            l_input="$default_value"
                        fi

                        break
                    fi
                done
            else
                select l_input in "${values_disp[@]}"; do
                    l_input="${l_input:-$INPUT_STD_NULL_VALUE}"
                    if [[ "$l_input" == "$INPUT_STD_NULL_VALUE" ]]; then
                        echo "Invalid choice" >&2
                    else
                        choice_int=$REPLY
                        l_var_value="${values_real[$choice_int-1]}"
                        if [[ $choice_int -eq $arr_size ]] && [[ "$l_var_value" == "$INPUT_STD_MULTI_VALUE_OTHER" ]]; then
                            [[ $flag_silent -eq 1 ]] && read_with_options+=("-s")
                            while true; do
                                "${read_with_options[@]}" l_input
                                if [[ -z "$l_input" ]]; then
                                    if [[ $flag_use_default_value_if_empty -eq 1 ]]; then
                                        l_input="$default_value"
                                        break
                                    elif [[ $flag_accept_empty_value -eq 1 ]]; then
                                        break
                                    fi
                                else
                                    break
                                fi
                            done
                        fi
                        break
                    fi
                done
                if [[ "$ps3_saved" == "$INPUT_STD_NULL_VALUE" ]]; then
                    unset PS3
                else
                    PS3="$ps3_saved"
                fi
            fi
            flag_res_ok=1
            if [[ $flag_check -eq 1 ]]; then
                local res=
                read -r -p "Are you agree with value '$l_input'? (Yes/no)" res
                if [[ ! "$res" =~ ^[yY]([eE][sS])?$ ]] && [[ "$res" != "" ]]; then
                    flag_res_ok=0
                fi
            fi
            l_var_value="$l_input"
        done
        [[ $flag_silent -eq 1 ]] && flag_print_value=0
        if [[ $flag_print_value -eq 1 ]]; then
            echo "$l_var_name='$l_var_value'"
        elif [[ $flag_prompt -eq 1 ]]; then
            echo
        fi
    }

    test_std_ask () {
        lt_var_name=
        std_ask lt_var_name <<<"response"
        echo "value=<$lt_var_name>"
        std_ask lt_var_name -p "the prompt: " <<<"response"
        echo "value=<$lt_var_name>"
        std_ask lt_var_name -s <<<"response"
        echo "value=<$lt_var_name>"
        std_ask lt_var_name -p "the prompt: " -s <<<"response"
        echo "value=<$lt_var_name>"
        std_ask lt_var_name -p "the prompt: " --no_empty <<<"response"
        echo "value=<$lt_var_name>"
        std_ask lt_var_name -p "the prompt: " --default "aaa" <<<"response"
        echo "value=<$lt_var_name>"
        std_ask lt_var_name -p "the prompt: " --default "aaa" <<<""
        echo "value=<$lt_var_name>"
        std_ask lt_var_name -p "the prompt: " -m "a:::value a" "b" "c:::value c" <<<"3"
        echo "value=<$lt_var_name>"
        std_ask lt_var_name -p "the prompt: " -o --other_disp "not in the list" -m "a:::value a" "b" "c:::value c" <<EOF
4
the value
EOF
        echo "value=<$lt_var_name>"
        std_ask lt_var_name -p "> " -c <<EOF
test
no
v2
yes
EOF
        echo "value=<$lt_var_name>"
        std_ask lt_var_name -p "> " -o -c -m "a" "b" <<EOF
3
elt
n
3
v3
Y
EOF
        echo "value=<$lt_var_name>"
    }

    if [[ "${0##*/}" == "$INPUT_STD_MOD_FILE" ]]; then
        echo "Module: <$0>"
        test_std_ask
    fi

fi
