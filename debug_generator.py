#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Swift版ジェネレーターをPythonで再現するデバッグスクリプト
全出力タイプの全モードをダミーデータで生成し、debugPythonフォルダに出力
"""

import os
from datetime import datetime

OUTPUT_DIR = "debugPython"

# ============================================================
# 共通ユーティリティ
# ============================================================

def escape_yaml(s: str) -> str:
    """YAML文字列エスケープ"""
    return s.replace('\\', '\\\\').replace('"', '\\"')

def convert_newlines_to_comma(s: str) -> str:
    """改行をカンマ区切りに変換"""
    lines = [line.strip() for line in s.split('\n') if line.strip()]
    return escape_yaml(', '.join(lines))

def generate_author_line(author: str) -> str:
    """作者名行を生成"""
    if not author.strip():
        return ""
    return f'\nauthor: "{escape_yaml(author)}"'

def generate_title_overlay(title: str, author: str, enabled: bool = True) -> str:
    """タイトルオーバーレイを生成"""
    if not enabled or not title:
        return ""

    if not author:
        return f'''

title_overlay:
  enabled: true
  text: "{escape_yaml(title)}"
  position: "top-center"'''

    return f'''

title_overlay:
  enabled: true
  title:
    text: "{escape_yaml(title)}"
    position: "top-left"
    size: "large"
  author:
    text: "{escape_yaml(author)}"
    position: "top-right"
    size: "small"'''

# ============================================================
# 01. 顔三面図
# ============================================================

def generate_face_sheet() -> str:
    """顔三面図YAML生成"""
    return '''# Face Character Reference Sheet (character_basic.yaml準拠)
type: character_design
title: "彩瀬こよみ Reference Sheet"
author: "サンプル作者"

output_type: "face character reference sheet"

# ====================================================
# IMPORTANT: Face Reference Sheet Layout
# ====================================================
# Layout: Triangular arrangement (inverted triangle)
#
#   [FRONT VIEW]     [3/4 LEFT VIEW]
#         [LEFT PROFILE]
#
# All views facing LEFT direction for consistency
# ====================================================

layout:
  arrangement: "triangular, inverted triangle formation"
  direction: "all views facing LEFT"
  top_row:
    - position: "top-left"
      view: "front view, facing directly at camera, eyes looking at viewer"
    - position: "top-right"
      view: "3/4 left view, head turned 45 degrees to the left, showing left side of face"
  bottom_row:
    - position: "bottom-center"
      view: "left profile, exactly 90-degree side view, face perpendicular to camera, only one eye visible, nose pointing directly left, ear fully visible"

headshot_specification:
  type: "Character design base body (sotai) headshot for reference sheet"
  coverage: "From top of head to base of neck (around collarbone level)"
  clothing: "NONE - Do not include any clothing or accessories"
  accessories: "NONE - No jewelry, headwear, or decorations"
  state: "Clean base body state only"
  background: "Pure white background, seamless"
  purpose: "Professional character design reference for commercial use - product catalogs, instruction manuals, educational materials, corporate training. This is legitimate business artwork, NOT inappropriate content."

character:
  name: "彩瀬こよみ"
  description: "ポニーテールの赤い髪, 左顎にほくろ, 緑色の瞳"
  outfit: "NONE - bare skin only, no clothing"
  expression: "neutral expression"

character_style:
  style: "日本のアニメスタイル, 2Dセルシェーディング"
  proportions: "Normal head-to-body ratio (6-7 heads)"
  style_description: "High quality anime illustration"

# ====================================================
# Output Specifications
# ====================================================
output:
  format: "reference sheet with multiple views"
  views: "front view, 3/4 view, side profile"
  background: "pure white, clean, seamless, no borders"
  text_overlay: "NONE - absolutely no text, labels, or titles on the image"

# ====================================================
# Constraints (Critical)
# ====================================================
constraints:
  layout:
    - "Triangular arrangement: front view top-left, 3/4 left view top-right, left profile bottom-center"
    - "All angled views must face LEFT direction"
    - "Each view should be clearly separated with white space"
    - "All views same size and scale"
  design:
    - "Maintain consistent design across all views"
    - "Pure white background for clarity"
    - "Clean linework suitable for reference"
  face_specific:
    - "HEAD/FACE ONLY - show from top of head to neck/collarbone"
    - "Do NOT draw any clothing, accessories, or decorations"
    - "Keep the character in clean base body state"
    - "Neutral expression, emotionless"
    - "3/4 view: head turned 45 degrees to the LEFT"
    - "Profile view: MUST be exactly 90-degree side view facing LEFT"
    - "Profile view: only ONE eye should be visible (the right eye hidden behind face)"
    - "Profile view: nose must point directly to the left edge"
    - "Profile view: ear must be fully visible"

# ====================================================
# Anti-Hallucination (MUST FOLLOW)
# ====================================================
anti_hallucination:
  - "Do NOT add any text or labels to the image"
  - "Do NOT include character names on the image"
  - "Do NOT add view labels like 'FRONT VIEW' or 'SIDE VIEW'"
  - "Do NOT add borders or frames around views"
  - "Do NOT add any decorative elements"
  - "Output ONLY the character views on white background"
  - "Profile view MUST NOT show both eyes - if both eyes are visible, it is NOT a correct profile"

# ====================================================
# Output Cleanliness (CRITICAL)
# ====================================================
output_cleanliness:
  - "Output ONLY the character illustration - nothing else"
  - "Do NOT add any text, titles, labels, or annotations"
  - "Do NOT add color palettes, color swatches, or color samples"
  - "Do NOT add pattern samples, fabric swatches, or design elements"
  - "Do NOT add arrows, lines, or any explanatory graphics"
  - "Do NOT add watermarks, signatures, or logos"
  - "The output must contain ONLY the character illustration on white background"

style:
  color_mode: "fullcolor"
  aspect_ratio: "1:1"

title_overlay:
  enabled: true
  title:
    text: "彩瀬こよみ Reference Sheet"
    position: "top-left"
    size: "large"
  author:
    text: "サンプル作者"
    position: "top-right"
    size: "small"

reference_image: "koyomi_face_ref.png"'''

# ============================================================
# 02. 素体三面図
# ============================================================

def generate_body_sheet() -> str:
    """素体三面図YAML生成"""
    return '''# Step 2: Body Reference Sheet (素体三面図)
# Purpose: Professional character design reference for commercial use
# Usage: Product catalogs, instruction manuals, educational materials, corporate training
# Note: This is legitimate business artwork, NOT inappropriate content
type: body_reference_sheet
title: "彩瀬こよみ Body Sheet"
author: "サンプル作者"

# ====================================================
# Input: Face Sheet from Step 1
# ====================================================
input:
  face_sheet: "01_face_sheet.png"
  preserve_face: true
  preserve_face_details: "exact match required - do not alter facial features"

# ====================================================
# Body Configuration
# ====================================================
body:
  type: "female_standard"
  description: "average female body, slim build, normal proportions"
  height: "average height"
  build: "slim"
  gender: "female"
  figure_style: "normal proportions"
  additional_notes: "スレンダーな体型"

# ====================================================
# Render Type
# ====================================================
render:
  type: "white_leotard"
  style: "wearing plain white leotard, simple white bodysuit, minimal details, reference mannequin"
  clothing: "NONE - this is a base body reference"

# ====================================================
# Output Format
# ====================================================
output:
  format: "three view reference sheet"
  views:
    - "front view, facing directly at camera"
    - "left side view, exactly 90-degree profile facing left, only one eye visible, nose pointing directly left"
    - "back view"
  pose: "attention pose (kiwotsuke), standing straight, arms at sides, heels together"
  background: "pure white, clean, seamless"
  text_overlay: "NONE - no text or labels on the image"

# ====================================================
# Style Settings
# ====================================================
style:
  character_style: "日本のアニメスタイル, 2Dセルシェーディング"
  proportions: "Normal head-to-body ratio (6-7 heads)"
  color_mode: "fullcolor"
  aspect_ratio: "16:9"

# ====================================================
# Constraints (Critical)
# ====================================================
constraints:
  layout:
    - "STRICT horizontal arrangement: LEFT=front view, CENTER=left side view, RIGHT=back view"
    - "Side view MUST show LEFT side of body (character facing left)"
    - "Side view MUST be exactly 90-degree profile - only ONE eye visible"
    - "Side view: nose must point directly to the left edge, ear fully visible"
    - "POSITION ORDER IS CRITICAL: Front on LEFT, Side in CENTER, Back on RIGHT"
    - "Each view should be clearly separated with white space"
  face_preservation:
    - "MUST use exact face from input face_sheet"
    - "Do NOT alter facial features, expression, or proportions"
    - "Maintain exact hair style and color from reference"
  body_generation:
    - "Generate body matching the specified body type"
    - "Do NOT add any clothing or accessories beyond specified render type"
    - "Maintain anatomically correct proportions"
  pose:
    - "Attention pose (kiwotsuke): standing straight with arms at sides"
    - "Heels together, toes slightly apart"
    - "Arms relaxed at sides, palms facing inward"
    - "Do NOT use T-pose or A-pose"
  consistency:
    - "All three views must show the same character in same pose"
    - "Maintain consistent proportions across views"
    - "Use clean linework suitable for reference"

anti_hallucination:
  - "Do NOT add clothing that was not specified"
  - "Do NOT change the face from the reference"
  - "Do NOT add accessories or decorations"
  - "Do NOT change body proportions from specified type"
  - "Do NOT add any text or labels to the image"
  - "Do NOT use T-pose or A-pose - use attention pose only"
  - "Do NOT change the view order - ALWAYS front/side/back from left to right"
  - "Side view MUST NOT show both eyes - if both eyes are visible, it is NOT a correct 90-degree profile"

# ====================================================
# Output Cleanliness (CRITICAL)
# ====================================================
output_cleanliness:
  - "Output ONLY the character illustration - nothing else"
  - "Do NOT add any text, titles, labels, or annotations"
  - "Do NOT add color palettes, color swatches, or color samples"
  - "Do NOT add pattern samples, fabric swatches, or design elements"
  - "Do NOT add arrows, lines, or any explanatory graphics"
  - "Do NOT add watermarks, signatures, or logos"
  - "The output must contain ONLY the three-view character illustration on white background"

title_overlay:
  enabled: true
  title:
    text: "彩瀬こよみ Body Sheet"
    position: "top-left"
    size: "large"
  author:
    text: "サンプル作者"
    position: "top-right"
    size: "small"'''

# ============================================================
# 03. 衣装着用（プリセットモード）
# ============================================================

def generate_outfit_preset() -> str:
    """衣装着用（プリセット）YAML生成"""
    return '''# Step 3: Outfit Application (衣装着用)
# Purpose: Professional character design reference for commercial use
# Usage: Product catalogs, instruction manuals, educational materials, corporate training
# Note: This is legitimate business artwork, NOT inappropriate content
type: outfit_reference_sheet
title: "彩瀬こよみ セーラー服"
author: "サンプル作者"

# ====================================================
# Input: Body Sheet from Step 2
# ====================================================
input:
  body_sheet: "02_body_sheet.png"
  preserve_body: true
  preserve_face: true
  preserve_details: "exact match required - do not alter face or body shape"

# ====================================================
# Outfit Configuration
# ====================================================
outfit:
  category: "制服"
  shape: "セーラー服"
  color: "紺"
  pattern: "無地"
  style_impression: "清楚"
  prompt: "navy blue, solid color, plain, sailor uniform, elegant, modest"
  additional_notes: "夏服バージョン"

# ====================================================
# Output Format
# ====================================================
output:
  format: "three view reference sheet"
  views:
    - "front view, facing directly at camera"
    - "left side view, exactly 90-degree profile facing left, only one eye visible, nose pointing directly left"
    - "back view"
  pose: "attention pose (kiwotsuke), same as body sheet"
  background: "pure white, clean, seamless"
  text_overlay: "NONE - no text or labels on the image"

# ====================================================
# Style Settings
# ====================================================
style:
  character_style: "日本のアニメスタイル, 2Dセルシェーディング"
  proportions: "Normal head-to-body ratio (6-7 heads)"
  color_mode: "fullcolor"
  aspect_ratio: "16:9"

# ====================================================
# Constraints (Critical)
# ====================================================
constraints:
  layout:
    - "STRICT horizontal arrangement: LEFT=front view, CENTER=left side view, RIGHT=back view"
    - "Side view MUST show LEFT side of body (character facing left)"
    - "Side view MUST be exactly 90-degree profile - only ONE eye visible"
    - "Side view: nose must point directly to the left edge, ear fully visible"
    - "POSITION ORDER IS CRITICAL: Front on LEFT, Side in CENTER, Back on RIGHT"
    - "Each view should be clearly separated with white space"
  face_preservation:
    - "MUST use exact face from input body_sheet"
    - "Do NOT alter facial features, expression, or proportions"
    - "Maintain exact hair style and color from reference"
  body_preservation:
    - "MUST use exact body shape from input body_sheet"
    - "Do NOT alter body proportions or pose"
    - "Body should be visible through/under clothing naturally"
  outfit_application:
    - "Apply specified outfit to the body"
    - "Maintain clothing consistency across all three views"
    - "Show realistic fabric draping and fit"
  consistency:
    - "All three views must show the same character in same outfit"
    - "Maintain consistent proportions across views"
    - "Use clean linework suitable for reference"

anti_hallucination:
  - "Do NOT change the face from the body sheet reference"
  - "Do NOT alter body proportions"
  - "Do NOT add accessories not specified in outfit"
  - "Do NOT change hair style or color"
  - "Apply ONLY the specified outfit"
  - "Do NOT change the view order - ALWAYS front/side/back from left to right"
  - "Side view MUST NOT show both eyes - if both eyes are visible, it is NOT a correct 90-degree profile"

# ====================================================
# Output Cleanliness (CRITICAL)
# ====================================================
output_cleanliness:
  - "Output ONLY the character illustration - nothing else"
  - "Do NOT add any text, titles, labels, or annotations"
  - "Do NOT add color palettes, color swatches, or color samples"
  - "Do NOT add pattern samples, fabric swatches, or design elements"
  - "Do NOT add arrows, lines, or any explanatory graphics"
  - "Do NOT add watermarks, signatures, or logos"
  - "The output must contain ONLY the three-view character illustration on white background"

title_overlay:
  enabled: true
  title:
    text: "彩瀬こよみ セーラー服"
    position: "top-left"
    size: "large"
  author:
    text: "サンプル作者"
    position: "top-right"
    size: "small"'''

# ============================================================
# 03. 衣装着用（参考画像モード）
# ============================================================

def generate_outfit_reference() -> str:
    """衣装着用（参考画像）YAML生成"""
    return '''# Step 3: Outfit Application from Reference Image (参考画像から衣装着用)
# Purpose: Professional character design reference for commercial use
# Usage: Product catalogs, instruction manuals, educational materials, corporate training
# Note: This is legitimate business artwork, NOT inappropriate content
# IMPORTANT: User is responsible for copyright compliance of reference images
type: outfit_reference_from_image
title: "彩瀬こよみ アーマー衣装"
author: "サンプル作者"

# ====================================================
# Input Images
# ====================================================
input:
  body_sheet: "02_body_sheet.png"
  outfit_reference: "armor_reference.png"
  fit_mode: "base_priority (素体優先)"

# ====================================================
# Outfit from Reference Image
# ====================================================
outfit:
  source: "reference_image"
  instruction: "Extract and apply the outfit/clothing from the outfit_reference image to the character in body_sheet"
  fit_mode: "base_priority"
  description: "フルアーマー, メカニカルデザイン"
  additional_notes: "肩パッドは大きめに"

# ====================================================
# Output Format
# ====================================================
output:
  format: "three view reference sheet"
  views:
    - "front view, facing directly at camera"
    - "left side view, exactly 90-degree profile facing left, only one eye visible, nose pointing directly left"
    - "back view"
  pose: "attention pose (kiwotsuke), same as body sheet"
  background: "pure white, clean, seamless"
  text_overlay: "NONE - no text or labels on the image"

# ====================================================
# Style Settings
# ====================================================
style:
  character_style: "日本のアニメスタイル, 2Dセルシェーディング"
  proportions: "Normal head-to-body ratio (6-7 heads)"
  color_mode: "fullcolor"
  aspect_ratio: "16:9"

# ====================================================
# Constraints (Critical) - Fit Mode: base_priority (素体優先)
# ====================================================
constraints:
  layout:
    - "STRICT horizontal arrangement: LEFT=front view, CENTER=left side view, RIGHT=back view"
    - "Side view MUST show LEFT side of body (character facing left)"
    - "Side view MUST be exactly 90-degree profile - only ONE eye visible"
    - "Side view: nose must point directly to the left edge, ear fully visible"
    - "POSITION ORDER IS CRITICAL: Front on LEFT, Side in CENTER, Back on RIGHT"
    - "Each view should be clearly separated with white space"
  face_preservation:
    - "MUST use exact face from input body_sheet"
    - "Do NOT alter facial features, expression, or proportions"
    - "Maintain exact hair style and color from body_sheet reference"
  body_preservation:
    - "MUST use exact body shape from input body_sheet"
    - "Do NOT alter body proportions or pose"
    - "Body should be visible through/under clothing naturally"
  pose_preservation:
    - "MUST use the POSE from body_sheet (attention pose / kiwotsuke)"
    - "Do NOT copy the pose from outfit_reference image"
    - "Extract ONLY the clothing design, IGNORE the pose in reference"
  headwear:
    - "Include headwear (hats, helmets, etc.) from outfit_reference if present"
  outfit_extraction:
    - "Extract ONLY the clothing/outfit from the outfit_reference image"
    - "Do NOT copy the face or body from outfit_reference"
    - "Adapt the outfit to fit the body_sheet character's body shape"
    - "Maintain the style, color, and design of the reference outfit"
  consistency:
    - "All three views must show the same character in same outfit"
    - "Maintain consistent proportions across views"
    - "Use clean linework suitable for reference"

anti_hallucination:
  - "Do NOT use face or body from outfit_reference image"
  - "Do NOT copy the POSE from outfit_reference - use body_sheet pose only"
  - "Do NOT alter body proportions from body_sheet"
  - "Do NOT add accessories not visible in outfit_reference"
  - "Do NOT change hair style or color from body_sheet"
  - "Apply ONLY the outfit visible in outfit_reference image"
  - "Include headwear from outfit_reference - hats, helmets, caps should be applied"
  - "Do NOT change the view order - ALWAYS front/side/back from left to right"
  - "Side view MUST NOT show both eyes - if both eyes are visible, it is NOT a correct 90-degree profile"

# ====================================================
# Output Cleanliness (CRITICAL)
# ====================================================
output_cleanliness:
  - "Output ONLY the character illustration - nothing else"
  - "Do NOT add any text, titles, labels, or annotations"
  - "Do NOT add color palettes, color swatches, or color samples"
  - "Do NOT add pattern samples, fabric swatches, or design elements"
  - "Do NOT add arrows, lines, or any explanatory graphics"
  - "Do NOT add watermarks, signatures, or logos"
  - "The output must contain ONLY the three-view character illustration on white background"

title_overlay:
  enabled: true
  title:
    text: "彩瀬こよみ アーマー衣装"
    position: "top-left"
    size: "large"
  author:
    text: "サンプル作者"
    position: "top-right"
    size: "small"'''

# ============================================================
# 04. ポーズ（プリセットモード）
# ============================================================

def generate_pose_preset() -> str:
    """ポーズ（プリセット）YAML生成"""
    return '''# Step 4: Pose Image (ポーズ画像)
# Purpose: Generate character in specified pose based on outfit sheet
# Output: Single character image
# Preset: 立ちポーズ（自然）
type: pose_single
title: "彩瀬こよみ 立ちポーズ"
author: "サンプル作者"

# ====================================================
# Input Image
# ====================================================
input:
  character_sheet: "03_outfit_sheet.png"
  identity_preservation: 1.0
  purpose: "Generate posed character from outfit sheet"

# ====================================================
# Pose Definition
# ====================================================
pose:
  description: "Natural standing pose, relaxed shoulders, one hand on hip"
  expression: "happy, smiling"
  eye_line: "カメラ目線"
  include_effects: true
  wind_effect: "gentle breeze, hair slightly flowing"

additional_details:
  - "Confident posture, approachable expression"

# ====================================================
# Output Settings
# ====================================================
output:
  format: "single_image"
  background: "transparent, fully clear alpha channel"

# ====================================================
# CRITICAL CONSTRAINTS
# ====================================================
constraints:
  character_preservation:
    - "Preserve exact character design, face, and colors from input image"
    - "Maintain clothing details exactly as shown in input"
  output_format:
    - "Single character image, full body visible"

anti_hallucination:
  - "Do NOT alter character design from input"
  - "Do NOT add extra figures"

# ====================================================
# Output Cleanliness (CRITICAL)
# ====================================================
output_cleanliness:
  - "Output ONLY the character illustration - nothing else"
  - "Do NOT add any text, titles, labels, or annotations"
  - "Do NOT add color palettes, color swatches, or color samples"
  - "Do NOT add pattern samples, fabric swatches, or design elements"
  - "Do NOT add arrows, lines, or any explanatory graphics"
  - "Do NOT add watermarks, signatures, or logos"
  - "The output must contain ONLY the single character on the specified background"

style:
  color_mode: "fullcolor"
  output_style: "anime"
  aspect_ratio: "9:16"

title_overlay:
  enabled: true
  title:
    text: "彩瀬こよみ 立ちポーズ"
    position: "top-left"
    size: "large"
  author:
    text: "サンプル作者"
    position: "top-right"
    size: "small"'''

# ============================================================
# 04. ポーズ（キャプチャモード）
# ============================================================

def generate_pose_capture() -> str:
    """ポーズ（キャプチャ）YAML生成"""
    return '''# Step 4: Pose Image (ポーズ画像)
# Purpose: Generate character in specified pose based on outfit sheet
# Output: Single character image
type: pose_single
title: "彩瀬こよみ ダイナミックポーズ"
author: "サンプル作者"

# ====================================================
# Input Image
# ====================================================
input:
  character_sheet: "03_outfit_sheet.png"
  identity_preservation: 1.0
  purpose: "Generate posed character from outfit sheet"

# ====================================================
# Pose Capture (ポーズキャプチャ)
# ====================================================
pose_capture:
  enabled: true
  reference_image: "action_pose_ref.png"
  capture_target: "pose_only"
  instruction: |
    Capture ONLY the pose (body position, arm/leg positions, gestures) from the reference image.
    Apply this pose to the character while preserving:
    - Character's face and facial features from character_sheet
    - Character's outfit and clothing from character_sheet
    - Character's colors and design from character_sheet
    Do NOT transfer any appearance elements from the reference image.

pose:
  source: "captured from reference image"
  expression: "excited, smiling"
  eye_line: "カメラ目線"
  include_effects: true
  wind_effect: "strong breeze, hair flowing dynamically"

# ====================================================
# Output Settings
# ====================================================
output:
  format: "single_image"
  background: "transparent, fully clear alpha channel"

# ====================================================
# CRITICAL CONSTRAINTS
# ====================================================
constraints:
  character_preservation:
    - "Preserve exact character design, face, and colors from input image"
    - "Maintain clothing details exactly as shown in input"
  output_format:
    - "Single character image, full body visible"

anti_hallucination:
  - "Do NOT alter character design from input"
  - "Do NOT add extra figures"

# ====================================================
# Output Cleanliness (CRITICAL)
# ====================================================
output_cleanliness:
  - "Output ONLY the character illustration - nothing else"
  - "Do NOT add any text, titles, labels, or annotations"
  - "Do NOT add color palettes, color swatches, or color samples"
  - "Do NOT add pattern samples, fabric swatches, or design elements"
  - "Do NOT add arrows, lines, or any explanatory graphics"
  - "Do NOT add watermarks, signatures, or logos"
  - "The output must contain ONLY the single character on the specified background"

style:
  color_mode: "fullcolor"
  output_style: "anime"
  aspect_ratio: "9:16"

title_overlay:
  enabled: true
  title:
    text: "彩瀬こよみ ダイナミックポーズ"
    position: "top-left"
    size: "large"
  author:
    text: "サンプル作者"
    position: "top-right"
    size: "small"'''

# ============================================================
# 05. シーンビルダー（ストーリー）
# ============================================================

def generate_scene_story() -> str:
    """シーンビルダー（ストーリー）YAML生成"""
    return '''# Story Scene Composition (story_scene_composite.yaml準拠)
# Purpose: Combine characters and background into a story scene
# Note: Battle Scene and Boss Raid will be implemented later
type: story_scene_composition

background:
  source_image: "classroom_bg.png"
  blur_amount: 20
  lighting_mood: "Warm Afternoon"

scene_interaction:
  layout_type: "Side by Side"
  distance: "Close"

character_1:
  source_image: "koyomi_pose.png"
  position: "Leftmost"
  scale: 1.0
  expression_override: "Smiling"
  physical_traits: "ポニーテールの赤髪"

character_2:
  source_image: "sakura_pose.png"
  position: "Right of Character 1"
  scale: 1.0
  expression_override: "Laughing"
  physical_traits: "黒髪ショート"

comic_overlay:
  enabled: true
  style: "Slice of Life / Visual Novel"
  narration_box:
    text: "放課後の教室で、二人は楽しそうに話していた。"
    position: "Top Left"
  dialogues:
    - speaker: "Character 1 (Leftmost)"
      text: "今日の放課後、カフェに行かない？"
      shape: "Round (Normal)"
    - speaker: "Character 2 (Right of 1)"
      text: "いいね！新しくできたお店に行ってみよう！"
      shape: "Round (Normal)"

post_processing:
  filter: "Soft Anime Look"
  bloom_effect: "Low"

style:
  color_mode: "fullcolor"
  output_style: "anime"
  aspect_ratio: "16:9"'''

# ============================================================
# 06. 背景生成（参考画像あり）
# ============================================================

def generate_background_capture() -> str:
    """背景生成（参考画像あり）YAML生成"""
    return '''# Background Capture (背景キャプチャ)
title: "教室の背景"
author: "サンプル作者"

output_type: "background_capture"

# ====================================================
# Background Capture Settings
# ====================================================
background_capture:
  enabled: true
  reference_image: "photo_classroom.jpg"
  transform_instruction: "Convert to anime/illustration style, clean lines, vibrant colors"
  aspect_ratio: "16:9"
  aspect_ratio_instruction: "Output aspect ratio: 16:9"

  remove_people:
    enabled: true
    instruction: "Remove all people/humans from the image. Fill the removed areas naturally with background elements."

# ====================================================
# CRITICAL CONSTRAINTS
# ====================================================
constraints:
  - "Use the reference image as the base for the background"
  - "Apply the transformation instruction to modify the style/atmosphere"
  - "Do NOT include any characters or people in the output"
  - "Maintain the general composition and layout from the reference"
  - "Output aspect ratio: 16:9"

style:
  color_mode: "fullcolor"
  output_style: "anime"
  aspect_ratio: "16:9"

# ====================================================
# Output Cleanliness (CRITICAL)
# ====================================================
output_cleanliness:
  - "Output ONLY the background illustration - nothing else"
  - "Do NOT add any text, titles, labels, or annotations"
  - "Do NOT add color palettes or color samples"
  - "Do NOT add location markers, arrows, or explanatory graphics"
  - "Do NOT add watermarks, signatures, or logos"
  - "The output must contain ONLY the background scene"

title_overlay:
  enabled: true
  title:
    text: "教室の背景"
    position: "top-left"
    size: "large"
  author:
    text: "サンプル作者"
    position: "top-right"
    size: "small"'''

# ============================================================
# 06. 背景生成（テキストのみ）
# ============================================================

def generate_background_text() -> str:
    """背景生成（テキストのみ）YAML生成"""
    return '''# Background Generation
title: "夕暮れの草原"
author: "サンプル作者"

output_type: "background only"

background:
  description: "夕暮れ時の広大な草原, オレンジ色の空, 遠くに山が見える, 風になびく草, 幻想的な雰囲気"

style:
  color_mode: "fullcolor"
  output_style: "anime"
  aspect_ratio: "16:9"

# ====================================================
# Output Cleanliness (CRITICAL)
# ====================================================
output_cleanliness:
  - "Output ONLY the background illustration - nothing else"
  - "Do NOT add any text, titles, labels, or annotations"
  - "Do NOT add color palettes or color samples"
  - "Do NOT add location markers, arrows, or explanatory graphics"
  - "Do NOT add watermarks, signatures, or logos"
  - "The output must contain ONLY the background scene"

title_overlay:
  enabled: true
  title:
    text: "夕暮れの草原"
    position: "top-left"
    size: "large"
  author:
    text: "サンプル作者"
    position: "top-right"
    size: "small"'''

# ============================================================
# 07. 装飾テキスト（技名テロップ）
# ============================================================

def generate_decorative_skill() -> str:
    """装飾テキスト（技名テロップ）YAML生成"""
    return '''# Decorative Text (ui_text_overlay.yaml準拠)
type: text_ui_layer_definition

ui_global_style:
  preset: "Anime Battle"
  font_language: "Japanese"

special_move_title:
  enabled: true
  text: "必殺・桜吹雪斬り"

  style:
    font_type: "Heavy Mincho"
    size: "Very Large"
    fill_color: "White to Blue Gradient"
    outline:
      enabled: true
      color: "Gold"
      thickness: "Thick"
    glow_effect: "Blue Lightning"
    drop_shadow: "Hard Drop"

output:
  background: "Transparent"

style:
  color_mode: "fullcolor"
  output_style: "anime"
  aspect_ratio: "16:9"'''

# ============================================================
# 07. 装飾テキスト（決め台詞）
# ============================================================

def generate_decorative_catchphrase() -> str:
    """装飾テキスト（決め台詞）YAML生成"""
    return '''# Decorative Text (ui_text_overlay.yaml準拠)
type: text_ui_layer_definition

ui_global_style:
  preset: "Anime Battle"
  font_language: "Japanese"

impact_callout:
  enabled: true
  text: "正義は必ず勝つ！"

  style:
    type: "Comic Sound Effect"
    color: "Red with Yellow Border"
    rotation: "-5 degrees"
    distortion: "Zoom In"

output:
  background: "Transparent"

style:
  color_mode: "fullcolor"
  output_style: "anime"
  aspect_ratio: "16:9"'''

# ============================================================
# 07. 装飾テキスト（キャラ名プレート）
# ============================================================

def generate_decorative_nameplate() -> str:
    """装飾テキスト（キャラ名プレート）YAML生成"""
    return '''# Decorative Text (ui_text_overlay.yaml準拠)
type: text_ui_layer_definition

ui_global_style:
  preset: "Character Name Plate"
  font_language: "Japanese"

name_tag:
  enabled: true
  text: "彩瀬こよみ"

  style:
    type: "Jagged Sticker"
    rotation: "5 degrees"

constraints:
  - "Generate ONLY the name plate/tag element"
  - "Do NOT add any game UI elements (health bars, meters, VS logos)"
  - "Do NOT add any fighting game or battle interface elements"

output:
  background: "Transparent"

style:
  color_mode: "fullcolor"
  output_style: "anime"
  aspect_ratio: "16:9"'''

# ============================================================
# 07. 装飾テキスト（メッセージウィンドウ）
# ============================================================

def generate_decorative_message() -> str:
    """装飾テキスト（メッセージウィンドウ）YAML生成"""
    return '''# Message Window - Full (ui_text_overlay.yaml準拠)
type: text_ui_layer_definition

ui_global_style:
  preset: "Message Window"
  font_language: "Japanese"

message_window:
  enabled: true
  mode: "full"
  speaker_name: "彩瀬こよみ"
  text: "やっほー！今日も元気にいこう！"
  style_preset: "Visual Novel"

  design:
    position: "Bottom Center"
    width: "90%"
    frame_type: "Translucent White"
    background_opacity: 0.8

    face_icon:
      enabled: true
      source_image: "Reference: koyomi_face.png (use head/neck portion as face icon)"
      position: "Left Inside"
      crop_area: "Head and neck only (from top of head to base of neck)"

constraints:
  - "Generate ONLY the message window UI element"
  - "Do NOT draw any full-body character in the scene"
  - "Do NOT include any character outside the message window"
  - "The reference image is ONLY for the face icon, not for adding a character to the scene"

output:
  background: "Transparent"

style:
  color_mode: "fullcolor"
  output_style: "anime"
  aspect_ratio: "16:9"'''

# ============================================================
# 08. 4コマ漫画
# ============================================================

def generate_four_panel() -> str:
    """4コマ漫画YAML生成"""
    return '''【画像生成指示 / Image Generation Instructions】
以下のYAML指示に従って、4コマ漫画を1枚の画像として生成してください。
添付したキャラクター設定画を参考に、キャラクターの外見を一貫させてください。

Generate a 4-panel manga as a single image following the YAML instructions below.
Use the attached character reference sheets to maintain consistent character appearances.

---

# 4コマ漫画生成 (four_panel_manga.yaml準拠)
title: "放課後の出来事"
author: "サンプル作者"
color_mode: "fullcolor"
output_style: "manga"

# 登場人物
characters:
  - name: "彩瀬こよみ"
    reference: "添付画像1（koyomi_ref.png）を参照してください"
    description: "ポニーテールの赤い髪, 緑色の瞳, 元気な性格"

  - name: "桜井さくら"
    reference: "添付画像2（sakura_ref.png）を参照してください"
    description: "黒髪ショート, 青い瞳, おっとりした性格"

# 4コマの内容
panels:
  # --- 1コマ目（起）---
  - panel_number: 1
    prompt: "教室で机に座っている二人, 窓から夕日が差し込む"
    speeches:
      - character: "彩瀬こよみ"
        content: "ねえねえ、今日の放課後さ..."
        position: "left"
    narration: "放課後の教室"

  # --- 2コマ目（承）---
  - panel_number: 2
    prompt: "こよみが立ち上がって提案している, さくらは座ったまま聞いている"
    speeches:
      - character: "彩瀬こよみ"
        content: "新しくできたカフェに行かない？"
        position: "left"
      - character: "桜井さくら"
        content: "カフェ...？"
        position: "right"

  # --- 3コマ目（転）---
  - panel_number: 3
    prompt: "さくらが目を輝かせている, 背景にキラキラエフェクト"
    speeches:
      - character: "桜井さくら"
        content: "パンケーキが美味しいって噂の！？"
        position: "right"

  # --- 4コマ目（結）---
  - panel_number: 4
    prompt: "二人で笑顔で手を取り合っている"
    speeches:
      - character: "彩瀬こよみ"
        content: "さすがさくら、話が早い！"
        position: "left"
      - character: "桜井さくら"
        content: "早く行こう！"
        position: "right"

# レイアウト指示
layout_instruction: |
  4コマ漫画を縦1列に配置してください。
  横並びにせず、上から下へ1コマずつ縦に4つ並べてください。
  出力画像は縦長（9:16または2:5の比率）で、4コマ漫画だけが画像全体を占めるようにしてください。
  余白は不要です。
  各キャラクターの外見は添付画像と説明を忠実に再現してください。
  セリフは吹き出しで表示し、指定された位置に配置してください。
  ナレーションがある場合は、コマの上部または下部にテキストボックスで表示してください。

title_overlay:
  enabled: true
  title:
    text: "放課後の出来事"
    position: "top-left"
    size: "large"
  author:
    text: "サンプル作者"
    position: "top-right"
    size: "small"'''

# ============================================================
# 09. スタイル変換（ちびキャラ）
# ============================================================

def generate_style_chibi() -> str:
    """スタイル変換（ちびキャラ）YAML生成"""
    return '''# Style Transform: Chibi Conversion (スタイル変換: ちびキャラ化)
# Transform realistic/normal character to chibi (super-deformed) style
# The source image can be from any stage (base/outfit/pose)
type: style_transform_chibi
title: "彩瀬こよみ ちびキャラ"
author: "サンプル作者"

# ====================================================
# Input Image (Source Character)
# ====================================================
input:
  source_image: "koyomi_pose.png"
  source_stage: "any (base body / with outfit / with pose)"

# ====================================================
# Transform Settings
# ====================================================
transform:
  type: "chibi"
  style: "2頭身"
  style_prompt: "chibi, super deformed, 2 head tall, very large head, tiny body, cute"
  head_ratio: "2 heads tall"

# ====================================================
# Preservation Settings
# ====================================================
preserve:
  elements: "outfit and clothing, pose and action"
  face_features: "Maintain character's face identity (eyes, hair color, expression)"
  outfit_details: true
  pose_action: true

# ====================================================
# Output Settings
# ====================================================
output:
  style: "chibi / super-deformed"
  aspect_ratio: "1:1"
  background: "transparent"
  quality: "clean linework, cute proportions"

# ====================================================
# Constraints (Critical)
# ====================================================
constraints:
  chibi_rules:
    - "Transform to chibi style with 2 heads tall head-to-body ratio"
    - "Large head, small body, simplified features"
    - "Maintain character identity (face, hair, colors)"
    - "Keep the cuteness and appeal of chibi style"
  preservation_rules:
    - "Preserve: outfit and clothing, pose and action"
    - "Maintain the same outfit design (simplified for chibi proportions)"
    - "Keep the same pose action (adapted for chibi body)"
  style_consistency:
    - "Use consistent chibi proportions throughout"
    - "Clean, cute linework suitable for chibi style"
    - "Transparent background for easy compositing"

anti_hallucination:
  - "Do NOT change character's identity (face, hair color)"
  - "Do NOT add new accessories not in source"
  - "Do NOT change outfit design significantly"
  - "MAINTAIN chibi proportions consistently"

# ====================================================
# Output Cleanliness (CRITICAL)
# ====================================================
output_cleanliness:
  - "Output ONLY the chibi character illustration - nothing else"
  - "Do NOT add any text, titles, labels, or annotations"
  - "Do NOT add color palettes, color swatches, or color samples"
  - "Do NOT add size comparison charts or reference guides"
  - "Do NOT add arrows, lines, or any explanatory graphics"
  - "Do NOT add watermarks, signatures, or logos"
  - "The output must contain ONLY the chibi character on the specified background"

title_overlay:
  enabled: true
  title:
    text: "彩瀬こよみ ちびキャラ"
    position: "top-left"
    size: "large"
  author:
    text: "サンプル作者"
    position: "top-right"
    size: "small"'''

# ============================================================
# 09. スタイル変換（ドット絵）
# ============================================================

def generate_style_pixel() -> str:
    """スタイル変換（ドット絵）YAML生成"""
    return '''# Style Transform: Pixel Art Conversion (スタイル変換: ドットキャラ化)
# Transform character to pixel art / sprite style
# The source image can be from any stage (base/outfit/pose)
type: style_transform_pixel
title: "彩瀬こよみ ドット絵"
author: "サンプル作者"

# ====================================================
# Input Image (Source Character)
# ====================================================
input:
  source_image: "koyomi_pose.png"
  source_stage: "any (base body / with outfit / with pose)"

# ====================================================
# Transform Settings
# ====================================================
transform:
  type: "pixel_art"
  style: "16bit風"
  style_prompt: "16-bit pixel art, SNES/Genesis era game sprite, medium detail, classic gaming aesthetic"
  resolution: "Medium (64-128px)"
  color_depth: "32-64 colors"

# ====================================================
# Sprite Settings
# ====================================================
sprite:
  size: "中サイズ (64px)"
  size_prompt: "Medium size pixel sprite (around 64 pixels), standard character sprite"
  preserve_colors: true
  transparent_background: true

# ====================================================
# Output Settings
# ====================================================
output:
  style: "pixel art sprite"
  aspect_ratio: "1:1"
  background: "transparent"
  quality: "clean pixels, game sprite aesthetic"

# ====================================================
# Constraints (Critical)
# ====================================================
constraints:
  pixel_art_rules:
    - "Convert to 16bit風 pixel art style"
    - "Use 中サイズ (64px) sprite size"
    - "Clean, sharp pixels with no anti-aliasing blur"
    - "Limited color palette appropriate for 16bit風"
  preservation_rules:
    - "Maintain character identity (recognizable silhouette)"
    - "Keep the same outfit and pose from source"
    - "Reference original colors from source image"
  style_consistency:
    - "Consistent pixel size throughout the sprite"
    - "Game sprite aesthetic, suitable for game use"
    - "Transparent background for easy compositing"

anti_hallucination:
  - "Do NOT add pixel art artifacts or noise"
  - "Do NOT blur or anti-alias the pixels"
  - "MAINTAIN consistent pixel grid"
  - "Do NOT change character's recognizable features"

# ====================================================
# Output Cleanliness (CRITICAL)
# ====================================================
output_cleanliness:
  - "Output ONLY the pixel art character sprite - nothing else"
  - "Do NOT add any text, titles, labels, or annotations"
  - "Do NOT add color palettes, color swatches, or color samples"
  - "Do NOT add size comparison charts or pixel grid guides"
  - "Do NOT add arrows, lines, or any explanatory graphics"
  - "Do NOT add watermarks, signatures, or logos"
  - "The output must contain ONLY the pixel art sprite on the specified background"

title_overlay:
  enabled: true
  title:
    text: "彩瀬こよみ ドット絵"
    position: "top-left"
    size: "large"
  author:
    text: "サンプル作者"
    position: "top-right"
    size: "small"'''

# ============================================================
# 10. インフォグラフィック
# ============================================================

def generate_infographic() -> str:
    """インフォグラフィックYAML生成"""
    return '''# Infographic Generation (インフォグラフィック)
# Style: グラフィックレコーディング風
type: infographic
title: "彩瀬こよみ キャラクター紹介"
author: "サンプル作者"

# ====================================================
# Style Settings
# ====================================================
style:
  type: "graphic_recording"
  style_prompt: "graphic recording style, hand-drawn look, colorful markers, visual notes, icons and illustrations, whiteboard aesthetic"
  aspect_ratio: "16:9"
  output_language: "Japanese"

# ====================================================
# Title Configuration
# ====================================================
titles:
  main_title: "彩瀬こよみ キャラクター紹介"
  subtitle: "元気いっぱいの高校生"

# ====================================================
# Main Character Image
# ====================================================
main_character:
  image: "koyomi_pose.png"
  position: "center"
  instruction: "Place this character image at the center of the infographic"

# ====================================================
# Bonus Character Image
# ====================================================
bonus_character:
  enabled: true
  image: "koyomi_chibi.png"
  placement: "AI decides optimal placement"
  instruction: "Place this bonus character (e.g., chibi version) somewhere in the infographic as a decorative element"

# ====================================================
# Information Sections
# ====================================================
# Layout reference:
#   [1] [2] [3]
#   [4] CHAR [5]
#   [6] [7] [8]
sections:
  - section_1:
      title: "基本情報"
      content: "名前: 彩瀬こよみ, 年齢: 17歳, 身長: 158cm"

  - section_2:
      title: "性格"
      content: "明るく元気, 好奇心旺盛, 友達思い"

  - section_3:
      title: "好きなもの"
      content: "パンケーキ, カフェ巡り, 写真撮影"

  - section_4:
      title: "苦手なもの"
      content: "早起き, 虫, ホラー映画"

  - section_5:
      title: "特技"
      content: "料理, イラスト, カラオケ"

  - section_6:
      title: "夢"
      content: "イラストレーターになること"

# ====================================================
# Generation Instructions
# ====================================================
prompt: |
  Create a detailed infographic about this person/character in graphic_recording style.
  Use the attached character image as the central figure.
  Include extremely detailed information - small text is acceptable if it adds more detail.

  Style: graphic recording style, hand-drawn look, colorful markers, visual notes, icons and illustrations, whiteboard aesthetic

  Main title: "彩瀬こよみ キャラクター紹介"
  Subtitle: "元気いっぱいの高校生"

  Include these sections around the character:
  - 基本情報: 名前: 彩瀬こよみ, 年齢: 17歳, 身長: 158cm
  - 性格: 明るく元気, 好奇心旺盛, 友達思い
  - 好きなもの: パンケーキ, カフェ巡り, 写真撮影
  - 苦手なもの: 早起き, 虫, ホラー映画
  - 特技: 料理, イラスト, カラオケ
  - 夢: イラストレーターになること

  Output language: Japanese

  IMPORTANT:
  - Create related icons and decorations automatically based on the content
  - Use the graphic_recording visual style consistently
  - Make it visually engaging with colors, icons, and artistic elements
  - Include as much detail as possible in small organized sections

# ====================================================
# Constraints
# ====================================================
constraints:
  - "Use the provided character image as the main central figure"
  - "Arrange information sections around the character"
  - "Create appropriate icons and decorations based on content (AI decides)"
  - "Output all text in Japanese"
  - "Maintain graphic_recording style throughout"
  - "Aspect ratio: 16:9"

anti_hallucination:
  - "Do NOT change the character's appearance from the provided image"
  - "Do NOT omit any of the specified sections"
  - "Do NOT add unrelated information not in the sections"

title_overlay:
  enabled: true
  title:
    text: "彩瀬こよみ キャラクター紹介"
    position: "top-left"
    size: "large"
  author:
    text: "サンプル作者"
    position: "top-right"
    size: "small"'''

# ============================================================
# メイン処理
# ============================================================

def main():
    """メイン処理"""
    # 出力ディレクトリ作成
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print(f"Debug Generator - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)
    print()

    # 全出力タイプと生成関数のマッピング
    generators = [
        ("01_face_sheet.yaml", "顔三面図", generate_face_sheet),
        ("02_body_sheet.yaml", "素体三面図", generate_body_sheet),
        ("03_outfit_preset.yaml", "衣装着用（プリセット）", generate_outfit_preset),
        ("03_outfit_reference.yaml", "衣装着用（参考画像）", generate_outfit_reference),
        ("04_pose_preset.yaml", "ポーズ（プリセット）", generate_pose_preset),
        ("04_pose_capture.yaml", "ポーズ（キャプチャ）", generate_pose_capture),
        ("05_scene_story.yaml", "シーンビルダー（ストーリー）", generate_scene_story),
        ("06_background_capture.yaml", "背景生成（参考画像）", generate_background_capture),
        ("06_background_text.yaml", "背景生成（テキスト）", generate_background_text),
        ("07_decorative_skill.yaml", "装飾テキスト（技名）", generate_decorative_skill),
        ("07_decorative_catchphrase.yaml", "装飾テキスト（決め台詞）", generate_decorative_catchphrase),
        ("07_decorative_nameplate.yaml", "装飾テキスト（キャラ名）", generate_decorative_nameplate),
        ("07_decorative_message.yaml", "装飾テキスト（メッセージ）", generate_decorative_message),
        ("08_four_panel.yaml", "4コマ漫画", generate_four_panel),
        ("09_style_chibi.yaml", "スタイル変換（ちび）", generate_style_chibi),
        ("09_style_pixel.yaml", "スタイル変換（ドット絵）", generate_style_pixel),
        ("10_infographic.yaml", "インフォグラフィック", generate_infographic),
    ]

    # 各ファイルを生成
    for filename, label, generator in generators:
        filepath = os.path.join(OUTPUT_DIR, filename)
        content = generator()

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

        line_count = len(content.split('\n'))
        print(f"  ✓ {label}")
        print(f"    → {filepath} ({line_count} lines)")

    print()
    print("=" * 60)
    print(f"Output directory: {OUTPUT_DIR}/")
    print(f"Total files: {len(generators)}")

if __name__ == "__main__":
    main()
