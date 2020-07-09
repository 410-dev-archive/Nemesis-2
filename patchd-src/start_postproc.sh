#!/bin/bash
open "/Library/Application Support/LanSchool/student.app"
open "/Library/Application Support/LanSchool/LanSchool.app"
sleep 1
if [[ ! -z "$(ps -ax | grep studen[t] )" ]] && [[ ! -z "$(ps -ax | grep LanSchoo[l] )" ]]; then
	echo "success" > "$2"
else
	echo "ERROR-01: Failed relaunching student.app or LanSchool.app" > "$2"
fi