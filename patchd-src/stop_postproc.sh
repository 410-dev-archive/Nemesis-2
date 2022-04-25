#!/bin/bash
killall "Relay Classroom"
sleep 1
echo "success" > "$2"
if [[ -z "$(ps -ax | grep "/Applications/Relay Classroom.ap[p]")" ]]; then
	echo "success" > "$2"
else
	echo "ERROR-01: Failed Terminating Relay Classroom.app - Detected by: $(ps -ax | grep "Relay Classroo[m]")" > "$2"
fi
export output=$(osascript -e 'display dialog "Do you want to clear Lightspeed Relay Classroom statistics? (Experimental Feature)" buttons {"No","Yes"} default button 2 with title "Nemesis 2"')
if [[ "$output" == "button returned:Yes" ]]; then
	export WebKitDat="$(find /private/var/folders -name "com.lightspeed.Classroom" 2>/dev/null)"
	echo "$WebKitDat" | while read dirAddr
	do
		sudo rm -rf "$dirAddr"
	done
	sudo rm -rf "$3/Library/WebKit/com.lightspeed.Classroom"
	sudo rm -rf "$3/Library/Caches/com.lightspeed.Classroom"
fi
exit 0