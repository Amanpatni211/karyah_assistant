# karyah_assistant

## Setup

*This setup assumes you have already cloned the repository or created the project locally.*

```bash
cd karyah_assistant # Navigate to project directory if not already there

# Option 1: Create and activate conda environment (Recommended)
# (Run this if you didn't create the environment during initial setup)
conda env create -f environment.yml
conda activate karyah_assistant

# Option 2: Install in existing environment
# Ensure your current environment has the necessary packages
pip install -e .
pip install -r requirements.txt
```

## Project Structure
```
├── configs/          # Configuration files
├── data/             # Raw and processed data (not in Git)
├── docs/             # Documentation
├── notebooks/        # Jupyter notebooks
├── results/          # Output of experiments (not in Git)
├── src/              # Source code
│   └── karyah_assistant/
│       ├── data/     # Data processing
│       ├── models/   # ML models
│       ├── utils/    # Utilities
│       └── visualization/ # Plotting and visualization
└── tests/            # Unit tests
```

## License
Copyright (c) 2025 [Your Name/Organization]
