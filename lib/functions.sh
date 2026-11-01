#!/bin/bash
# lib/functions.sh - L17 RPS Tournament

DATA="data/matches.csv"
LOG="logs/activity.log"
ROUND_DATA="data/rounds.csv"

# Ensure required directories and files exist
initialize_files() {
    mkdir -p data reports backups logs

    if [ ! -f "$DATA" ]; then
        echo "date,player,rounds,wins,losses,draws" > "$DATA"
    fi

    if [ ! -f "$ROUND_DATA" ]; then
        echo "date,player,match_id,round,player_choice,computer_choice,result" > "$ROUND_DATA"
    fi

    if [ ! -f "$LOG" ]; then
        touch "$LOG"
    fi
}

initialize_files

# Write a message to the activity log
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $*" >> "$LOG"
}

# Check whether the match history exists
check_data() {
    if [ ! -f "$DATA" ]; then
        echo "Data not found: $DATA"
        return 1
    fi
}

# Display help information
show_help() {
    echo "Usage: ./main.sh            -> open the menu"
    echo "       ./main.sh 5          -> play 5 rounds"
    echo "       ./main.sh --help     -> show this help"
    echo "       ./main.sh --backup   -> backup data"
    echo "       ./main.sh --cron     -> generate weekly statistics"
}

# View saved match history
view_data() {
    check_data || return
    echo "========== MATCH HISTORY =========="
    cat -n "$DATA"
}

# Create a compressed backup
do_backup() {
    mkdir -p backups

    local f="backups/data_$(date +%Y%m%d_%H%M%S).tar.gz"

    if tar -czf "$f" data/; then
        echo "Backup saved: $f ($(du -h "$f" | cut -f1))"
        log "backup created $f"
    else
        echo "Backup failed."
        return 1
    fi
}

# Display the latest activity log entries
view_log() {
    if [ -f "$LOG" ]; then
        tail -n 15 "$LOG"
    else
        echo "No activity yet."
    fi
}

# Generate a random computer choice using $RANDOM
get_computer_choice() {
    case $((RANDOM % 3)) in
        0) COMPUTER_CHOICE="rock" ;;
        1) COMPUTER_CHOICE="paper" ;;
        2) COMPUTER_CHOICE="scissors" ;;
    esac
}

# Ask for and validate the player's choice
read_player_choice() {
    while true; do
        read -r -p "Choose rock, paper, or scissors: " PLAYER_CHOICE

        PLAYER_CHOICE=$(echo "$PLAYER_CHOICE" | tr '[:upper:]' '[:lower:]')

        case "$PLAYER_CHOICE" in
            rock|paper|scissors)
                return 0
                ;;
            *)
                echo "Invalid choice. Enter rock, paper, or scissors."
                ;;
        esac
    done
}

# Decide the winner using case statements
decide_round() {
    if [ "$PLAYER_CHOICE" = "$COMPUTER_CHOICE" ]; then
        ROUND_RESULT="DRAW"
    else
        case "$PLAYER_CHOICE" in
            rock)
                case "$COMPUTER_CHOICE" in
                    scissors) ROUND_RESULT="WIN" ;;
                    paper)    ROUND_RESULT="LOSS" ;;
                esac
                ;;
            paper)
                case "$COMPUTER_CHOICE" in
                    rock)     ROUND_RESULT="WIN" ;;
                    scissors) ROUND_RESULT="LOSS" ;;
                esac
                ;;
            scissors)
                case "$COMPUTER_CHOICE" in
                    paper) ROUND_RESULT="WIN" ;;
                    rock)  ROUND_RESULT="LOSS" ;;
                esac
                ;;
        esac
    fi
}

