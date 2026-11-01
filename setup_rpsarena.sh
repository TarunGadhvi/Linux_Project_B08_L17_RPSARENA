#!/bin/bash
# ============================================================
#  STARTER KIT – L17 RPS Tournament
#  Student: TARUN JAYVIRDAN GADHVI  Roll: B08  Div: H
#  Run:  bash setup_rpsarena.sh
#  It creates ~/linux_project/rpsarena with folders, sample data and scripts.
# ============================================================
P="$HOME/linux_project/rpsarena"
if [ -d "$P" ]; then echo "Folder $P already exists. Rename or delete it first."; exit 1; fi
mkdir -p "$P"/lib "$P"/data "$P"/reports "$P"/backups "$P"/logs
cd "$P" || exit 1

# sample data: data/matches.csv
cat > 'data/matches.csv' <<'KIT_DATA_0'
date,player,rounds,wins,losses,draws
2026-10-26,SAHIL,5,3,1,1
KIT_DATA_0

cat > lib/functions.sh <<'KIT_FUNCS'
#!/bin/bash
# lib/functions.sh – all functions for RPS Tournament
DATA="data/matches.csv"

LOG="logs/activity.log"

# write one line to the activity log
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $*" >> "$LOG"
}

# check the data file / folder exists before using it
check_data() {
    if [ ! -e "$DATA" ]; then
        echo "Data not found: $DATA"
        return 1
    fi
}

show_help() {
    echo "Usage: ./main.sh            -> open the menu"
    echo "       ./main.sh --help     -> show this help"
    echo "       ./main.sh --backup   -> backup data/ now"
    echo "       ./main.sh --cron     -> run the scheduled (crontab) task"
}

view_data() {
    check_data || return
    if [ -d "$DATA" ]; then ls -l "$DATA"; else cat -n "$DATA" | more; fi
}

do_backup() {
    f="backups/data_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$f" data/
    echo "Backup saved: $f ($(du -h "$f" | cut -f1))"
    log "backup created $f"
}

view_log() {
    if [ -f "$LOG" ]; then tail -n 15 "$LOG"; else echo "No activity yet."; fi
}

# ------------------------------------------------------------
# FEATURE 1: Rounds given as a command-line argument
# Commands you can use: $1, $RANDOM, case, while, awk
# ------------------------------------------------------------
feature_1() {
    echo "== Rounds given as a command-line argument =="
    echo "TODO: write the code for this feature (see your project guide, Step 3)."
    # ---- example to start from (remove the # and change it) ----
    # read -p "Search for: " word
    # grep -i "$word" "$DATA" || echo "Nothing found"
    # # or show selected columns: awk -F',' '{ print $1, $2 }' "$DATA"
    log "feature_1 used"
}

# ------------------------------------------------------------
# FEATURE 2: Computer choice with $RANDOM
# Commands you can use: $1, $RANDOM, case, while, awk
# ------------------------------------------------------------
feature_2() {
    echo "== Computer choice with RANDOM =="
    echo "TODO: write the code for this feature (see your project guide, Step 4)."
    # ---- example to start from (remove the # and change it) ----
    # read -p "Search for: " word
    # grep -i "$word" "$DATA" || echo "Nothing found"
    # # or show selected columns: awk -F',' '{ print $1, $2 }' "$DATA"
    log "feature_2 used"
}

# ------------------------------------------------------------
# FEATURE 3: Decide winner with case
# Commands you can use: $1, $RANDOM, case, while, awk
# ------------------------------------------------------------
feature_3() {
    echo "== Decide winner with case =="
    echo "TODO: write the code for this feature (see your project guide, Step 5)."
    # ---- example to start from (remove the # and change it) ----
    # # example: count rows per value of column 2
    # tail -n +2 "$DATA" | cut -d',' -f2 | sort | uniq -c | sort -nr | head -5
    # # example: top 5 rows by column 3 (rounds)
    # tail -n +2 "$DATA" | sort -t',' -k3 -nr | head -5
    log "feature_3 used"
}

