import toml
import os

file_path = '.gemini\\skills\\openspec-new-change\\SKILL.toml'
try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    print("File content length:", len(content))
    print("Last 100 chars:", repr(content[-100:]))
    data = toml.load(file_path)
    print("Parsed successfully")
except Exception as e:
    print(f"Error: {e}")
    print("Position:", e.pos if hasattr(e, 'pos') else 'N/A')