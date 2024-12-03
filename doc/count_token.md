# Count token

| Name | Language |
|:---|:---|
| `count_token.sh` | Bash |

## Synopsis

`count_token.sh` is a simple tool to count token occurrences.

## Usage

```bash
count_token.sh --help
```

```text
count_token, 2024-07-31 1.0
Usage: count_token.sh [options] [input_filename(s)]

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
```

## Examples

With this input file:

```text
AAA
BBB
AAA
CCC
BBB
CCC
AAA
AAA
B
AAA
AAA
```

### Basic text output (human readable)

```bash
count_token.sh example.txt
```

Result:

```text
Token   : Percent : Occurrences
'AAA'   :  54.55% : 6
'B'     :   9.09% : 1
'BBB'   :  18.18% : 2
'CCC'   :  18.18% : 2
Total   : 100.00% : 11
```

### CSV output

```bash
count_token.sh --oformat csv example.txt
```

Result:

```csv
"Token","Percent","Occurrences"
"AAA",54.55%,6
"B",9.09%,1
"BBB",18.18%,2
"CCC",18.18%,2
"Total",100%,11
```

### JSON output

```bash
count_token.sh --oformat json example.txt
```

Result:

```json
{
  "data": [
    {
      "token": "AAA",
      "percent": 54.55,
      "occurrences": 6
    },
    {
      "token": "B",
      "percent": 9.09,
      "occurrences": 1
    },
    {
      "token": "BBB",
      "percent": 18.18,
      "occurrences": 2
    },
    {
      "token": "CCC",
      "percent": 18.18,
      "occurrences": 2
    }
  ],
  "total": 11
}
```
