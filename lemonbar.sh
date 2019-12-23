#!/bin/bash

Battery(){
    BATPERC=$(acpi --battery | cut -d ',' -f 2 | sed 's/%//')
    if [ "$BATPERC" -gt "75" ]
    then
        echo "BAT:%{F#00FF00}${BATPERC}%"
    else
        if [ "$BATPERC" -lt "75" ] || [ "$BATPERC" -eq "75" ]
        then
            echo "BAT:%{F#FFFF00}${BATPERC}%"
        else
            if [ "$BATPERC" -lt "50" ] || [ "$BATPERC" -eq "50" ]
            then
                echo "BAT:%{F#FFA500}${BATPERC}%"
            else
                if [ "$BATPERC" -lt "25" ] || [ "$BATPERC" -eq "25" ]
                then
                    echo "BAT:%{F#FF0000}${BATPERC}%"
                fi
            fi
        fi
    fi
}

Time(){
    DATETIME=$(date "+%a %d %m | %T")
    echo -n "$DATETIME"
}

Wireless(){
    ESSID=$(iwconfig | grep 'ESSID' | sed 's/.*://' | tr -s ' ')
    if [ "$ESSID" == "off/any" ]
    then
        echo down
    else
        echo "$ESSID"
    fi
}

CPU(){
    CPUSTAT=$(cat /home/gandalf/cpustat)
    echo "$CPUSTAT"
}

Memory(){
    MEM_UNFORMAT=$(free -h | grep Mem | tr -s ' ' | awk '{ print $3 " " $2}')
	MEMORY=$(echo ${MEM_UNFORMAT/ //})
    MEMORY=$(echo ${MEMORY//Gi/GB})
    MEMORY=$(echo ${MEMORY//Mi/MB})
	echo "$MEMORY"
}

Workspace(){
    WORK_JQ=$(i3-msg -t get_workspaces)
    WORK_COUNT=$(echo ${WORK_JQ} | jq length)
    WORK_COUNT=$((WORK_COUNT - 1))
    CURR_WORK=$(echo ${WORK_JQ} | jq '.[] | select(.focused==true) | .num')
    for i in $(eval echo {0..$WORK_COUNT})
    do
        NUM=$(echo ${WORK_JQ} | jq '.['$i'].num')

        if [ "$CURR_WORK" == "$NUM" ]
        then
            WORK="${WORK}%{B#000000}=%{B#00FF00}| ${NUM} |"
        else
            WORK="${WORK}%{B#000000}=%{B#FF0000}| ${NUM} |"
        fi

    done
    echo "${WORK}%{B#000000}="
}

while true; do
    echo "%{F#FFFFFF}%{B#000000}%{l}$(Time) | W: $(Wireless)| CPU: $(CPU) | MEM: $(Memory) %{F#FFFFFF}%{B#000000}%{c}(Workspace) %{B#000000}%{r}$(Battery) %{B#000000}"
    read -t 0.1
done
