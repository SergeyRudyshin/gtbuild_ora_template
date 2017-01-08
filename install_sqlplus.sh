#!/usr/bin/env bash

# 
# Copyright 2017 Sergey Rudyshin. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# the script installs the command-file via sqlplus 
#
# a name of the command-file is passed via the first parameter
# the script expects the file "parameters.sqlplus.tmpl" to be pipilined to its stdin
# this tmpl-file is supposed to have some enviroment variables (such as passwords, etc)
# before the execution the variables are substituted and the result is placed at the begining of the command-file
# then sqlplus is invoked and the output is saved in a log file and checked on having any errors
# if neither sqlplus returns an error nor the log contains errors the script returns 0
# otherwise it prints the list of errors and the log and returns 1

CMD_FILE=$1

ERROR_REGX="^(ERROR:|ORA-|SP2-)"

mv $CMD_FILE $CMD_FILE.temp
(eval "echo \"$(</dev/stdin)\"";  cat $CMD_FILE.temp; ) > $CMD_FILE
rm $CMD_FILE.temp

RES=0
echo "" | sqlplus /nolog "@$CMD_FILE" &> "$CMD_FILE.log"; SQLPLUS_RES=$?

[[ $SQLPLUS_RES -eq 0 ]] || (echo "*** sqlplus returned error ($SQLPLUS_RES) ***"; RES=1)

SQLPLUS_ERRORS=$(egrep -i --line-number "$ERROR_REGX" "$CMD_FILE.log"); LOG_RES=$?

[[ $LOG_RES -eq 1 ]] || (echo -e "*** Errors during installation: ***\n$SQLPLUS_ERRORS\n"; cat "$CMD_FILE.log"; RES=1)

exit $RES
