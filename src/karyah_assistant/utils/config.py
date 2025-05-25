"""Configuration utilities."""
import os
import yaml

def load_config(config_path="configs/default.yml"):
    """Load configuration from YAML file."""
    # Adjust path relative to this file's location if needed
    # script_dir = os.path.dirname(__file__)
    # config_abs_path = os.path.join(script_dir, "../..", config_path)
    # Use absolute path if running from different directories
    config_abs_path = os.path.abspath(config_path) 
    
    if not os.path.exists(config_abs_path):
        print(f"Warning: Config file not found at {config_abs_path}")
        # Try path relative to potential project root if setup.py was used
        alt_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../..", config_path))
        if os.path.exists(alt_path):
            config_abs_path = alt_path
        else:
            print(f"Warning: Also not found at {alt_path}. Returning empty config.")
            return {}

    with open(config_abs_path, "r") as f:
        return yaml.safe_load(f)
