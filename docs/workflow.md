# Telegram Personal Assistant Workflow

This document provides a simplified explanation of how the Telegram Personal Assistant works.

## Daily Workflow

The system follows this daily workflow to help you track tasks, sleep, and food from your Telegram chats:

```
Telegram Chat → Export → LLM Processing → Database → Reports
```

### 1. Telegram Chat Export

Every day, the system connects to Telegram and exports the last 24 hours of messages from your specified chat.

- **Script**: `src/telegram_export.py`
- **Output**: Text file in the `data/` directory (e.g., `data/kanha_chat_2023-05-28.txt`)
- **Configuration**: Uses your Telegram API credentials from `config.ini`

### 2. LLM Processing

The exported chat messages are processed by a local Large Language Model (LLM) to extract structured information.

- **Script**: `src/process_chats.py`
- **Model**: Qwen 14B (runs locally via Ollama)
- **Processing**: The text is split into manageable chunks and each chunk is analyzed by the LLM

### 3. Information Extraction

The LLM identifies and extracts three types of information:

- **Tasks**: Activities or to-do items mentioned in your chat
- **Sleep Hours**: Any mentions of sleep duration
- **Food Log**: Food items or meals mentioned in your chat

For example, from a message like:
```
"Today I woke up at 7am after sleeping for 6 hours, had eggs for breakfast, and need to finish my report."
```

The LLM would extract:
- Task: "finish my report"
- Sleep hours: 6
- Food log: "eggs for breakfast"

### 4. Database Storage

Extracted information is stored in an SQLite database (`personal_assistant.db`):

- **Tasks Table**: Stores identified tasks
- **Metrics Table**: Stores sleep hours and food logs

### 5. CSV Reports

Finally, the system generates CSV reports for easy viewing:

- `tasks_report.csv`: All extracted tasks
- `metrics_report.csv`: Sleep hours and food logs

## Running the Workflow

To run the entire workflow:

```bash
./scripts/run_daily_analysis.sh
```

This single command handles all steps in the process, from exporting Telegram messages to generating the final reports.

## Automation

For truly hands-off operation, set up a cron job to run the workflow daily:

```bash
# Run at 11:59 PM every day
59 23 * * * /path/to/telegram-personal-assistant/scripts/run_daily_analysis.sh
```

This allows you to passively track your daily activities mentioned in your Telegram chats without any manual intervention. 