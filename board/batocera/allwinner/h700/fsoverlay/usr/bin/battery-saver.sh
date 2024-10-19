#!/bin/bash

LOCK="/var/run/battery-saver.lock"
if [ -f "$LOCK" ]; then
    exit 1
fi

trap 'restore_brightness; rm -f "$LOCK"; exit 0' SIGTERM EXIT
touch "$LOCK"

STATE="active"
BRIGHTNESS="$(batocera-brightness)"
LOOP_COUNT=0 # This should always be 0
JS_DEVICES=()

MODE="$(/usr/bin/batocera-settings-get system.batterysavermode)"
if [[ -z "$MODE" || ! "$MODE" =~ ^(dim|suspend|shutdown)$ ]]; then
    MODE="dim" # default can be dim|suspend|shutdown
    /usr/bin/batocera-settings-set system.batterysavermode "$MODE"
fi

TIMER="$(/usr/bin/batocera-settings-get system.batterysavertimer)"
if [[ -z "$TIMER" || ! "$TIMER" =~ ^[0-9]+$ || "$TIMER" -lt 60 ]]; then
    TIMER="120" # default in seconds
    /usr/bin/batocera-settings-set system.batterysavertimer "$TIMER"
fi

# Called with SIGTERM so brightness is restored before saving when shutting down
restore_brightness() {
    batocera-brightness $BRIGHTNESS
}

js_update() {
    JS_DEVICES=()
    for js_device in /dev/input/js*; do
        if [ -e "$js_device" ]; then
            JS_DEVICES+=("$js_device")
        fi
    done
}

do_inactivity() {
    case "$MODE" in
        dim)
            BRIGHTNESS="$(batocera-brightness)"
            batocera-brightness 5
            batocera-audio setSystemVolume mute
            STATE="inactive"
        ;;
        suspend)
            pm-is-supported --suspend && pm-suspend
            LOOP_COUNT=0
            STATE="active"
        ;;
        shutdown)
            echo disable > /sys/kernel/debug/dispdbg/command
            echo lcd0 > /sys/kernel/debug/dispdbg/name
            echo 1 > /sys/kernel/debug/dispdbg/start
            amixer set Master mute
            batocera-es-swissknife --emukill
            /usr/bin/poweroff.sh
        ;;
    esac
}

do_activity() {
    if [ "$MODE" = "dim" ]; then
        STATE="active"
        batocera-brightness $BRIGHTNESS
        batocera-audio setSystemVolume unmute
    fi
}

monitor_controllers() {
    local JS_REFRESH_INTERVAL=10 # Number of loops before controller refresh (by default 1 loop per second)

    while true; do
        if (( LOOP_COUNT % JS_REFRESH_INTERVAL == 0 )); then
            js_update
        fi
		
		# Wait a bit if no controllers are detected
        if [ ${#JS_DEVICES[@]} -eq 0 ]; then
            sleep 1
            continue
        fi

        for i in "${!JS_DEVICES[@]}"; do
            js="${JS_DEVICES[$i]}"

            if [ -e "$js" ]; then
                if timeout 1 jstest --event "$js" | tail -n +25 | grep -q "Event"; then
                    LOOP_COUNT=0
					# Check if detected input device is first and reorder if not
                    if [ "$i" -ne 0 ]; then
                        JS_DEVICES=("$js" "${JS_DEVICES[@]:0:$i}" "${JS_DEVICES[@]:$((i + 1))}")
                    fi
                    if [ "$STATE" = "inactive" ]; then
                        do_activity
                    fi

                    break # If input is detected don't need to continue looping through other devices
                fi
            fi
        done

        ((LOOP_COUNT++))
        if (( LOOP_COUNT >= TIMER )); then
            if [ "$STATE" = "active" ]; then
                do_inactivity
            fi
        fi
    done
}

js_update
monitor_controllers

exit 0