# Validate and collect the player's name
get_player_name() {
    while true; do
        read -r -p "Enter your name: " PLAYER_NAME

        # Remove leading and trailing spaces
        PLAYER_NAME=$(echo "$PLAYER_NAME" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        local name_pattern='^[a-zA-Z][a-zA-Z0-9_ -]{0,29}$'
        if [[ "$PLAYER_NAME" =~ $name_pattern ]]; then
            return 0
        else
            echo "Invalid name. Use 1-30 characters, starting with a letter."
            echo "Letters, numbers, spaces, underscores and hyphens are allowed."
        fi
    done
}

# ------------------------------------------------------------
# FEATURE 1: Play a tournament
# ------------------------------------------------------------
feature_1() {
    echo "========== RPS TOURNAMENT GAME =========="

    get_player_name

    local rounds

    if [[ "${1:-}" =~ ^[0-9]+$ ]] && [ "$1" -ge 1 ] && [ "$1" -le 99 ]; then
        rounds="$1"
        echo "Rounds selected: $rounds"
    else
        read -r -p "How many rounds do you want to play (1-99)? " rounds
    fi

    if ! [[ "$rounds" =~ ^[0-9]+$ ]] ||
       [ "$rounds" -lt 1 ] ||
       [ "$rounds" -gt 99 ]; then
        echo "Invalid number. Please enter a number from 1 to 99."
        log "invalid number of rounds entered"
        return 1
    fi

    LAST_PLAYER_NAME="$PLAYER_NAME"
    LAST_ROUNDS="$rounds"
    LAST_WINS=0
    LAST_LOSSES=0
    LAST_DRAWS=0
    LAST_MATCH_ID="$(date +%Y%m%d%H%M%S)-$$"
    LAST_MATCH_SAVED=0

    LAST_ROUND_RESULTS=()
    LAST_PLAYER_CHOICES=()
    LAST_COMPUTER_CHOICES=()

    for ((i=1; i<=rounds; i++)); do
        echo
        echo "----- Round $i of $rounds -----"

        read_player_choice
        LAST_PLAYER_CHOICES+=("$PLAYER_CHOICE")

        get_computer_choice
        LAST_COMPUTER_CHOICES+=("$COMPUTER_CHOICE")

        decide_round
        LAST_ROUND_RESULTS+=("$ROUND_RESULT")

        echo "You chose: $PLAYER_CHOICE"
        echo "Computer chose: $COMPUTER_CHOICE"

        case "$ROUND_RESULT" in
            WIN)
                echo "You won this round!"
                ((LAST_WINS++))
                ;;
            LOSS)
                echo "The computer won this round."
                ((LAST_LOSSES++))
                ;;
            DRAW)
                echo "This round is a draw."
                ((LAST_DRAWS++))
                ;;
        esac
    done

    echo
    echo "========== MATCH SUMMARY =========="
    echo "Player: $LAST_PLAYER_NAME"
    echo "Rounds: $LAST_ROUNDS"
    echo "Wins: $LAST_WINS"
    echo "Losses: $LAST_LOSSES"
    echo "Draws: $LAST_DRAWS"

    if [ "$LAST_WINS" -gt "$LAST_LOSSES" ]; then
        echo "Overall result: $LAST_PLAYER_NAME wins!"
    elif [ "$LAST_WINS" -lt "$LAST_LOSSES" ]; then
        echo "Overall result: Computer wins!"
    else
        echo "Overall result: Match tied!"
    fi

    echo
    echo "Select option 4 to save this match to the history."

    log "match played by $LAST_PLAYER_NAME: rounds=$LAST_ROUNDS wins=$LAST_WINS losses=$LAST_LOSSES draws=$LAST_DRAWS"
}

# ------------------------------------------------------------
# FEATURE 2: Generate a computer choice
# ------------------------------------------------------------
feature_2() {
    get_computer_choice
    echo "Computer chose: $COMPUTER_CHOICE"
    log "computer choice generated"
}

# ------------------------------------------------------------
# FEATURE 3: Play one round and decide the winner
# ------------------------------------------------------------
feature_3() {
    echo "========== SINGLE ROUND =========="

    get_player_name
    read_player_choice
    get_computer_choice
    decide_round

    echo "Player: $PLAYER_NAME"
    echo "Your choice: $PLAYER_CHOICE"
    echo "Computer choice: $COMPUTER_CHOICE"

    case "$ROUND_RESULT" in
        WIN)  echo "$PLAYER_NAME wins!" ;;
        LOSS) echo "Computer wins!" ;;
        DRAW) echo "It's a draw!" ;;
    esac

    log "single round played by $PLAYER_NAME; result=$ROUND_RESULT"
}