# ------------------------------------------------------------
# FEATURE 4: Save match history
# Commands you can use: $1, $RANDOM, case, while, awk
# ------------------------------------------------------------
feature_4() {
    echo "== Save match history =="
    echo "TODO: write the code for this feature (see your project guide, Step 6)."
    # ---- example to start from (remove the # and change it) ----
    # out="reports/report_$(date +%Y-%m-%d).txt"
    # {
    #     echo "===== RPS Tournament report – $(date) ====="
    #     tail -n +2 "$DATA" | sort
    # } > "$out"
    # echo "Report saved to $out"
    log "feature_4 used"
}

# ------------------------------------------------------------
# FEATURE 5: Show win % and longest win streak
# Commands you can use: $1, $RANDOM, case, while, awk
# ------------------------------------------------------------
feature_5() {
    echo "== Show win % and longest win streak =="
    echo "TODO: write the code for this feature (see your project guide, Step 7)."
    # ---- example to start from (remove the # and change it) ----
    # # example: total and average of column 3 (rounds); change $3 if you need another column
    # awk -F',' 'NR>1 { sum += $3; n++ }
    # END { if (n>0) printf "Total: %.2f  Average: %.2f\n", sum, sum/n }' "$DATA"
    # # for decimals in bash use bc, e.g.: echo "scale=2; 45/60" | bc
    log "feature_5 used"
}

# ------------------------------------------------------------
# CRON TASK: Every Sunday at 8 PM, write weekly win/loss stats to weekly_stats.txt
# Runs when crontab calls:  ./main.sh --cron
# ------------------------------------------------------------
cron_task() {
    # TODO: write the code for the scheduled task here (Step 10 of your guide)
    echo "$(date '+%Y-%m-%d %H:%M') cron task ran" >> reports/cron_output.txt
    log "cron task ran"
}
KIT_FUNCS

cat > main.sh <<'KIT_MAIN'
#!/bin/bash
# main.sh – L17 RPS Tournament
# Menu-driven shell script (while loop + case)
cd "$(dirname "$0")" || exit 1
source lib/functions.sh

case "$1" in
    --help)   show_help; exit 0 ;;
    --backup) do_backup; exit 0 ;;
    --cron)   cron_task; exit 0 ;;
esac

while true; do
    echo
    echo '========== RPS TOURNAMENT =========='
    echo '1) Rounds given as a command-line argument'
    echo '2) Computer choice with $RANDOM'
    echo '3) Decide winner with case'
    echo '4) Save match history'
    echo '5) Show win % and longest win streak'
    echo "6) View data"
    echo "7) Backup data (tar.gz)"
    echo "8) View activity log"
    echo "0) Exit"
    read -p "Choose an option: " ch
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
KIT_MAIN

cat > README.md <<'KIT_README'
# L17 – RPS Tournament

**Student:** TARUN JAYVIRDAN GADHVI | **Roll:** B08 | **Division:** H | **Enrollment:** 24004501210085

## Problem
Create a rock-paper-scissors tournament against the computer with best-of-N rounds and match history.

## Who will use it
Friends settling arguments with rock-paper-scissors.

## Folder structure
- main.sh – menu (run with ./main.sh)
- lib/functions.sh – all functions
- data/ – data files
- reports/ – reports created by the script
- backups/ – tar.gz backups
- logs/ – activity.log and cron.log

## Features
1. Rounds given as a command-line argument
2. Computer choice with $RANDOM
3. Decide winner with case
4. Save match history
5. Show win % and longest win streak

## How to run
    cd ~/linux_project/rpsarena
    ./main.sh
    ./main.sh --help

## Crontab task
Every Sunday at 8 PM, write weekly win/loss stats to weekly_stats.txt

    0 20 * * 0 /bin/bash $HOME/linux_project/rpsarena/main.sh --cron >> $HOME/linux_project/rpsarena/logs/cron.log 2>&1

## Commands used
$1, $RANDOM, case, while, awk

## What I learned
(write 3-5 lines here)
KIT_README

chmod +x main.sh lib/functions.sh
touch logs/activity.log
echo
echo "Starter kit ready!  Folder: $P"
ls -R "$P"
echo
echo "Next:  cd ~/linux_project/rpsarena  &&  ./main.sh"
