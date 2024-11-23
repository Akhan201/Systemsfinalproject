#!/bin/bash


task=()

function run_command_with_retries(){
    local command="$1"
    local retries=3
    local delay=5

    for ((i=1; i<=retries; i++)); do
        echo "Attempt $i of $retries: Executing command..."
        eval "$command"
        if [ $? -eq 0 ]; then
            echo "Command executed successfully."
            return 0
        else
            echo "Command failed."
            if [ $i -lt $retries ]; then
                echo "Retrying in $delay seconds..."
                sleep $delay
            fi
        fi
    done
    echo "All retries failed."
    return 1
}

while true; do
    echo "Please enter the task you wish to schedule:"
    read user_command

    echo "Would you like it to be a one-time task or a recurring task?"
    echo "1) One-time task"
    echo "2) Recurring task"
    read choice

    case $choice in
        1)
            echo "Enter the time you would like the task to be executed:"
            echo "Format examples:"
            echo "'MM/DD/YYYY HH:MM AM/PM' (e.g., '12/31/2024 6:00 PM')"
            echo "'now + 1 minute', 'tomorrow 5pm', 'next Monday'"
            echo "Please enter the date and time:"
            read schedule_time
            command="echo '$user_command' | at $schedule_time"
            if run_command_with_retries "$command"; then
                task+=("One-time task: '$user_command' scheduled for $schedule_time")
            fi
            ;;
        2)
            echo "Enter the time you would like the task to be executed (cron format, e.g., '0 5 * * *' for 5 AM daily):"
            read recurring_tasks
            command="(crontab -l; echo '$recurring_tasks $user_command') | crontab -"
            if run_command_with_retries "$command"; then
                task+=("Recurring task: '$user_command' scheduled with cron format '$recurring_tasks'")
            fi
            ;;
        *)
            echo "Invalid choice, please enter 1 or 2."
            continue
            ;;
    esac

    echo "Would you like to enter more tasks?"
    echo "1) Yes"
    echo "2) No"
    read continue_choice

    if [[ $continue_choice -eq 2 ]]; then
        echo "Exiting the program."
        break
    elif [[ $continue_choice -ne 1 ]]; then
        echo "Invalid choice, please enter 1 for yes or 2 for no."
    fi
done

echo "Scheduled tasks:"
for task_item in "${task[@]}"; do
    echo "$task_item"
done
