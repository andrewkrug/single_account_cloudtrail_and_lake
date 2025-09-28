#!/bin/bash

# Create architecture diagram using Python with a virtual environment
echo "Creating virtual environment for diagram generation..."

# Create virtual environment
python3 -m venv diagram_env

# Activate and install matplotlib
source diagram_env/bin/activate
pip install matplotlib

# Run the diagram creation script
python create_diagram.py

# Deactivate virtual environment
deactivate

# Clean up virtual environment
rm -rf diagram_env

echo "Diagram creation complete!"