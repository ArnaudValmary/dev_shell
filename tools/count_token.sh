#! /usr/bin/env bash

set -u

declare -r prog_name="${0##*/}"
declare -r prog_name_short="${prog_name%.*}"
declare -r prog_version="2024-07-31 1.0"

declare -r cmd_awk='awk'

print_usage () {
    cat <<EOF
$prog_name_short, $prog_version
Usage: $prog_name [options] [input_filename(s)]

Standard options:

    -h, --help
        Print this help
    -V, --version
        Print version
    -v, --verbose
        Verbose/Debug mode
    --
        End of options

Output options:

    Header line

    --with_header
    --no_header
        With or without header line
        Default is with header
        This option is ignored if selected output format is JSON
    --header_(token|percent|occurrences) header_string_value
        Choose the column header.
        For text and CSV outputs:
            The default values are "Token", "Percent" and "Occurrences"
            With '--per_thousand' option, "Per thousand" value is used
            With '--per_ten_thousand' option, "Per ten thousand" value is used
        For JSON outputs:
            The default field names are "token", "percent" and "occurrences".
            With '--per_thousand' option, "perthousand" value is used
            With '--per_ten_thousand' option, "pertenthousand" value is used

    Data lines

    --with_cotes
    --no_cotes
        With or without cotes
        Default is with cotes
        This option is ignored if selected output format is CSV or JSON
    --cote[12] cote_string
        Choose the cote before (1) or after (2) printed token
        Default values are same and are simple cote "'"
        This option is ignored if selected output format is CSV or JSON
    --conv_format (%_format_string)
        The 'printf' like number format
        Default is '%3.2f'
    --use_locale
    --dont_use_locale
        Use or not locale numeric to print floats
        Default is use locale
        When use locale, CSV default separator will be ','
            instead of '.' if and only if ',' is in float numbers
    -%, --per_cent
    -‰, -%%, --per_mille, --per_thousand
    -‱, -%%%, --per_ten_thousand
        Compute ratio with per cent, thousand, or ten thousand
        Default is per cent
    --with_percent_sign
    --no_percent_sign
        With or without percent sign "%"
        Default is with percent sign
        This option is ignored if selected output format is JSON
        This option also modify the footer line percentage
        With option "--per_thousand" the default sign is "‰"
        With option "--per_ten_thousand" the default sign is "‱"
    -i, --cmp_ignore_case
    --no_cmp_ignore_case
        With or without ignore case during comparison
        Default is no ignore case
    -l, --lower
    -u, --upper
        With -i or --cmp_ignore_case option only.
        Convert token to lower/upper case.
        Default is uppercase.
    --print_ignore_case
    --no_print_ignore_case
        With or without ignore case during printing
        Default is no ignore case
        Note: All tokens on output are in uppercase

    Footer line

    --with_footer
    --no_footer
        With or without footer line
        Default is with footer
    --footer_total total_string_value
        Choose the total header string.
        For text and CSV outputs:
            The default value is "Total"
        For JSON outputs:
            The default field name is "total".

    Globals
    --of, --oformat (txt|csv|json)
        Output is text, CSV or JSON formatted
        Default output format is "txt"
    --sep sep_value
        Separator value
        For text:
            Default value is ' : '
        For CSV:
            Default value is ','

Sorting options:

    -s, -sort (t|o)
        Sort output by:
            t, token:       token value
            o, occurrences: occurrences value
        The default mode is by token value
    -r, --reverse, --desc
        Reverse order
    -n, --normal, --asc
        Normal order
        This is the default mode

Files options:

    --error_if_file_not_readable
    --warning_if_file_not_readable
        Print error and exit or just print warning on unreadable input file
        Default is print error and exit

input_filename(s)
    One or more input filenames
    If "STDIN" or "-" is present, the standard input is also read.
    If no input filenames given, the standard input is read.
EOF
}

print_version () {
    echo "$prog_name_short, $prog_version"
}

print_error () {
    local -i code=${2:-0}
    echo "ERROR: ${1:-}" >&2
    if [[ $code -gt 0 ]]; then
        exit $code
    fi
}

print_warning () {
    echo "WARNING: ${1:-}" >&2
}

print_verbose () {
    :
}

