#!/bin/bash

# Undo Script for Telegram Chat Analysis Setup
# WARNING: This script will attempt to remove software and data.
# Review each command carefully before running this script.
# You may need to run parts of this script with sudo privileges.

echo "WARNING: This script will attempt to remove software and data related to the Telegram chat analysis setup."
echo "It is highly recommended to review each command in this script before proceeding."
read -p "Are you sure you want to continue? (yes/no): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "Undo operation cancelled by the user."
    exit 1
fi

echo "Proceeding with undo operations..."

# Stop and remove Ollama service and application (commands might vary slightly by system)
echo "
--- Undoing Ollama --- (Requires sudo)"
echo "Attempting to stop and remove Ollama. You might be prompted for your sudo password."
read -p "Stop and remove Ollama? (yes/no): " ollama_confirm
if [ "$ollama_confirm" == "yes" ]; then
    sudo systemctl stop ollama
    sudo systemctl disable ollama
    sudo rm /etc/systemd/system/ollama.service
    sudo systemctl daemon-reload
    sudo rm $(which ollama) # Assumes ollama is in PATH and was installed to /usr/local/bin/ollama
    # Ollama models and data are typically in ~/.ollama or /usr/share/ollama/. 
    # Be very careful with these directories.
    echo "Ollama application and service removal attempted."
    echo "Ollama models are stored in ~/.ollama/models and /usr/share/ollama/models."
    echo "If you want to remove these, you must do so manually, e.g.:"
    echo "  rm -rf ~/.ollama/models"
    echo "  sudo rm -rf /usr/share/ollama/models"
    read -p "Remove ~/.ollama directory (contains models, logs, etc.)? (yes/no): " ollama_data_confirm
    if [ "$ollama_data_confirm" == "yes" ]; then
        rm -rf ~/.ollama
        echo "~/.ollama directory removed."
    else
        echo "Skipping removal of ~/.ollama directory."
    fi
else
    echo "Skipping Ollama removal."
fi

# Remove Python packages from the telegram_bot conda environment
# This assumes you have conda and the environment activated or will activate it.
echo "
--- Undoing Python Packages (in telegram_bot conda env) --- "
read -p "Remove Python packages (unstructured, ollama, etc.) from 'telegram_bot' conda env? (yes/no): " pkg_confirm
if [ "$pkg_confirm" == "yes" ]; then
    echo "Please ensure your 'telegram_bot' conda environment is active."
    echo "Run the following commands manually if the environment is not active or if you prefer:"
    echo "  conda activate telegram_bot"
    echo "  pip uninstall unstructured python-magic ollama telethon python-dotenv -y"
    # Alternatively, to remove the entire environment:
    # echo "  conda deactivate"
    # echo "  conda env remove -n telegram_bot"
    read -p "Attempt to run pip uninstall now (assumes 'telegram_bot' is active or on PATH)? (yes/no): " pip_uninstall_confirm
    if [ "$pip_uninstall_confirm" == "yes" ]; then
        # Trying to ensure it runs in the conda env if possible, though direct activation in script is tricky
        if [[ "$CONDA_DEFAULT_ENV" == "telegram_bot" || -n "$(conda env list | grep telegram_bot)" ]]; then
            echo "Attempting uninstall within environment..."
            conda run -n telegram_bot pip uninstall unstructured python-magic ollama telethon python-dotenv -y
        else
            echo "Conda environment 'telegram_bot' not detected as active. Please uninstall packages manually as shown above."
        fi
    else
        echo "Skipping automatic pip uninstall. Please do it manually if desired."
    fi
else
    echo "Skipping Python package removal."
fi

# Remove NLTK data
echo "
--- Undoing NLTK Data --- "
read -p "Remove NLTK data from ~/nltk_data (punkt, averaged_perceptron_tagger, etc.)? (yes/no): " nltk_confirm
if [ "$nltk_confirm" == "yes" ]; then
    rm -rf ~/nltk_data/tokenizers/punkt.zip ~/nltk_data/tokenizers/punkt/
    rm -rf ~/nltk_data/tokenizers/punkt_tab.zip ~/nltk_data/tokenizers/punkt_tab/
    rm -rf ~/nltk_data/taggers/averaged_perceptron_tagger.zip ~/nltk_data/taggers/averaged_perceptron_tagger/
    rm -rf ~/nltk_data/taggers/averaged_perceptron_tagger_eng.zip ~/nltk_data/taggers/averaged_perceptron_tagger_eng/
    # Add other specific NLTK resources if more were downloaded
    echo "Attempted to remove specific NLTK resources. You might want to inspect ~/nltk_data for other items."
else
    echo "Skipping NLTK data removal."
fi

# Remove created files
echo "
--- Undoing Project Files --- "
read -p "Remove generated files (personal_assistant.db, qwen-14b-model.Modelfile, data/*, setup_summary.md, this_script.sh)? (yes/no): " files_confirm
if [ "$files_confirm" == "yes" ]; then
    rm -i personal_assistant.db
    rm -i qwen-14b-model.Modelfile
    rm -i data/kanha_chat_*.txt # Be careful with wildcards
    rm -i setup_and_workflow_summary.md
    echo "Note: telegram_export.py and process_chats.py are not automatically removed by this script."
    echo "This script itself (undo_setup.sh) will also not be removed automatically."
else
    echo "Skipping project file removal."
fi

echo "
Undo script finished. Please manually verify the removal of any components as needed." 