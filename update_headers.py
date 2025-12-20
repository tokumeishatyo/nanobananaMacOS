#!/usr/bin/env python3
"""
Update section headers in debugPython yaml files to unified format.
"""

import os
import re

# Header replacements mapping
HEADER_REPLACEMENTS = {
    # Output section
    r"# Output Specifications": "# Output",
    r"# Output Format": "# Output",
    r"# Output Settings": "# Output",

    # Input section
    r"# Input: Face Sheet from Step 1": "# Input - Face Sheet from Step 1",
    r"# Input: Body Sheet from Step 2": "# Input - Body Sheet from Step 2",
    r"# Input Images": "# Input",
    r"# Input Image \(Source Character\)": "# Input - Source Character",
    r"# Input Image$": "# Input",

    # Constraints section
    r"# CRITICAL CONSTRAINTS": "# Constraints (CRITICAL)",
    r"# Constraints \(Critical\) - Fit Mode:": "# Constraints (CRITICAL) - Fit Mode:",
    r"# Constraints \(Critical\)": "# Constraints (CRITICAL)",
    r"# Constraints$": "# Constraints (CRITICAL)",

    # Style section
    r"# Style Settings": "# Style",

    # Other sections that need standardization
    r"# Body Configuration": "# Body",
    r"# Render Type": "# Render",
    r"# Outfit Configuration": "# Outfit",
    r"# Outfit from Reference Image": "# Outfit - From Reference Image",
    r"# Pose Definition": "# Pose",
    r"# Pose Capture \(ポーズキャプチャ\)": "# Pose Capture",
    r"# Transform Settings": "# Transform",
    r"# Preservation Settings": "# Preservation",
    r"# Sprite Settings": "# Sprite",
    r"# Background Capture Settings": "# Background Capture",
    r"# Title Configuration": "# Title",
    r"# Main Character Image": "# Main Character",
    r"# Bonus Character Image": "# Bonus Character",
    r"# Information Sections": "# Sections",
    r"# Generation Instructions": "# Generation",
}

def update_file(filepath):
    """Update headers in a single file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content

    for pattern, replacement in HEADER_REPLACEMENTS.items():
        content = re.sub(pattern, replacement, content)

    # Add Anti-Hallucination header if missing
    if "anti_hallucination:" in content and "# Anti-Hallucination" not in content:
        content = re.sub(
            r"\nanti_hallucination:",
            "\n# ====================================================\n# Anti-Hallucination (MUST FOLLOW)\n# ====================================================\nanti_hallucination:",
            content
        )

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

def main():
    debug_dir = "/workspace/debugPython"
    updated = []

    for filename in sorted(os.listdir(debug_dir)):
        if filename.endswith('.yaml'):
            filepath = os.path.join(debug_dir, filename)
            if update_file(filepath):
                updated.append(filename)
                print(f"  Updated: {filename}")
            else:
                print(f"  No changes: {filename}")

    print(f"\nTotal updated: {len(updated)} files")

if __name__ == "__main__":
    main()
