# L17 – RPS Tournament
## Project Guide
This project was completed under the guidance of
**Dr. Anjum Y. Mansuri**, Assistant Professor, Computer Applications,
LJ Institute of Computer Applications, LJ University, Ahmedabad.
GitHub: [@anjum-mansuri](https://github.com/anjum-mansuri)

OS Linux Lab 260120510 | Project ID: L17

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
Through this project, I learned how to create a Rock-Paper-Scissors tournament using Bash scripting in Linux. I understood how to use command-line arguments, $RANDOM, case statements, and loops to manage game rounds and determine winners. I also learned how to store match history in files and use awk to calculate statistics such as win percentage and winning streaks. Additionally, I gained practical knowledge of automating weekly reports using crontab jobs and maintaining logs and backups.
=======

