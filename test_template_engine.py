#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Template Engine Test Script
Generates YAML output from MasterTemplate.yaml for testing
"""

import os
import re
from typing import Dict, List, Optional, Any

# ============================================================
# Template Parser
# ============================================================

class TemplateParser:
    """Parse MasterTemplate.yaml and SelectionMap.yaml"""

    def extract_section_template(self, yaml_content: str, output_type: str, section_name: str) -> Optional[str]:
        """Extract section template from master template"""
        lines = yaml_content.split('\n')
        in_output_type = False
        in_section = False
        in_template = False
        template_lines = []
        template_indent = 0
        output_type_indent = 0

        for line in lines:
            trimmed = line.strip()
            current_indent = len(line) - len(line.lstrip())

            # Find the output type
            if trimmed == f"{output_type}:":
                in_output_type = True
                output_type_indent = current_indent
                continue

            if in_output_type:
                # Check for next output type (same indent level, different name)
                if (current_indent == output_type_indent and trimmed and
                    trimmed.endswith(':') and not trimmed.startswith('#') and
                    trimmed != f"{output_type}:"):
                    break

                # Check for top-level key
                if current_indent == 0 and trimmed and not trimmed.startswith('#'):
                    break

                # Find section name (not while in template)
                if not in_template and trimmed == f"{section_name}:":
                    in_section = True
                    continue

                if in_section:
                    # Find template: field
                    if trimmed.startswith('template:'):
                        in_template = True
                        if '|' in trimmed:
                            continue
                        continue

                    if in_template:
                        if template_indent == 0 and trimmed:
                            template_indent = current_indent

                        # End of template (indent decreased)
                        if current_indent < template_indent and trimmed and not trimmed.startswith('#'):
                            break

                        if current_indent >= template_indent:
                            content = line[template_indent:]
                            template_lines.append(content)
                        elif not trimmed:
                            template_lines.append('')

                    # Next section
                    if not in_template and trimmed and trimmed.endswith(':') and not trimmed.startswith('#'):
                        break

        return '\n'.join(template_lines) if template_lines else None

    def extract_common_section_template(self, yaml_content: str, section_name: str) -> Optional[str]:
        """Extract common section template"""
        lines = yaml_content.split('\n')
        in_common_sections = False
        in_section = False
        in_template = False
        template_lines = []
        template_indent = 0

        for line in lines:
            trimmed = line.strip()

            if trimmed == "common_sections:":
                in_common_sections = True
                continue

            if trimmed == "output_types:":
                break

            if in_common_sections:
                if not in_template and trimmed == f"{section_name}:":
                    in_section = True
                    continue

                if in_section:
                    if trimmed.startswith('template:'):
                        in_template = True
                        if '|' in trimmed:
                            continue
                        continue

                    if in_template:
                        current_indent = len(line) - len(line.lstrip())

                        if template_indent == 0 and trimmed:
                            template_indent = current_indent

                        if current_indent < template_indent and trimmed and not trimmed.startswith('#'):
                            break

                        if current_indent >= template_indent:
                            content = line[template_indent:]
                            template_lines.append(content)
                        elif not trimmed:
                            template_lines.append('')

                    if trimmed.startswith('description:'):
                        continue

                    if (not in_template and trimmed and trimmed.endswith(':') and
                        not trimmed.startswith('#') and not trimmed.startswith('description')):
                        break

        return '\n'.join(template_lines) if template_lines else None

    def extract_header_values(self, yaml_content: str, output_type: str) -> Dict[str, str]:
        """Extract header values from output type"""
        values = {}
        lines = yaml_content.split('\n')
        in_output_type = False
        in_header_values = False
        output_type_indent = 0

        for line in lines:
            trimmed = line.strip()
            current_indent = len(line) - len(line.lstrip())

            if trimmed == f"{output_type}:":
                in_output_type = True
                output_type_indent = current_indent
                continue

            if in_output_type:
                # Check for next output type
                if (current_indent == output_type_indent and trimmed and
                    trimmed.endswith(':') and not trimmed.startswith('#') and
                    trimmed != f"{output_type}:"):
                    break

                if trimmed == "header_values:":
                    in_header_values = True
                    continue

                if in_header_values:
                    if ':' in trimmed:
                        key, _, value = trimmed.partition(':')
                        key = key.strip()
                        value = value.strip()

                        # Remove quotes
                        if value.startswith('"') and value.endswith('"'):
                            value = value[1:-1]

                        if key and not key.startswith('#'):
                            values[key] = value

                    # End of header_values
                    if (trimmed.endswith(':') and ' ' not in trimmed and
                        trimmed != "header_values:"):
                        break

        return values

    def extract_section_list(self, yaml_content: str, selection_key: str) -> List[str]:
        """Extract section list from selection map"""
        sections = []
        lines = yaml_content.split('\n')
        in_selection_map = False
        in_selection = False
        in_sections = False

        for line in lines:
            trimmed = line.strip()

            if trimmed == "selection_map:":
                in_selection_map = True
                continue

            if in_selection_map:
                if trimmed == f"{selection_key}:":
                    in_selection = True
                    continue

                if in_selection:
                    if trimmed == "sections:":
                        in_sections = True
                        continue

                    if in_sections:
                        if trimmed.startswith('- '):
                            section_name = trimmed[2:].strip()
                            # Remove comments
                            if '#' in section_name:
                                section_name = section_name[:section_name.index('#')].strip()
                            if section_name:
                                sections.append(section_name)
                        elif trimmed and not trimmed.startswith('#'):
                            break

                    # Next selection
                    current_indent = len(line) - len(line.lstrip())
                    if current_indent == 0 and trimmed and not trimmed.startswith('#'):
                        break

        return sections


# ============================================================
# Template Renderer
# ============================================================

class TemplateRenderer:
    """Render templates with variable substitution"""

    def render(self, template: str, variables: Dict[str, Any]) -> str:
        """Render template with variables"""
        result = template

        # Process {{#if condition}}...{{/if}} blocks
        result = self._process_conditionals(result, variables)

        # Process {{! comment }} - remove them
        result = re.sub(r'\{\{!.*?\}\}', '', result, flags=re.DOTALL)

        # Process {{variable}} substitutions
        def replace_var(match):
            var_name = match.group(1)
            return str(variables.get(var_name, ''))

        result = re.sub(r'\{\{(\w+)\}\}', replace_var, result)

        return result

    def _process_conditionals(self, template: str, variables: Dict[str, Any]) -> str:
        """Process {{#if var}}...{{/if}} blocks with proper nesting support"""
        result = template

        # Process from innermost to outermost
        max_iterations = 100  # Prevent infinite loops
        iteration = 0

        while iteration < max_iterations:
            iteration += 1

            # Find the first {{#if that has a matching {{/if}} without nested {{#if
            # Start from the end to process innermost first
            if_start = -1
            if_end = -1
            var_name = None
            depth = 0

            i = 0
            while i < len(result):
                if result[i:i+5] == '{{#if':
                    if depth == 0:
                        # Find the end of the tag
                        tag_end = result.find('}}', i)
                        if tag_end != -1:
                            tag_content = result[i+5:tag_end].strip()
                            if_start = i
                            var_name = tag_content
                    depth += 1
                    i = result.find('}}', i) + 2 if result.find('}}', i) != -1 else i + 1
                elif result[i:i+7] == '{{/if}}':
                    depth -= 1
                    if depth == 0 and if_start != -1:
                        if_end = i + 7
                        break
                    i += 7
                else:
                    i += 1

            if if_start == -1 or if_end == -1:
                break

            # Extract the content between {{#if var}} and {{/if}}
            content_start = result.find('}}', if_start) + 2
            content = result[content_start:if_end-7]

            # Check if variable exists and is truthy
            if self._var_exists(var_name, variables):
                # Process nested conditionals in content first
                processed_content = self._process_conditionals(content, variables)
                result = result[:if_start] + processed_content + result[if_end:]
            else:
                result = result[:if_start] + result[if_end:]

        return result

    def _var_exists(self, var_name: str, variables: Dict[str, Any]) -> bool:
        """Check if variable exists and is truthy"""
        if var_name not in variables:
            return False
        value = variables[var_name]
        if isinstance(value, bool):
            return value
        if isinstance(value, str):
            return bool(value)
        return bool(value)


# ============================================================
# Test Data
# ============================================================

def create_test_variables() -> Dict[str, Any]:
    """Create test variables for face_sheet"""
    return {
        # Common variables
        'title': 'テスト顔三面図',
        'author': 'テスト作者',
        'type': 'character_design',
        'color_mode': 'fullcolor',
        'output_style': 'anime',
        'aspect_ratio': '1:1',
        'is_duotone': False,
        'title_overlay_enabled': False,

        # Header values (will be overwritten from template)
        'header_title_ja': '顔三面図',
        'header_title_en': 'Face Character Reference Sheet',

        # Face sheet specific
        'character_name': 'テストキャラ',
        'character_description': 'テスト用キャラクターの説明文',
        'expression': 'neutral expression',
        'reference_image_path': 'test_reference.png',

        # Style info
        'style_info_style': '日本のアニメスタイル, 2Dセルシェーディング',
        'style_info_proportions': 'Normal head-to-body ratio (6-7 heads)',
        'style_info_description': 'High quality anime illustration',
    }


# ============================================================
# Main
# ============================================================

def main():
    master_template_path = 'nanobananaMacOS/Resources/Templates/MasterTemplate.yaml'
    selection_map_path = 'nanobananaMacOS/Resources/Templates/SelectionMap.yaml'
    output_dir = 'templatetest'

    # Read templates
    try:
        with open(master_template_path, 'r', encoding='utf-8') as f:
            master_template = f.read()
    except FileNotFoundError:
        print(f"Error: Cannot read {master_template_path}")
        return

    try:
        with open(selection_map_path, 'r', encoding='utf-8') as f:
            selection_map = f.read()
    except FileNotFoundError:
        print(f"Error: Cannot read {selection_map_path}")
        return

    parser = TemplateParser()
    renderer = TemplateRenderer()

    # Get section list for face_sheet
    sections = parser.extract_section_list(selection_map, 'face_sheet')
    print("=== Sections for face_sheet ===")
    for i, section in enumerate(sections, 1):
        print(f"{i}. {section}")
    print()

    # Get header values
    header_values = parser.extract_header_values(master_template, 'face_sheet')
    print("=== Header values ===")
    for key, value in header_values.items():
        print(f"{key}: {value}")
    print()

    # Create variables
    variables = create_test_variables()

    # Add header values to variables
    variables.update(header_values)

    # Generate YAML
    yaml_parts = []
    optional_sections = ['title_overlay', 'reference_image', 'bonus_character']

    for section_name in sections:
        # Try output type specific section first
        template = parser.extract_section_template(master_template, 'face_sheet', section_name)

        # Try common section if not found
        if template is None:
            template = parser.extract_common_section_template(master_template, section_name)

        if template:
            rendered = renderer.render(template, variables)
            if rendered.strip():
                yaml_parts.append(rendered)
        elif section_name not in optional_sections:
            print(f"Warning: Section '{section_name}' not found")

    final_yaml = '\n'.join(yaml_parts)

    # Output
    print("=== Generated YAML ===")
    print(final_yaml)

    # Save to file
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, '01_face_sheet_template.yaml')

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(final_yaml)

    print(f"\n=== Saved to {output_path} ===")


if __name__ == '__main__':
    main()