activate_verbose () {
    print_verbose () {
        echo "DEBUG: ${1:-}" >&2
    }
}

read_files () {
    local -i flag_read_stdin=$1
    shift
    cat "${@}" <(echo -n '')
    if [[ $flag_read_stdin -eq 1 ]]; then
        cat
    fi
}

declare -a awk_input_filenames=()
declare -a awk_options=()
declare -i flag_read_stdin=0
declare -i flag_use_locale=1

check_args () {
    local arg=
    local -i nb_arg=$#
    local -i flag_parameter=0
    local opt_arg=
    local -i flag_warning_if_file_not_readable=0
    local input_filename=
    local -a input_filenames=()

    while [[ $nb_arg -gt 0 ]]; do

        arg="$1"
        nb_arg+=-1
        shift
        print_verbose "ARG=<$arg>"

        if [[ $flag_parameter -eq 0 ]] && [[ "$arg" =~ ^- ]]; then
            case "$arg" in
                "-")
                    print_verbose "- READ STDIN (-)"
                    flag_read_stdin=1
                    flag_parameter=1
                ;;
                "--")
                    print_verbose "- END OF PARAMETERS"
                    flag_parameter=1
                ;;
                "--no_header")
                    print_verbose "- NO HEADER"
                    awk_options+=("-v" "flag_no_header=1")
                ;;
                "--with_header")
                    print_verbose "- WITH HEADER"
                    awk_options+=("-v" "flag_no_header=0")
                ;;
                "--no_footer")
                    print_verbose "- NO FOOTER"
                    awk_options+=("-v" "flag_no_footer=1")
                ;;
                "--with_footer")
                    print_verbose "- WITH FOOTER"
                    awk_options+=("-v" "flag_no_footer=0")
                ;;
                "--no_cotes")
                    print_verbose "- NO COTES"
                    awk_options+=("-v" "flag_no_cotes=1")
                ;;
                "--with_cotes")
                    print_verbose "- WITH COTES"
                    awk_options+=("-v" "flag_no_cotes=0")
                ;;
                "--no_percent_sign")
                    print_verbose "- NO PERCENT SIGN"
                    awk_options+=("-v" "flag_no_percent_sign=1")
                ;;
                "--with_percent_sign")
                    print_verbose "- WITH PERCENT SIGN"
                    awk_options+=("-v" "flag_no_percent_sign=0")
                ;;
                "--no_cmp_ignore_case")
                    print_verbose "- NO CMP IGNORE CASE"
                    awk_options+=("-v" "flag_cmp_ignorecase=0")
                ;;
                "-i"|"--cmp_ignore_case")
                    print_verbose "- WITH CMP IGNORE CASE"
                    awk_options+=("-v" "flag_cmp_ignorecase=1")
                ;;
                "-l"|"--lower")
                    print_verbose "- LOWER CASE"
                    awk_options+=("-v" "flag_lower=1")
                ;;
                "-u"|"--upper")
                    print_verbose "- UPPER CASE"
                    awk_options+=("-v" "flag_lower=0")
                ;;
                "--no_print_ignore_case")
                    print_verbose "- NO PRINT IGNORE CASE"
                    awk_options+=("-v" "flag_print_ignorecase=0")
                ;;
                "--print_ignore_case")
                    print_verbose "- WITH PRINT IGNORE CASE"
                    awk_options+=("-v" "flag_print_ignorecase=1")
                ;;
                "-%"|"--per_cent")
                    print_verbose "- PER CENT"
                    awk_options+=("-v" "param_per=cent")
                ;;
                "-‰"|"-%%"|"--per_mille"|"--per_thousand")
                    print_verbose "- PER THOUSAND"
                    awk_options+=("-v" "param_per=thousand")
                ;;
                "-‱"|"-%%%"|"--per_ten_thousand")
                    print_verbose "- PER TEN THOUSAND"
                    awk_options+=("-v" "param_per=ten_thousand")
                ;;
                "--use_locale")
                    print_verbose "- USE LOCALE"
                    flag_use_locale=1
                ;;
                "--dont_use_locale")
                    print_verbose "- DONT USE LOCALE"
                    flag_use_locale=0
                ;;
                "--header_token"|"--header_token="*|"--header_percent"|"--header_percent="*|"--header_occurrences"|"--header_occurrences="*|"--footer_total"|"--footer_total="*)
                    print_verbose "- HEADER/FOOTER"
                    local h_name="${arg#--}"
                    h_name="${h_name%%=*}"
                    print_verbose "  - NAME=<$h_name>"
                    if [[ "$arg" =~ ^--header_(token|percent|occurrences)= ]] || [[ "$arg" =~ ^--footer_(total)= ]]; then
                        opt_arg="${arg#*=}"
                        opt_arg="${opt_arg//\\/\\\\}"
                    else
                        if [[ $nb_arg -le 0 ]]; then
                            print_error "Argument required for option '$arg'" 2
                        fi
                        opt_arg="$1"
                        nb_arg+=-1
                        shift
                    fi
                    print_verbose "  - VALUE=<$opt_arg>"
                    awk_options+=("-v" "flag_param_$h_name=1" "-v" "param_$h_name=${opt_arg}")
                ;;
                "--cote"[12]|"--cote"[12]"="*)
                    print_verbose "- COTE"
                    local n_cote="${arg:6:1}"
                    print_verbose "  - N=<$n_cote>"
                    if [[ "$arg" =~ ^--cote[12]= ]]; then
                        opt_arg="${arg#*=}"
                        opt_arg="${opt_arg//\\/\\\\}"
                    else
                        if [[ $nb_arg -le 0 ]]; then
                            print_error "Argument required for option '$arg'" 2
                        fi
                        opt_arg="$1"
                        nb_arg+=-1
                        shift
                    fi
                    print_verbose "  - VALUE=<$opt_arg>"
                    awk_options+=("-v" "flag_param_cote_$n_cote=1" "-v" "param_cote_$n_cote=${opt_arg}")
                ;;
                "--sep"|"--sep="*)
                    print_verbose "- SEP"
                    if [[ "$arg" =~ ^--sep= ]]; then
                        opt_arg="${arg#*=}"
                        opt_arg="${opt_arg//\\/\\\\}"
                    else
                        if [[ $nb_arg -le 0 ]]; then
                            print_error "Argument required for option '$arg'" 2
                        fi
                        opt_arg="$1"
                        nb_arg+=-1
                        shift
                    fi
                    print_verbose "  - VALUE=<$opt_arg>"
                    awk_options+=("-v" "flag_sep=1" "-v" "param_sep=${opt_arg}")
                ;;
                "--conv_format"|"--conv_format="*)
                    print_verbose "- CONV FORMAT"
                    if [[ "$arg" =~ ^--conv_format= ]]; then
                        opt_arg="${arg#*=}"
                    else
                        if [[ $nb_arg -le 0 ]]; then
                            print_error "Argument required for option '$arg'" 2
                        fi
                        opt_arg="$1"
                        nb_arg+=-1
                        shift
                    fi
                    print_verbose "  - VALUE=<$opt_arg>"
                    awk_options+=("-v" "conv_format=${opt_arg}")
                ;;
                "-s"|"--sort"|"--sort="*)
                    print_verbose "- SORT"
                    if [[ "$arg" =~ ^--sort= ]]; then
                        opt_arg="${arg#*=}"
                    else
                        if [[ $nb_arg -le 0 ]]; then
                            print_error "Argument required for option '$arg'" 2
                        fi
                        opt_arg="$1"
                        nb_arg+=-1
                        shift
                    fi
                    case "$opt_arg" in
                        "t"|"token"|"o"|"occurrence")
                            opt_arg="${opt_arg:0:1}"
                        ;;
                        *)
                            print_error "Unknown value '$opt_arg' for option '$arg'" 3
                        ;;
                    esac
                    print_verbose "  - VALUE=<$opt_arg>"
                    awk_options+=("-v" "sort=$opt_arg")
                ;;
                "--of"|"--of="*|"--oformat"|"--oformat="*)
                    print_verbose "- OUTPUT FORMAT"
                    if [[ "$arg" =~ ^--(of|oformat)= ]]; then
                        opt_arg="${arg#*=}"
                    else
                        if [[ $nb_arg -le 0 ]]; then
                            print_error "Argument required for option '$arg'" 2
                        fi
                        opt_arg="$1"
                        nb_arg+=-1
                        shift
                    fi
                    case "$opt_arg" in
                        "txt"|"csv"|"json")
                            opt_arg="${opt_arg:0:1}"
                        ;;
                        *)
                            print_error "Unknown value '$opt_arg' for option '$arg'" 3
                        ;;
                    esac
                    awk_options+=("-v" "output_format=$opt_arg")
                ;;
                "-r"|"--desc"|"--reverse")
                    print_verbose "- REVERSE ORDER"
                    awk_options+=("-v" "flag_reverse=1")
                ;;
                "-n"|"--asc"|"--normal")
                    print_verbose "- NORMAL ORDER"
                    awk_options+=("-v" "flag_reverse=0")
                ;;
                "--warning_if_file_not_readable")
                    print_verbose "- WARNING IF FILE NOT READABLE"
                    flag_warning_if_file_not_readable=1
                ;;
                "--error_if_file_not_readable")
                    print_verbose "- ERROR IF FILE NOT READABLE"
                    flag_warning_if_file_not_readable=0
                ;;
                "-h"|"--help")
                    print_verbose "- HELP"
                    print_usage
                    exit 0
                ;;
                "-V"|"--version")
                    print_verbose "- VERSION"
                    print_version
                    exit 0
                ;;
                "-v"|"--verbose")
                    activate_verbose
                    print_verbose "- VERBOSE MODE"
                ;;
                *)
                    print_verbose "- UNKONW OPTION"
                    print_error "Unknown option '$arg'" 1
                ;;
            esac
            continue
        fi

        print_verbose "- PARAMETER"
        if [[ "$arg" == "-" ]] || [[ "$arg" == "STDIN" ]]; then
            print_verbose "  - READ STDIN"
            flag_read_stdin=1
        else
            input_filenames+=("$arg")
        fi

    done

    if [[ $flag_use_locale -eq 1 ]]; then
        print_verbose "AWK USE LOCALE NUMERIC"
        awk_options+=("--use-lc-numeric")
    fi

    print_verbose "CHECK FILENAMES"
    if [[ ${#input_filenames[@]} -lt 1 ]] && [[ $flag_read_stdin -eq 0 ]]; then
            print_verbose "  - READ STDIN (no input file)"
            flag_read_stdin=1
    fi
    for input_filename in "${input_filenames[@]}"; do
        if [[ ! -f "$input_filename" ]] || [[ ! -r "$input_filename" ]]; then
            if [[ $flag_warning_if_file_not_readable -eq 1 ]]; then
                print_warning "Input file '$input_filename' is not readable"
            else
                print_error "Input file '$input_filename' is not readable" 11
            fi
        else
            awk_input_filenames+=("$input_filename")
        fi
    done
}

check_args "${@}"
print_verbose "FILENAMES=<${awk_input_filenames[*]}>"
print_verbose "AWK OPTIONS=<${awk_options[*]}>"

# shellcheck disable=SC2016
read_files $flag_read_stdin "${awk_input_filenames[@]}" \
| $cmd_awk \
    "${awk_options[@]}" \
\ '
function txt2csv(s) {
    gsub(/"/, "\\\"", s)
    return "\"" s "\""
}
function txt2json(s) {
    gsub(/"/,  "\\\"", s)
    gsub(/\$/, "\\$",  s)
    gsub(/`/,  "\\`",  s)
    return s
}
function get_max(value_1, value_2) {
    if (value_1 < value_2) {
        return value_2
    }
    return value_1
}
function get_prct(max_value, n, divisor) {
    if (max_value == 0) {
        return 0.
    }
    return divisor * n / max_value
}
function get_prct_filler(prct, divisor) {
    prct_filler = ""
    while (divisor >= 10) {
        if (prct < divisor) {
            prct_filler = prct_filler " "
        }
        divisor /= 10
    }
    return prct_filler
}
function test_and_print(i, str1, str2) {
    if (i > 0) {
        printf(str1)
        return i
    }
    printf(str2)
    return i + 1
}
function test_coma_in_float() {
    if (0.5 ~ /,/) {
        return 1
    }
    return 0
}
function print_line(sep, token, n_token, max_len_token, len_add_prct, nb_token, apos1, apos2, percent_sign, divisor,    size_filler, prct, prct_filler) {
    size_filler = max_len_token - length(token) - length(apos1) - length(apos1)
    prct = get_prct(nb_token, n_token, divisor)
    prct_filler = get_prct_filler(prct, divisor)
    printf("%s%-s%s%*.*s%s%s%3.2f%s%*.*s%s%d\n", apos1, token, apos2, size_filler, size_filler, "", sep, prct_filler, prct, percent_sign, len_add_prct, len_add_prct, "", sep, n_token)
}
function print_footer_line(sep, token, n_token, max_len_token, len_add_prct, nb_token, percent_sign, divisor,    size_filler, prct, prct_filler) {
    size_filler = max_len_token - length(token)
    prct = get_prct(nb_token, n_token, divisor)
    prct_filler = get_prct_filler(prct, divisor)
    printf("%-s%*.*s%s%s%3.2f%s%*.*s%s%d\n", token, size_filler, size_filler, "", sep, prct_filler, prct, percent_sign, len_add_prct, len_add_prct, "", sep, n_token)
}
function print_line_csv(sep, token, n_token, nb_token, percent_sign, divisor) {
    printf("%s%s%s%s%s%d\n", txt2csv(token), sep, get_prct(nb_token, n_token, divisor), percent_sign, sep, n_token)
}
function print_line_json(token, n_token, nb_token, h_token, h_prct, h_occurrence, divisor,      i) {
    cmd = "\
        jq \
        --monochrome-output \
        --null-input \
        --arg h_token      \"" h_token         "\" \
        --arg token        \"" txt2json(token) "\" \
        --arg h_prct       \"" h_prct          "\" \
        --argjson prct     \"" get_prct(nb_token, n_token, divisor) "\" \
        --arg h_occurrence \"" h_occurrence    "\" \
        --argjson n_token  \"" n_token         "\" \
        \"\
            .[\\$h_token]      |= \\$token | \
            .[\\$h_prct]       |= \\$prct  | \
            .[\\$h_occurrence] |= \\$n_token \
        \" \
        "
    i = 0
    while ( ( cmd | getline result ) > 0 ) {
        i = test_and_print(i, "\n", "")
        printf("    %s", result)
    }
    close(cmd)
}
function print_header_line(sep, token, prct, occurrence, max_token_len, len_add_prct) {
    printf("%-*.*s%s%-s%*.*s%s%s\n", max_token_len, max_token_len, token, sep, prct, len_add_prct, len_add_prct, "", sep, occurrence)
}
function print_header_line_csv(sep, token, prct, occurrence) {
    printf("%s%s%s%s%s\n", txt2csv(token), sep, txt2csv(prct), sep, txt2csv(occurrence))
}
function print_footer_json(total_token, nb_token) {
    printf(",\n  \"%s\": %d", txt2json(total_token), nb_token)
}
BEGIN {
    flag_coma = test_coma_in_float()
    if (conv_format != "") {
        CONVFMT = conv_format
    } else {
        CONVFMT = "%3.2f"
    }
    if (flag_print_ignorecase == 1) {
        IGNORECASE=1
    } else {
        IGNORECASE=0
    }
    if (output_format == "c") {
        flag_csv = 1
        if (flag_coma) {
            sep=";"
        } else {
            sep=","
        }
    } else if (output_format == "j") {
        flag_json = 1
        flag_no_header = 0
        sep=""
    } else {
        sep=" : "
    }
    if (param_per == "thousand") {
        divisor = 1000
        percent_sign = "‰"
    } else if (param_per == "ten_thousand") {
        divisor = 10000
        percent_sign = "‱"
    } else {
        divisor = 100
        percent_sign = "%"
    }
    if (flag_no_percent_sign == 1) {
        percent_sign = ""
    }
    if (flag_sep == 1 && flag_json == 0) {
        sep = param_sep
    }
    if (flag_no_header == 1) {
        header_token      = ""
        header_percent    = ""
        header_occurrence = ""
    } else {
        if (flag_json == 1) {
            header_token      = "token"
            if (divisor == 1000) {
                header_percent    = "permille"
            } else if (divisor == 10000) {
                header_percent    = "pertenthousand"
            } else {
                header_percent    = "percent"
            }
            header_occurrence = "occurrences"
        } else {
            header_token      = "Token"
            if (divisor == 1000) {
                header_percent    = "Per mille"
            } else if (divisor == 10000) {
                header_percent    = "Per ten thousand"
            } else {
                header_percent    = "Percent"
            }
            header_occurrence = "Occurrences"
        }
        if (flag_param_header_token == 1) {
            header_token = param_header_token
        }
        if (flag_param_header_percent == 1) {
            header_percent = param_header_percent
        }
        if (flag_param_header_occurrences == 1) {
            header_occurrence = param_header_occurrences
        }
    }
    if (flag_no_footer == 1) {
        total_token = ""
    } else {
        if (flag_param_footer_total == 1) {
            total_token = param_footer_total
        } else if (flag_json == 1) {
            total_token = "total"
        } else {
            total_token = "Total"
        }
    }
    if (flag_no_cotes == 1) {
        apos1            = ""
        apos2            = apos1
    } else {
        apos1            = "\47"
        apos2            = apos1
        if (flag_param_cote_1 == 1) {
            apos1 = param_cote_1
        }
        if (flag_param_cote_2 == 1) {
            apos2 = param_cote_2
        }
    }
    len_apos = length(apos1) + length(apos2)
    if (sort == "") {
        sort = "t"
    }
    max_len_token    = 0
    if (flag_no_header == 0) {
        max_len_token = get_max(max_len_token, length(header_token))
    }
    if (flag_no_footer == 0) {
        max_len_token = get_max(max_len_token, length(total_token))
    }
    len_prct_100     = length((divisor + 0.1) percent_sign)
    len_prct_header  = length(header_percent)
    if (len_prct_100 < len_prct_header) {
        len_prct_line = len_prct_header - len_prct_100
        len_prct_head = 0
    } else {
        len_prct_line = 0
        len_prct_head = len_prct_100 - len_prct_header
    }
}
flag_cmp_ignorecase == 0 {
    arr_n_token[$0] += 1
}
flag_cmp_ignorecase == 1 {
    if (flag_lower == 1) {
        arr_n_token[tolower($0)] += 1
    } else {
        arr_n_token[toupper($0)] += 1
    }
}
{
    max_len_token = get_max(max_len_token, length($0) + len_apos)
    nb_token++
}
END {
    if (sort == "t") {
        if (flag_reverse == 1) {
            PROCINFO["sorted_in"] = "@ind_str_desc"
        } else {
            PROCINFO["sorted_in"] = "@ind_str_asc"
        }
    } else if (sort == "o") {
        if (flag_reverse == 1) {
            PROCINFO["sorted_in"] = "@val_num_desc"
        } else {
            PROCINFO["sorted_in"] = "@val_num_asc"
        }
    }
    if (flag_csv == 1) {
        if (flag_no_header == 0) {
            print_header_line_csv(sep, header_token, header_percent, header_occurrence)
        }
        for (token in arr_n_token) {
            print_line_csv(sep, token, arr_n_token[token], nb_token, percent_sign, divisor)
        }
        if (flag_no_footer == 0) {
            print_line_csv(sep, total_token, nb_token, nb_token, percent_sign, divisor)
        }
    } else if (flag_json == 1) {
        printf("{\n")
        i = 0
        printf("  \"data\": [")
        for (token in arr_n_token) {
            i = test_and_print(i, ",\n", "\n")
            print_line_json(token, arr_n_token[token], nb_token, header_token, header_percent, header_occurrence, divisor)
        }
        test_and_print(i, "\n  ", "")
        printf("]")
        if (flag_no_footer == 0) {
            print_footer_json(total_token, nb_token)
        }
        printf("\n}")
    } else {
        if (flag_no_header == 0) {
            print_header_line(sep, header_token, header_percent, header_occurrence, max_len_token, len_prct_head)
        }
        for (token in arr_n_token) {
            print_line(sep, token, arr_n_token[token], max_len_token, len_prct_line, nb_token, apos1, apos2, percent_sign, divisor)
        }
        if (flag_no_footer == 0) {
            print_footer_line(sep, total_token, nb_token, max_len_token, len_prct_line, nb_token, percent_sign, divisor)
        }
    }
}
'

exit $?
