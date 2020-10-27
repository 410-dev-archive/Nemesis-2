#!/bin/bash
killall "Relay Classroom"
sleep 1
echo "success" > "$2"
if [[ -z "$(ps -ax | grep "Relay Classroo[m] ")" ]]; then
	echo "success" > "$2"
else
	echo "ERROR-01: Failed Terminating Relay Classroom.app - Detected by: $(ps -ax | grep "Relay Classroo[m]")" > "$2"
fi
exit 0