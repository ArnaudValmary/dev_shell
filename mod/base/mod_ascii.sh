#! /usr/bin/env bash
# shellcheck disable=SC2034

#
# https://en.wikipedia.org/wiki/ASCII
#

# 0x00 Null
declare -r ascii_char_null_base64="AA=="
# 0x01 Start of heading
declare -r ascii_char_soh=$'\x01'
# 0x02 Start of text
declare -r ascii_char_stx=$'\x02'
# 0x03 End of text
declare -r ascii_char_etx=$'\x03'
# 0x04 End of transmission
declare -r ascii_char_eot=$'\x04'
# 0x05 Enquiry
declare -r ascii_char_enq=$'\x05'
# 0x06 Acknowledgement
declare -r ascii_char_ack=$'\x06'
# 0x07 Bell
declare -r ascii_char_bel=$'\a'
# 0x08 Backspace
declare -r ascii_char_bs=$'\b'
# 0x09 Horizontal tab
declare -r ascii_char_ht=$'\t'
# 0x0A Line feed
declare -r ascii_char_lf=$'\n'
# 0x0B Vertical tab
declare -r ascii_char_vt=$'\v'
# 0x0C Form feed
declare -r ascii_char_ff=$'\f'
# 0x0D Carriage return
declare -r ascii_char_cr=$'\r'
# 0x0E Shift out
declare -r ascii_char_so=$'\x0e'
# 0x0F Shift in
declare -r ascii_char_si=$'\x0f'
# 0x10 Data link escape
declare -r ascii_char_dle=$'\x10'
# 0x11 Device control 1
declare -r ascii_char_dc1=$'\x11'
# 0x12 Device control 2
declare -r ascii_char_dc2=$'\x12'
# 0x13 Device control 3
declare -r ascii_char_dc3=$'\x13'
# 0x14 Device control 4
declare -r ascii_char_dc4=$'\x14'
# 0x15 Negative acknowledgement
declare -r ascii_char_nak=$'\x15'
# 0x16 Synchronous idle
declare -r ascii_char_syn=$'\x16'
# 0x17 End of transmission block
declare -r ascii_char_etb=$'\x17'
# 0x18 Cancel
declare -r ascii_char_can=$'\x18'
# 0x19 End of medium
declare -r ascii_char_em=$'\x19'
# 0x1A Substitute
declare -r ascii_char_sub=$'\x1a'
# 0x1B Escape
declare -r ascii_char_esc=$'\e'
# 0x1C File separator
declare -r ascii_char_fs=$'\x1c'
# 0x1D Group separator
declare -r ascii_char_gs=$'\x1d'
# 0x1E Record separator
declare -r ascii_char_rs=$'\x1e'
# 0x1F Unit separator
declare -r ascii_char_us=$'\x1f'

# 0x7F DELETE
declare -r ascii_char_del=$'\x7f'
