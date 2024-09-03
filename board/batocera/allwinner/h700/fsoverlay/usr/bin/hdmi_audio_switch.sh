#!/bin/sh

# Path to the HDMI state file
hdmi_state_file="/sys/devices/platform/soc/6000000.hdmi/extcon/hdmi/state"

check_ingame() {
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:1234/runningGame")
    if [ $? -ne 0 ]; then
        return 0
    fi
    if [ "$HTTP_STATUS" -eq 201 ]; then
        return 1
    else
        return 0
    fi
}

if check_ingame; then
    exit 1
fi

kill_es() {
	killall emulationstation 2>/dev/null
	killall touchegg 2>/dev/null
	if [ $? -eq 0 ]; then
		sleep 20 &
		watchdog=$!
		while ! [ -z $(pidof emulationstation) ]; do
			sleep 0.25
			$(kill -0 $watchdog) || exit
		done
		kill -9 $watchdog
	fi
}

state=$(cat "$hdmi_state_file")

echo "$(date) - HDMI event triggered - ${state}" >> /var/log/hdmi-event.log

if [ "$state" = "HDMI=1" ]; then
    sleep 1
    batocera-audio set auto
    batocera-resolution setOutput
    echo "HDMI CONNECTED!" >> /var/log/hdmi-event.log
    kill_es

else
    if check_ingame; then
	    exit 1
	fi
	
	sleep 1
	batocera-audio set auto
    batocera-resolution setOutput
    echo "HDMI DISCONNECTED!" >> /var/log/hdmi-event.log
    kill_es
fi

exit 0