# ------------------------------------------------------------
# FEATURE 4: Save match history
# ------------------------------------------------------------
feature_4() {
    if ! [[ "${LAST_ROUNDS:-}" =~ ^[0-9]+$ ]] ||
       [ "${LAST_ROUNDS:-0}" -lt 1 ]; then
        echo "No tournament is available to save."
        echo "Choose option 1 and complete a tournament first."
        return 1
    fi

    if [ "${LAST_MATCH_SAVED:-0}" -eq 1 ]; then
        echo "This match has already been saved."
        return 0
    fi

    initialize_files

    local match_date
    match_date=$(date +%F)

    # Save the tournament summary
    printf '%s,%s,%s,%s,%s,%s\n' \
        "$match_date" "$LAST_PLAYER_NAME" "$LAST_ROUNDS" \
        "$LAST_WINS" "$LAST_LOSSES" "$LAST_DRAWS" >> "$DATA"

    # Save each individual round
    for ((i=0; i<${#LAST_ROUND_RESULTS[@]}; i++)); do
        printf '%s,%s,%s,%s,%s,%s,%s\n' \
            "$match_date" "$LAST_PLAYER_NAME" "$LAST_MATCH_ID" \
            "$((i+1))" "${LAST_PLAYER_CHOICES[$i]}" \
            "${LAST_COMPUTER_CHOICES[$i]}" \
            "${LAST_ROUND_RESULTS[$i]}" >> "$ROUND_DATA"
    done

    LAST_MATCH_SAVED=1

    echo "Match saved successfully!"
    echo "Player: $LAST_PLAYER_NAME"
    echo "Summary file: $DATA"
    echo "Round details: $ROUND_DATA"

    log "match $LAST_MATCH_ID saved for $LAST_PLAYER_NAME"
}

# ------------------------------------------------------------
# FEATURE 5: Show win percentage and longest win streak
# ------------------------------------------------------------
feature_5() {
    check_data || return

    echo "========== TOURNAMENT STATISTICS =========="

    awk -F',' '
        NR > 1 {
            matches++
            rounds += $3
            wins += $4
            losses += $5
            draws += $6
        }
        END {
            print "Matches played:", matches+0
            print "Total rounds:", rounds+0
            print "Total wins:", wins+0
            print "Total losses:", losses+0
            print "Total draws:", draws+0

            if (rounds > 0)
                printf "Win percentage: %.2f%%\n", wins*100/rounds
            else
                print "Win percentage: 0.00%"
        }
    ' "$DATA"

    if [ -f "$ROUND_DATA" ]; then
        awk -F',' '
            NR > 1 {
                if ($7 == "WIN") {
                    current++
                    if (current > longest)
                        longest = current
                } else {
                    current = 0
                }
            }
            END {
                print "Longest consecutive win streak:", longest+0
            }
        ' "$ROUND_DATA"
    else
        echo "Longest consecutive win streak: 0"
    fi

    log "statistics viewed"
}

# ------------------------------------------------------------
# CRON TASK: Generate statistics for the last seven days
# ------------------------------------------------------------
cron_task() {
    initialize_files

    local output="reports/weekly_stats.txt"
    local cutoff
    cutoff=$(date -d '7 days ago' +%F)

    {
        echo "RPS TOURNAMENT - WEEKLY STATISTICS"
        echo "Generated: $(date)"
        echo "Period starting: $cutoff"
        echo

        awk -F',' -v cutoff="$cutoff" '
            NR > 1 && $1 >= cutoff {
                matches++
                rounds += $3
                wins += $4
                losses += $5
                draws += $6
            }
            END {
                print "Matches played:", matches+0
                print "Total rounds:", rounds+0
                print "Wins:", wins+0
                print "Losses:", losses+0
                print "Draws:", draws+0

                if (rounds > 0)
                    printf "Win percentage: %.2f%%\n", wins*100/rounds
                else
                    print "Win percentage: 0.00%"
            }
        ' "$DATA"
    } > "$output"

    echo "Weekly report saved to $output"
    log "weekly statistics report generated"
}
