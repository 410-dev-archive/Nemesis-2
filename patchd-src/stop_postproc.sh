#!/bin/bash
killall LanSchool
killall student

if [[ -d "/Library/Application Support/LanSchool_Renamed" ]]; then
	echo "success" > "$2"
elif [[ -d "/Library/Application Support/LanSchool" ]]; then
	echo "ERROR-01: LanSchool not renamed." > "$2"
else
	echo "ERROR-02: Failed verifying renamed directory." > "$2"
fi