# process_chats.py
from unstructured.partition.text import partition_text
import sqlite3
import ollama # Added import for ollama
import json # Added import for json
import re # Added for regex-based JSON extraction

def analyze_chat(file_path):
    # Extract structured data
    elements = partition_text(filename=file_path)
    
    # Connect to DB
    conn = sqlite3.connect('personal_assistant.db')
    c = conn.cursor()
    
    # Create tables
    c.execute('''CREATE TABLE IF NOT EXISTS tasks 
                 (id INTEGER PRIMARY KEY, task TEXT, category TEXT)''')
    c.execute('''CREATE TABLE IF NOT EXISTS metrics
                 (id INTEGER PRIMARY KEY, sleep_hours INTEGER, food_log TEXT)''') # Added metrics table
    
    # Process each text element
    for el in elements:
        # Check if element text is not empty or just whitespace
        if not el.text or el.text.isspace():
            print(f"Skipping empty element: {el}")
            continue

        print(f"Processing element: {el.text[:100]}...") # Log the element being processed

        # Enhanced prompt to ask for JSON only, but still good to have robust parsing
        prompt_text = f'''Extract from: {el.text}
                     ONLY output a single valid JSON object with the following schema and nothing else. Do NOT include any comments in the JSON output.
                     {{ "tasks": ["string"], "sleep_hours": integer or null, "food_log": ["string"] }}
                     Example: {{"tasks": ["buy groceries"], "sleep_hours": 7, "food_log": ["salad"]}}'''

        response = ollama.generate(
            model='qwen-14b',
            prompt=prompt_text,
            options={"temperature": 0.0} # Lower temperature for more deterministic JSON output
        )
        
        raw_llm_output = response['response']
        print(f"LLM raw response: {raw_llm_output}") # Keep logging raw response for debugging

        # Attempt to extract JSON from the raw output
        json_str = None # Initialize json_str
        try:
            # First, try to find JSON within markdown code blocks ```json ... ```
            match = re.search(r"```json\n(.*?)\n```", raw_llm_output, re.DOTALL)
            if match:
                json_str = match.group(1)
            else:
                # If no markdown, try to find the first '{' and last '}'
                first_brace = raw_llm_output.find('{')
                last_brace = raw_llm_output.rfind('}')
                if first_brace != -1 and last_brace != -1 and last_brace > first_brace:
                    json_str = raw_llm_output[first_brace:last_brace+1]
                else:
                    # If no clear JSON, and as a last resort, try to see if the model just gave JSON without preamble
                    json_str = raw_llm_output

            # Remove // comments before parsing
            if json_str:
                # Corrected comment stripping
                json_str = re.sub(r"//.*", "", json_str) # Remove all // comments to the end of their line
                json_str = json_str.strip() # General strip for leading/trailing whitespace on the whole block

            data = json.loads(json_str)
            
            # Insert tasks if any
            if data.get('tasks'):
                for task_item in data['tasks']:
                    if isinstance(task_item, str): # Basic validation
                        c.execute('INSERT INTO tasks (task, category) VALUES (?,?)', 
                                 (task_item, None)) # Category not explicitly extracted yet
                    else:
                        print(f"Skipping non-string task item: {task_item}")
            
            # Insert metrics if any
            sleep_hours = data.get('sleep_hours')
            food_log_items = data.get('food_log', [])
            
            if sleep_hours is not None or food_log_items:
                # Join food log items into a comma-separated string for storage
                food_log_str = ", ".join(food_log_items) if food_log_items else None
                c.execute('INSERT INTO metrics (sleep_hours, food_log) VALUES (?,?)', 
                         (sleep_hours, food_log_str))

        except json.JSONDecodeError as e:
            print(f"Error decoding JSON: {e}")
            print(f"Attempted to parse (after comment removal): {json_str}")
        except KeyError as e:
            print(f"KeyError in LLM response structure: {e}")
            if 'data' in locals(): print(f"Parsed data: {data}")
        except Exception as e:
            print(f"An unexpected error occurred processing LLM response: {e}")
            if json_str: print(f"Problematic JSON string (after comment removal): {json_str}")

    conn.commit()
    conn.close()

if __name__ == '__main__':
    # Example usage: python3 process_chats.py data/kanha_chat_YYYY-MM-DD.txt
    import sys
    if len(sys.argv) > 1:
        chat_file_path = sys.argv[1]
        analyze_chat(chat_file_path)
    else:
        print("Please provide the path to the chat file.")
        print("Usage: python3 process_chats.py <path_to_chat_file>") 