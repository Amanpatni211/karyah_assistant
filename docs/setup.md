# Setup Guide for Telegram Personal Assistant

This document provides detailed instructions for setting up the Telegram Personal Assistant system.

## Core Components

### 1. Ollama (LLM Runner)
- **Installation**: 
  ```bash
  curl -fsSL https://ollama.com/install.sh | sh
  ```
- Ollama runs as a background service to provide local LLM inference.

### 2. Python Environment (Conda)
- **Required packages**:
  - `unstructured[md]`: For parsing text files
  - `python-magic`: For file type detection
  - `ollama`: Python client for Ollama
  - `telethon`: For Telegram API interaction
  - `python-dotenv`: For environment variable management
- **NLTK Resources**: The system requires several NLTK data packages:
  - `punkt`, `punkt_tab` (for tokenization)
  - `averaged_perceptron_tagger`, `averaged_perceptron_tagger_eng` (for text analysis)

### 3. LLM Model (Qwen 14B)
- **Installation**:
  ```bash
  # Pull the base model
  ollama pull qwen:14b
  
  # Create custom model with our parameters
  ollama create qwen-14b -f models/qwen-14b-model.Modelfile
  ```
- The model is configured with increased context length (4096 tokens) and a system prompt optimized for personal accountability tasks.

### 4. Scripts
- **`telegram_export.py`**: Fetches messages from Telegram
- **`process_chats.py`**: Processes text with the LLM
- **`run_daily_analysis.sh`**: Coordinates the entire pipeline
- **`undo_setup.sh`**: Helps remove the setup if needed

### 5. Database
- SQLite database (`personal_assistant.db`) with two tables:
  - `tasks`: Stores extracted tasks
  - `metrics`: Stores sleep hours and food log entries

## Step-by-Step Setup Instructions

1. **Create and activate a Conda environment**:
   ```bash
   conda create -n telegram_bot python=3.8
   conda activate telegram_bot
   ```

2. **Install Ollama**:
   ```bash
   curl -fsSL https://ollama.com/install.sh | sh
   ```

3. **Install Python dependencies**:
   ```bash
   pip install telethon python-dotenv unstructured python-magic ollama
   ```

4. **Configure Telegram credentials**:
   - Create `config.ini` (use `config.ini.sample` as a template)
   - Create `.env` (use `env.sample` as a template)

5. **Set up the LLM model**:
   ```bash
   ollama pull qwen:14b
   ollama create qwen-14b -f models/qwen-14b-model.Modelfile
   ```

6. **Make scripts executable**:
   ```bash
   chmod +x scripts/run_daily_analysis.sh scripts/undo_setup.sh
   ```

7. **Run the pipeline**:
   ```bash
   ./scripts/run_daily_analysis.sh
   ```

## Database Schema

### tasks table
```sql
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY,
  task TEXT,
  category TEXT
)
```

### metrics table
```sql
CREATE TABLE metrics (
  id INTEGER PRIMARY KEY,
  sleep_hours INTEGER,
  food_log TEXT
)
```

## Troubleshooting

### Common Issues

1. **Empty database after processing**:
   - Ensure your chat file contains substantive messages
   - Check LLM responses in the console output
   - Verify that JSON parsing was successful

2. **Ollama connection issues**:
   - Ensure Ollama service is running (`systemctl status ollama`)
   - Check that the model is properly installed (`ollama list`)

3. **NLTK resource errors**:
   - If you see errors about missing NLTK resources, run:
     ```python
     import nltk
     nltk.download('punkt')
     nltk.download('punkt_tab')
     nltk.download('averaged_perceptron_tagger')
     nltk.download('averaged_perceptron_tagger_eng')
     ``` 