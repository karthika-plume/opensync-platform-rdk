#!/bin/sh

TOOL="./wifi_hal_tool"

LOG_PREFIX="WIFIHALTOOL" # It may happen the HAL implementation itself prints to stdout,
                         # so filter only tool-relevant logs.

# Get the whole wifi_hal_tool output for a given command.
# This function invokes (runs) the wifi_hal_tool.
#
# Syntax: get_output <HAL function name> <params...>
#
# For example, to get output of "wifi_getApAssociatedDeviceDiagnosticResult3"
# for AP index "0", call:
#
# get_output wifi_getApAssociatedDeviceDiagnosticResult3 0
get_output()
{
    $TOOL "${@}" 2>/dev/null | grep "$LOG_PREFIX" # At this point we discard all the errors as
                                                  # we want a clean output. For bug investigation
                                                  # please use wifi_hal_tool directly (not via scripts)
                                                  # to see HAL's stderr.
}

# Get the value from input containing "key=value" pattern.
#
# Syntax: get_key_raw <INPUT VARIABLE> <key>
#
# For example, for $INPUT="output: "WIFHALTOOL: foo=2 output=4 bar=3""
# and <key>="output", call:
#
# get_key_raw $INPUT output
#
# and it will return "4"
get_key_raw()
{
    echo $1 | awk -F"$2"= '{print $2}' | awk '{print $1}'
}

# Get the value from wifi_hal_tool output, which contains "key=value" pattern.
#
# Syntax: get_key <key> <HAL function name> <params...>
#
# For example, to get value from key "enabled" from wifi_getSSIDEnable
# HAL for AP index "0", call:
#
# get_key enabled wifi_getSSIDEnable 0
get_key()
{
    get_key_raw "$(get_output "${@:2}")" $1
}

# Get the value from input containing "key=>>a string<<" pattern.
#
# Syntax: get_key_string_raw <INPUT VARIABLE> <key>
#
# For example, for $INPUT="output: "WIFHALTOOL: foo=2 output=>>2.4 GHz<< bar=3""
# and <key>="output", call:
#
# get_key_string_raw $INPUT output
#
# and it will return "2.4. GHz"
get_key_string_raw()
{
    echo $1 | awk -F"$2"=">>" '{print $2}' | awk -F"<<" '{print $1}'
}

# Get the value from wifi_hal_tool output, which contains "key=>>a string<<" pattern.
#
# Syntax: get_key_string <key> <HAL function name> <params...>
#
# For example, to get value from key "ssid" from wifi_getSSIDName
# HAL for AP index "0", call:
#
# get_key_string ssid wifi_getSSIDName $INDEX
get_key_string()
{
    get_key_string_raw "$(get_output "${@:2}")" $1
}
