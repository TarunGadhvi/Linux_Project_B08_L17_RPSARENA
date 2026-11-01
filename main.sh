#!/bin/bash
# main.sh - L17 RPS Tournament
# Menu-driven shell script (while loop + case)

cd "$(dirname "$0")" || exit 1
source lib/functions.sh

# Support command-line options.
case "${1:-}" in
    --help)
        show_help
        exit 0
        ;;
    --backup)
        do_backup
        exit $?
        ;;
    --cron)
        cron_task
        exit $?
        ;;
    '')
        # No argument: open the interactive menu below.
        ;;
    *[!0-9]*|0)
        echo "Invalid argument: $1"
        echo "Use ./main.sh [1-99], --help, --backup, or --cron."
        exit 1
        ;;
    *)
        if [ "$1" -ge 1 ] && [ "$1" -le 99 ]; then
            feature_1 "$1"
            exit $?
        else
            echo "Number of rounds must be between 1 and 99."
            exit 1
        fi
        ;;
esac

while true; do
    echo
    echo '========== RPS TOURNAMENT =========='
    echo '1) Play a tournament'
    echo '2) Generate a computer choice'
    echo '3) Play one round and decide the winner'
    echo '4) Save match history'
    echo '5) Show win percentage and longest win streak'
    echo '6) View saved match data'
    echo '7) Backup data (tar.gz)'
    echo '8) View activity log'
    echo '0) Exit'

    if ! read -r -p "Choose an option: " ch; then
        echo
        echo "Input closed. Exiting."
        break
    fi

    case "$ch" in
        1) feature_1 ;;
        2) feature_2 ;;
        3) feature_3 ;;
        4) feature_4 ;;
        5) feature_5 ;;
        6) view_data ;;
        7) do_backup ;;
        8) view_log ;;
        0) echo "Bye!"; break ;;
        *) echo "Invalid choice, try again." ;;
    esac
done
