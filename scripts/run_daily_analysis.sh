#!/bin/bash

# Script to run the daily Telegram chat analysis workflow

echo "Starting daily Telegram chat analysis workflow..."

# Define project directory (adjust if this script is moved)
PROJECT_DIR=$(pwd)
DATA_DIR="$PROJECT_DIR/data"
ENV_NAME="telegram_bot"

# Activate Conda environment
echo "Activating Conda environment: $ENV_NAME..."

# Source conda.sh to initialize conda in this shell
# Try common locations for conda.sh
if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/miniconda3/etc/profile.d/conda.sh"
elif [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/anaconda3/etc/profile.d/conda.sh"
elif [ -f "/opt/conda/etc/profile.d/conda.sh" ]; then
    . "/opt/conda/etc/profile.d/conda.sh"
else
    echo "Error: conda.sh not found. Please ensure Conda is installed correctly."
    echo "You may need to run 'conda init bash' in your terminal first."
    exit 1
fi

# Now that conda is initialized, activate the environment
conda activate "$ENV_NAME"
if [ $? -ne 0 ]; then
    echo "Error activating Conda environment '$ENV_NAME'. Please ensure it exists and Conda is configured correctly."
    exit 1
fi
echo "Conda environment activated."

# Step 1: Export Telegram chats
echo "Running Telegram export script (src/telegram_export.py)..."
python3 "$PROJECT_DIR/src/telegram_export.py"
if [ $? -ne 0 ]; then
    echo "Error running telegram_export.py. Exiting."
    exit 1
fi
echo "Telegram export finished."

# Step 2: Find the latest chat export file
# Assumes chat files are named like *.txt in the data directory
LATEST_CHAT_FILE=$(ls -t "$DATA_DIR"/*.txt 2>/dev/null | head -n 1)

if [ -z "$LATEST_CHAT_FILE" ]; then
    echo "Error: No chat export .txt files found in $DATA_DIR. Exiting."
    exit 1
fi
echo "Latest chat file found: $LATEST_CHAT_FILE"

# Step 3: Process the chat transcript
echo "Running chat processing script (src/process_chats.py) on $LATEST_CHAT_FILE..."
python3 "$PROJECT_DIR/src/process_chats.py" "$LATEST_CHAT_FILE"
if [ $? -ne 0 ]; then
    echo "Error running process_chats.py. Exiting."
    exit 1
fi
echo "Chat processing finished."

# Step 4: Export database tables to CSV for reporting
echo "Exporting database tables to CSV..."
DB_FILE="$PROJECT_DIR/personal_assistant.db"
TASKS_CSV="$PROJECT_DIR/tasks_report.csv"
METRICS_CSV="$PROJECT_DIR/metrics_report.csv"

sqlite3 -header -csv "$DB_FILE" "SELECT * FROM tasks;" > "$TASKS_CSV"
if [ $? -ne 0 ]; then
    echo "Error exporting tasks table to CSV."
else
    echo "Tasks table exported to $TASKS_CSV"
fi

sqlite3 -header -csv "$DB_FILE" "SELECT * FROM metrics;" > "$METRICS_CSV"
if [ $? -ne 0 ]; then
    echo "Error exporting metrics table to CSV."
else
    echo "Metrics table exported to $METRICS_CSV"
fi

# Deactivate Conda environment
conda deactivate

echo "Workflow completed!"
echo "Reports are available at:"
echo "  $TASKS_CSV"
echo "  $METRICS_CSV"

exit 0 