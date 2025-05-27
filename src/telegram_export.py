import os
import configparser
from datetime import datetime, timedelta, timezone
from telethon.sync import TelegramClient
from telethon.tl.types import InputPeerChannel
from dotenv import load_dotenv

load_dotenv()

config = configparser.ConfigParser()
config.read('config.ini')

# Configuration
API_ID = int(config['Telegram']['api_id'])
API_HASH = config['Telegram']['api_hash']
PHONE = config['Telegram']['phone']
CHAT_NAME = config['Telegram']['chat_name']
OUTPUT_DIR = "data"
SESSION_FILE = os.getenv('SESSION_NAME')

def main():
    client = TelegramClient(SESSION_FILE, API_ID, API_HASH)
    
    with client:
        client.start(PHONE)
        
        # Find the target chat
        chat = None
        for dialog in client.iter_dialogs():
            if dialog.name.lower() == CHAT_NAME.lower():
                chat = dialog.input_entity
                break
        
        if not chat:
            raise ValueError(f"Chat '{CHAT_NAME}' not found")

        # Calculate time range (last 7 days)
        end_date = datetime.now(timezone.utc)
        print(end_date)
        start_date = end_date - timedelta(days=7)

        # Create output directory
        os.makedirs(OUTPUT_DIR, exist_ok=True)
        
        # Generate filename with timestamp
        filename = f"kanha_chat_{end_date.strftime('%Y-%m-%d')}.txt"
        output_path = os.path.join(OUTPUT_DIR, filename)

        # Export messages
        with open(output_path, 'w', encoding='utf-8') as f:
            # Correctly fetch messages from start_date up to (but not including) end_date
            messages = client.iter_messages(
                chat,
                offset_date=start_date,
                reverse=True
            )
            
            # Filter messages by date in the loop
            for msg in messages:
                # msg.date is already > start_date due to offset_date and reverse=True.
                # Stop if message date is at or after end_date (i.e., outside the desired window).
                if msg.date >= end_date:
                    break
                if msg.text:
                    f.write(f"[{msg.date}] {msg.sender_id}: {msg.text}\n")

if __name__ == "__main__":
    main()
