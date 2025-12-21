#!/bin/bash

read -p "Action (start/stop/restart/status): " CMD

case "${CMD,,}" in
    start|s)
        echo "Starting..."
        ;;
    stop|S)
        echo "Stopping..."
        ;;
    restart|r|reload)
        echo "Restarting..."
        ;;
    status|stat)
        echo "Status..."
        ;;
    *)
        echo "Invalid: $CMD"
        exit 1
        ;;
esac

# 檔案類型
read -p "Filename: " FILE

case "$FILE" in
    *.txt)
        echo "Text file"
        ;;
    *.sh)
        echo "Shell script"
        ;;
    *.jpg|*.png)
        echo "Image"
        ;;
    *)
        echo "Unknown type"
        ;;
esac
