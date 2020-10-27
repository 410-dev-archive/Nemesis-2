#!/bin/bash

sleep 1
if [[ ! -z "$(ps -ax | grep "Relay Classroo[m]")" ]]; then
	echo "success" > "$2"
else
	open "/Applications/Relay Classroom.app"
	if [[ ! -z "$(ps -ax | grep "Relay Classroo[m]")" ]]; then
		echo "ERROR-01: Failed relaunching Relay Classroom.app" > "$2"
		echo "success" > "$2"
	else
		echo "Relay Classroom launching failed." > "$2"
	fi
fi
exit 0