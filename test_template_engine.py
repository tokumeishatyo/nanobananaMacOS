#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Template Engine Test Script
Generates YAML output from MasterTemplate.yaml for all output types
and compares with legacy generator output.

Usage:
  python3 test_template_engine.py           # Generate all output types
  python3 test_template_engine.py face      # Generate only face_sheet
  python3 test_template_engine.py --compare # Compare new vs old
"""

import os
import re
import sys
import difflib
from typing import Dict, List, Optional, Any
from datetime import datetime

# ============================================================
# Configuration
# ============================================================

OUTPUT_DIR = 'templatetest'
MASTER_TEMPLATE_PATH = 'nanobananaMacOS/Resources/Templates/MasterTemplate.yaml'
SELECTION_MAP_PATH = 'nanobananaMacOS/Resources/Templates/SelectionMap.yaml'

# Output type configurations
OUTPUT_TYPES = {
    'face_sheet': {
        'selection_key': 'face_sheet',
        'filename': '01_face_sheet',
        'description': '顔三面図',
    },
    'body_sheet': {
        'selection_key': 'body_sheet',
        'filename': '02_body_sheet',
        'description': '素体三面図',
    },
    'outfit_preset': {
        'selection_key': 'outfit_sheet_preset',
        'filename': '03_outfit_preset',
        'description': '衣装着用（プリセット）',
    },
    'outfit_reference': {
        'selection_key': 'outfit_sheet_reference',
        'filename': '03_outfit_reference',
        'description': '衣装着用（参考画像）',
    },
    'pose_preset': {
        'selection_key': 'pose_preset',
        'filename': '04_pose_preset',
        'description': 'ポーズ（プリセット）',
    },
    'pose_reference': {
        'selection_key': 'pose_reference',
        'filename': '04_pose_reference',
        'description': 'ポーズ（参考画像）',
    },
    'background': {
        'selection_key': 'background_without_reference',
        'filename': '06_background',
        'description': '背景生成',
    },
    'four_panel': {
        'selection_key': 'four_panel',
        'filename': '08_four_panel',
        'description': '4コマ漫画',
    },
    'style_transform': {
        'selection_key': 'style_transform_normal',
        'filename': '09_style_transform',
        'description': 'スタイル変換',
    },
    'infographic': {
        'selection_key': 'infographic',
        'filename': '10_infographic',
        'description': 'インフォグラフィック',
    },
}

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
        in_skip_template = False  # For skipping template blocks we don't care about
        template_lines = []
        template_indent = 0
        skip_template_indent = 0
        output_type_indent = 0

        for line in lines:
            trimmed = line.strip()
            current_indent = len(line) - len(line.lstrip())

            # Skip content inside template blocks we're not interested in
            if in_skip_template:
                if current_indent < skip_template_indent and trimmed and not trimmed.startswith('#'):
                    in_skip_template = False
                    skip_template_indent = 0
                else:
                    continue

            # Don't match output_type when we're inside a template block
            if not in_template and trimmed == f"{output_type}:":
                in_output_type = True
                output_type_indent = current_indent
                continue

            if in_output_type:
                if (current_indent == output_type_indent and trimmed and
                    trimmed.endswith(':') and not trimmed.startswith('#') and
                    trimmed != f"{output_type}:"):
                    break

                if current_indent == 0 and trimmed and not trimmed.startswith('#'):
                    break

                if not in_template and trimmed == f"{section_name}:":
                    in_section = True
                    continue

                # If not in our target section but see 'template:', skip that block
                if not in_section and trimmed.startswith('template:') and '|' in trimmed:
                    in_skip_template = True
                    # Find the indent of the next non-empty line to set skip_template_indent
                    skip_template_indent = current_indent + 2  # template content is indented more
                    continue

                if in_section:
                    if trimmed.startswith('template:'):
                        in_template = True
                        if '|' in trimmed:
                            continue
                        continue

                    if in_template:
                        if template_indent == 0 and trimmed:
                            template_indent = current_indent

                        if current_indent < template_indent and trimmed and not trimmed.startswith('#'):
                            break

                        if current_indent >= template_indent:
                            content = line[template_indent:]
                            template_lines.append(content)
                        elif not trimmed:
                            template_lines.append('')

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

                        if value.startswith('"') and value.endswith('"'):
                            value = value[1:-1]

                        if key and not key.startswith('#'):
                            values[key] = value

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
                            if '#' in section_name:
                                section_name = section_name[:section_name.index('#')].strip()
                            if section_name:
                                sections.append(section_name)
                        elif trimmed and not trimmed.startswith('#'):
                            break

                    current_indent = len(line) - len(line.lstrip())
                    if current_indent == 0 and trimmed and not trimmed.startswith('#'):
                        break

        return sections

    def extract_output_type_key(self, yaml_content: str, selection_key: str) -> Optional[str]:
        """Extract output_type_key from selection map"""
        lines = yaml_content.split('\n')
        in_selection_map = False
        in_selection = False

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
                    if trimmed.startswith("output_type_key:"):
                        value = trimmed.split(':', 1)[1].strip()
                        if value.startswith('"') and value.endswith('"'):
                            value = value[1:-1]
                        return value

                    current_indent = len(line) - len(line.lstrip())
                    if current_indent == 0 and trimmed and not trimmed.startswith('#'):
                        break

        return None


# ============================================================
# Template Renderer
# ============================================================

class TemplateRenderer:
    """Render templates with variable substitution"""

    def render(self, template: str, variables: Dict[str, Any]) -> str:
        result = template
        result = self._process_conditionals(result, variables)
        result = re.sub(r'\{\{!.*?\}\}', '', result, flags=re.DOTALL)

        def replace_var(match):
            var_name = match.group(1)
            return str(variables.get(var_name, ''))

        result = re.sub(r'\{\{(\w+)\}\}', replace_var, result)
        return result

    def _process_conditionals(self, template: str, variables: Dict[str, Any]) -> str:
        result = template
        max_iterations = 100
        iteration = 0

        while iteration < max_iterations:
            iteration += 1
            if_start = -1
            if_end = -1
            var_name = None
            depth = 0

            i = 0
            while i < len(result):
                if result[i:i+5] == '{{#if':
                    if depth == 0:
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

            content_start = result.find('}}', if_start) + 2
            content = result[content_start:if_end-7]

            if self._var_exists(var_name, variables):
                processed_content = self._process_conditionals(content, variables)
                result = result[:if_start] + processed_content + result[if_end:]
            else:
                result = result[:if_start] + result[if_end:]

        return result

    def _var_exists(self, var_name: str, variables: Dict[str, Any]) -> bool:
        if var_name not in variables:
            return False
        value = variables[var_name]
        if isinstance(value, bool):
            return value
        if isinstance(value, str):
            return bool(value)
        return bool(value)


# ============================================================
# Test Data for Each Output Type
# ============================================================

def get_common_variables() -> Dict[str, Any]:
    """Common variables for all output types"""
    return {
        'title': 'テスト作品',
        'author': 'テスト作者',
        'color_mode': 'fullcolor',
        'output_style': 'anime',
        'aspect_ratio': '16:9',
        'is_duotone': False,
        'title_overlay_enabled': False,
    }


def get_face_sheet_variables() -> Dict[str, Any]:
    """Variables for face_sheet"""
    vars = get_common_variables()
    vars.update({
        'type': 'character_design',
        'aspect_ratio': '1:1',
        'character_name': 'テストキャラ',
        'character_description': 'テスト用キャラクターの説明',
        'expression': 'neutral expression',
        'reference_image_path': 'test_face_reference.png',
        'style_info_style': '日本のアニメスタイル, 2Dセルシェーディング',
        'style_info_proportions': 'Normal head-to-body ratio (6-7 heads)',
        'style_info_description': 'High quality anime illustration',
    })
    return vars


def get_body_sheet_variables() -> Dict[str, Any]:
    """Variables for body_sheet"""
    vars = get_common_variables()
    vars.update({
        'type': 'body_reference_sheet',
        'aspect_ratio': '16:9',
        'character_name': 'テストキャラ',
        'character_description': 'テスト用キャラクターの説明',
        'face_sheet_path': 'face_reference.png',
        'body_type': 'slim',
        'bust_description': 'medium',
        'expression_type': 'neutral',
        'style_info_style': '日本のアニメスタイル, 2Dセルシェーディング',
        'style_info_proportions': 'Normal head-to-body ratio (6-7 heads)',
        'style_info_description': 'High quality anime illustration',
    })
    return vars


def get_outfit_preset_variables() -> Dict[str, Any]:
    """Variables for outfit_sheet preset mode"""
    vars = get_common_variables()
    vars.update({
        'type': 'outfit_reference_sheet',
        'body_sheet_path': 'body_reference.png',
        'outfit_category': 'casual',
        'outfit_shape': 'T-shirt and jeans',
        'outfit_color': 'blue',
        'outfit_pattern': 'solid',
        'outfit_impression': 'casual and relaxed',
    })
    return vars


def get_outfit_reference_variables() -> Dict[str, Any]:
    """Variables for outfit_sheet reference mode"""
    vars = get_common_variables()
    vars.update({
        'type': 'outfit_reference_sheet',
        'body_sheet_path': 'body_reference.png',
        'outfit_image_path': 'outfit_reference.png',
        'fit_mode': 'exact',
        'include_headwear': 'true',
    })
    return vars


def get_pose_preset_variables() -> Dict[str, Any]:
    """Variables for pose preset mode"""
    vars = get_common_variables()
    vars.update({
        'type': 'pose_illustration',
        'outfit_sheet_path': 'outfit_reference.png',
        'pose_preset': 'standing',
        'camera_angle': 'front',
        'background_description': 'simple gradient background',
        'lighting': 'natural daylight',
    })
    return vars


def get_pose_reference_variables() -> Dict[str, Any]:
    """Variables for pose reference mode"""
    vars = get_common_variables()
    vars.update({
        'type': 'pose_illustration',
        'outfit_sheet_path': 'outfit_reference.png',
        'pose_image_path': 'pose_reference.png',
        'background_description': 'simple gradient background',
        'lighting': 'natural daylight',
    })
    return vars


def get_background_variables() -> Dict[str, Any]:
    """Variables for background generation"""
    vars = get_common_variables()
    vars.update({
        'type': 'background_generation',
        'background_description': 'A serene forest clearing with sunlight filtering through the trees',
    })
    return vars


def get_four_panel_variables() -> Dict[str, Any]:
    """Variables for four panel manga"""
    vars = get_common_variables()
    vars.update({
        'type': 'four_panel_manga',
    })
    return vars


def get_style_transform_variables() -> Dict[str, Any]:
    """Variables for style transform"""
    vars = get_common_variables()
    vars.update({
        'type': 'style_transform',
        'source_image_path': 'source_character.png',
        'target_style': 'chibi',
        'style_prompt': 'Convert to cute chibi style with big head and small body',
        'output_background': 'white background',
    })
    return vars


def get_infographic_variables() -> Dict[str, Any]:
    """Variables for infographic"""
    vars = get_common_variables()
    vars.update({
        'type': 'infographic',
        'infographic_type': 'character_profile',
        'style_prompt': 'Modern magazine style infographic',
        'output_language': 'Japanese',
        'main_title': 'キャラクタープロファイル',
        'subtitle': 'Character Information',
        'character_image_path': 'character.png',
        'bonus_character_enabled': False,
    })
    return vars


# Map output type to variable function
VARIABLE_FUNCTIONS = {
    'face_sheet': get_face_sheet_variables,
    'body_sheet': get_body_sheet_variables,
    'outfit_preset': get_outfit_preset_variables,
    'outfit_reference': get_outfit_reference_variables,
    'pose_preset': get_pose_preset_variables,
    'pose_reference': get_pose_reference_variables,
    'background': get_background_variables,
    'four_panel': get_four_panel_variables,
    'style_transform': get_style_transform_variables,
    'infographic': get_infographic_variables,
}


# ============================================================
# YAML Generator
# ============================================================

class YAMLGenerator:
    """Generate YAML from templates"""

    def __init__(self):
        self.parser = TemplateParser()
        self.renderer = TemplateRenderer()
        self.master_template = None
        self.selection_map = None

    def load_templates(self):
        """Load template files"""
        with open(MASTER_TEMPLATE_PATH, 'r', encoding='utf-8') as f:
            self.master_template = f.read()
        with open(SELECTION_MAP_PATH, 'r', encoding='utf-8') as f:
            self.selection_map = f.read()

    def generate(self, output_type_key: str, selection_key: str, variables: Dict[str, Any]) -> str:
        """Generate YAML for given output type"""
        if not self.master_template or not self.selection_map:
            self.load_templates()

        # Get output type from SelectionMap's output_type_key
        template_output_type = self.parser.extract_output_type_key(self.selection_map, selection_key)
        if not template_output_type:
            # Fallback to selection_key itself
            template_output_type = selection_key

        # Get header values
        header_values = self.parser.extract_header_values(self.master_template, template_output_type)
        all_variables = {**variables, **header_values}

        # Get section list
        sections = self.parser.extract_section_list(self.selection_map, selection_key)

        # Generate YAML
        yaml_parts = []
        optional_sections = ['title_overlay', 'reference_image', 'bonus_character']

        for section_name in sections:
            template = self.parser.extract_section_template(
                self.master_template, template_output_type, section_name
            )
            if template is None:
                template = self.parser.extract_common_section_template(
                    self.master_template, section_name
                )

            if template:
                rendered = self.renderer.render(template, all_variables)
                if rendered.strip():
                    yaml_parts.append(rendered)
            elif section_name not in optional_sections:
                print(f"  Warning: Section '{section_name}' not found for {output_type_key}")

        return '\n'.join(yaml_parts)


# ============================================================
# Comparison Functions
# ============================================================

def compare_files(old_content: str, new_content: str) -> str:
    """Generate diff between old and new content"""
    old_lines = old_content.splitlines(keepends=True)
    new_lines = new_content.splitlines(keepends=True)

    diff = difflib.unified_diff(
        old_lines, new_lines,
        fromfile='旧版 (Legacy)',
        tofile='新版 (Template)',
        lineterm=''
    )
    return ''.join(diff)


def create_comparison_report(output_type: str, old_content: str, new_content: str) -> str:
    """Create a detailed comparison report"""
    lines = []
    lines.append(f"=" * 60)
    lines.append(f"Comparison: {output_type}")
    lines.append(f"=" * 60)

    old_lines = old_content.strip().split('\n')
    new_lines = new_content.strip().split('\n')

    lines.append(f"Old lines: {len(old_lines)}")
    lines.append(f"New lines: {len(new_lines)}")
    lines.append("")

    # Check for key differences
    old_set = set(l.strip() for l in old_lines if l.strip() and not l.strip().startswith('#'))
    new_set = set(l.strip() for l in new_lines if l.strip() and not l.strip().startswith('#'))

    only_in_old = old_set - new_set
    only_in_new = new_set - old_set

    if only_in_old:
        lines.append("Only in OLD (missing in new):")
        for item in sorted(only_in_old)[:10]:
            lines.append(f"  - {item[:80]}...")
        if len(only_in_old) > 10:
            lines.append(f"  ... and {len(only_in_old) - 10} more")
        lines.append("")

    if only_in_new:
        lines.append("Only in NEW (added):")
        for item in sorted(only_in_new)[:10]:
            lines.append(f"  + {item[:80]}...")
        if len(only_in_new) > 10:
            lines.append(f"  ... and {len(only_in_new) - 10} more")
        lines.append("")

    if not only_in_old and not only_in_new:
        lines.append("✓ Content is equivalent (ignoring whitespace and comments)")
    else:
        lines.append(f"Differences: {len(only_in_old)} removed, {len(only_in_new)} added")

    return '\n'.join(lines)


# ============================================================
# Main Functions
# ============================================================

def generate_all(types_to_generate: List[str] = None):
    """Generate YAML for all or specified output types"""
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    generator = YAMLGenerator()
    generator.load_templates()

    if types_to_generate is None:
        types_to_generate = list(OUTPUT_TYPES.keys())

    print(f"Template Engine Test - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)

    for type_key in types_to_generate:
        if type_key not in OUTPUT_TYPES:
            print(f"Unknown output type: {type_key}")
            continue

        config = OUTPUT_TYPES[type_key]
        print(f"\nGenerating: {config['description']} ({type_key})")

        # Get variables
        if type_key in VARIABLE_FUNCTIONS:
            variables = VARIABLE_FUNCTIONS[type_key]()
        else:
            variables = get_common_variables()

        # Generate YAML
        try:
            yaml_content = generator.generate(
                type_key,
                config['selection_key'],
                variables
            )

            # Save to file
            filename = f"{config['filename']}_template.yaml"
            filepath = os.path.join(OUTPUT_DIR, filename)
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(yaml_content)

            print(f"  ✓ Saved to {filepath}")
            print(f"    Lines: {len(yaml_content.split(chr(10)))}")

        except Exception as e:
            print(f"  ✗ Error: {e}")

    print("\n" + "=" * 60)
    print(f"Output directory: {OUTPUT_DIR}/")


def run_comparison():
    """Compare template output with legacy samples"""
    samples_dir = 'samples'
    template_dir = OUTPUT_DIR

    if not os.path.exists(samples_dir):
        print(f"Error: Samples directory '{samples_dir}' not found")
        return

    if not os.path.exists(template_dir):
        print("Generating template output first...")
        generate_all()

    print("\nComparison Report")
    print("=" * 60)

    # Map sample files to output types
    sample_mappings = {
        '01_face_sheet.yaml': '01_face_sheet_template.yaml',
        '02_body_sheet.yaml': '02_body_sheet_template.yaml',
        '03_outfit_sheet_preset.yaml': '03_outfit_preset_template.yaml',
    }

    report_lines = []

    for sample_file, template_file in sample_mappings.items():
        sample_path = os.path.join(samples_dir, sample_file)
        template_path = os.path.join(template_dir, template_file)

        if not os.path.exists(sample_path):
            print(f"  Sample not found: {sample_file}")
            continue

        if not os.path.exists(template_path):
            print(f"  Template output not found: {template_file}")
            continue

        with open(sample_path, 'r', encoding='utf-8') as f:
            old_content = f.read()
        with open(template_path, 'r', encoding='utf-8') as f:
            new_content = f.read()

        report = create_comparison_report(sample_file, old_content, new_content)
        print(report)
        report_lines.append(report)

        # Save diff
        diff = compare_files(old_content, new_content)
        if diff:
            diff_path = os.path.join(template_dir, f"diff_{sample_file.replace('.yaml', '.txt')}")
            with open(diff_path, 'w', encoding='utf-8') as f:
                f.write(diff)
            print(f"  Diff saved to: {diff_path}")

    # Save full report
    report_path = os.path.join(template_dir, 'comparison_report.txt')
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write(f"Comparison Report - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        f.write('\n\n'.join(report_lines))
    print(f"\nFull report saved to: {report_path}")


def main():
    """Main entry point"""
    args = sys.argv[1:]

    if '--compare' in args:
        run_comparison()
    elif '--help' in args or '-h' in args:
        print(__doc__)
    elif args:
        # Generate specific types
        types = []
        for arg in args:
            # Match partial names
            matches = [k for k in OUTPUT_TYPES.keys() if arg.lower() in k.lower()]
            types.extend(matches)
        if types:
            generate_all(types)
        else:
            print(f"No matching output types found for: {args}")
            print(f"Available types: {', '.join(OUTPUT_TYPES.keys())}")
    else:
        generate_all()


if __name__ == '__main__':
    main()
