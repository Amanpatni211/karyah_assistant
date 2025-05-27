# Telegram Personal Assistant

Extract tasks, sleep hours, and food logs from your Telegram chats using local LLMs, helping you track your daily activities and habits.

## 📋 Overview

This project creates a pipeline to:
1. Export your Telegram chat messages daily
2. Process these messages using a local LLM (Qwen 14B via Ollama)
3. Extract structured information like tasks, sleep hours, and food items 
4. Store everything in a database for tracking and analysis
5. Generate CSV reports of your data

All processing happens locally on your machine, ensuring your chat data remains private.

## ✨ Features

- **Daily Chat Export**: Automatically exports the last 24 hours of messages from a specified Telegram chat
- **Privacy-Focused**: Uses Ollama to run the LLM locally on your machine
- **Structured Extraction**: Identifies tasks, sleep patterns, and food consumption from natural language
- **Persistent Storage**: Saves extracted data to a SQLite database for long-term tracking
- **Easy Reports**: Generates CSV files with your extracted data for simple viewing and analysis

## 🛠️ Installation

### Prerequisites
- Linux/macOS/WSL (Windows Subsystem for Linux)
- Python 3.8+
- Conda or Miniconda
- Telegram API credentials (api_id and api_hash from https://my.telegram.org)

### Step 1: Clone the repository
```bash
git clone https://github.com/Amanpatni211/karyah_assistant.git
cd telegram-personal-assistant
```

### Step 2: Create and configure Conda environment
```bash
conda create -n telegram_bot python=3.8
conda activate telegram_bot
```

### Step 3: Install Ollama (for local LLM)
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### Step 4: Install Python dependencies
```bash
conda activate telegram_bot
pip install telethon python-dotenv unstructured python-magic ollama
```

### Step 5: Set up configuration
Create a `config.ini` file:
```ini
[Telegram]
api_id = YOUR_TELEGRAM_API_ID
api_hash = YOUR_TELEGRAM_API_HASH
phone = YOUR_PHONE_NUMBER
chat_name = TARGET_CHAT_NAME
```

Create a `.env` file:
```
SESSION_NAME=your_session_name
```

### Step 6: Set up the LLM model
```bash
# Pull the base model
ollama pull qwen:14b

# Create our custom model
ollama create qwen-14b -f models/qwen-14b-model.Modelfile
```

## 🚀 Usage

### Initial setup
Make the scripts executable:
```bash
chmod +x scripts/run_daily_analysis.sh
chmod +x scripts/undo_setup.sh
```

### Run the daily analysis
```bash
./scripts/run_daily_analysis.sh
```

This will:
1. Export your Telegram chats from the last 24 hours
2. Process them with the LLM
3. Save extracted information to the database
4. Generate CSV reports at the root of the project

### Viewing your data
After running the analysis, you'll have:
- `tasks_report.csv`: Contains all extracted tasks
- `metrics_report.csv`: Contains sleep hours and food log entries

You can also query the SQLite database directly:
```bash
sqlite3 personal_assistant.db
```

## 📁 Project Structure

```
telegram-personal-assistant/
├── data/                   # Chat export files
├── docs/                   # Documentation
├── models/                 # LLM model files
│   └── qwen-14b-model.Modelfile
├── scripts/                # Shell scripts
│   ├── run_daily_analysis.sh
│   └── undo_setup.sh
├── src/                    # Python source code
│   ├── telegram_export.py  # Exports Telegram chats
│   └── process_chats.py    # Processes chats with LLM
├── .env                    # Environment variables (not tracked)
├── .gitignore              # Git ignore file
├── config.ini              # Configuration (not tracked)
├── personal_assistant.db   # SQLite database (not tracked)
└── README.md               # This file
```

## 🔄 How It Works

1. **Telegram Export**: `telegram_export.py` connects to Telegram using your credentials and exports the last 24 hours of messages from your target chat to a text file in the `data/` directory.

2. **Text Processing**: `process_chats.py` uses the `unstructured` library to break the chat text into manageable elements.

3. **LLM Analysis**: Each text element is sent to the local Qwen 14B model running through Ollama, which extracts tasks, sleep hours, and food information.

4. **Database Storage**: Extracted information is stored in a SQLite database (`personal_assistant.db`) with tables for tasks and metrics.

5. **Reporting**: CSV reports are generated from the database tables for easy viewing and analysis.

## ⚙️ Automation

For full automation, consider setting up a cron job to run the analysis daily:

```bash
# Edit your crontab
crontab -e

# Add a line to run the script at 11:59 PM daily
59 23 * * * /path/to/telegram-personal-assistant/scripts/run_daily_analysis.sh
```

## 🧹 Uninstallation

If you want to remove the setup:

```bash
./scripts/undo_setup.sh
```

This script provides an interactive way to remove components of the system.

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgements

- [Ollama](https://ollama.com/) for making local LLMs accessible
- [Telethon](https://github.com/LonamiWebs/Telethon) for Telegram API access
- [Unstructured](https://github.com/Unstructured-IO/unstructured) for text processing
- [Qwen](https://github.com/QwenLM/Qwen) for the LLM model 
