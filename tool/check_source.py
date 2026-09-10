#!/usr/bin/env python3
"""Offline structural checks, NOT a substitute for dart analyze or compilation."""
from pathlib import Path
import json, re, sys

ROOT = Path(__file__).resolve().parents[1]

class DartStructure:
    def __init__(self, source, path):
        self.s, self.path = source, path
    def fail(self, offset, message):
        line = self.s.count('\n', 0, offset) + 1
        raise ValueError(f'{self.path}:{line}: {message}')
    def string(self, i, raw=False):
        s = self.s
        quote = s[i]
        triple = s.startswith(quote * 3, i)
        delimiter = quote * (3 if triple else 1)
        start = i
        i += len(delimiter)
        while i < len(s):
            if s.startswith(delimiter, i): return i + len(delimiter)
            if not raw and s[i] == '\\': i += 2; continue
            if not raw and s.startswith('${', i): i = self.code(i + 2, interpolation=True); continue
            if not triple and s[i] == '\n': self.fail(start, 'newline in a single-line string')
            i += 1
        self.fail(start, 'unterminated string')
    def code(self, i=0, interpolation=False):
        s = self.s; stack = []
        pairs = {')': '(', ']': '[', '}': '{'}
        while i < len(s):
            if s.startswith('//', i):
                end = s.find('\n', i); i = len(s) if end < 0 else end + 1; continue
            if s.startswith('/*', i):
                level=1; start=i; i+=2
                while i < len(s) and level:
                    if s.startswith('/*', i): level+=1; i+=2
                    elif s.startswith('*/', i): level-=1; i+=2
                    else: i+=1
                if level: self.fail(start,'unterminated comment')
                continue
            char = s[i]
            if char in "'\"":
                raw = i > 0 and s[i-1] == 'r' and (i < 2 or not (s[i-2].isalnum() or s[i-2]=='_'))
                i = self.string(i, raw=raw); continue
            if char in '([{': stack.append((char, i))
            elif char in ')]}':
                if interpolation and not stack and char == '}': return i + 1
                if not stack or stack[-1][0] != pairs[char]: self.fail(i, f'unmatched {char}')
                stack.pop()
            i += 1
        if stack: self.fail(stack[-1][1], f'unclosed {stack[-1][0]}')
        if interpolation: self.fail(i-1, 'unclosed string interpolation')
        return i

errors=[]; count=0
for folder in ['lib', 'test', 'integration_test', 'tool']:
    for file in (ROOT/folder).rglob('*.dart'):
        count += 1
        text=file.read_text()
        try: DartStructure(text,str(file.relative_to(ROOT))).code()
        except ValueError as error: errors.append(str(error))
        for uri in re.findall(r"(?:import|export|part)\s+['\"]([^'\"]+)['\"]",text):
            if uri.startswith('dart:'): continue
            if uri.startswith('package:recipe_app/'):
                target=ROOT/'lib'/uri.removeprefix('package:recipe_app/')
            elif uri.startswith('package:'): continue
            else: target=file.parent/uri
            if not target.exists(): errors.append(f'{file.relative_to(ROOT)}: missing import {uri}')
for file in ROOT.rglob('*.json'):
    try: json.loads(file.read_text())
    except (ValueError,UnicodeError) as error: errors.append(f'{file}: invalid JSON {error}')
recipes=json.loads((ROOT/'assets/data/recipes.json').read_text())
for recipe in recipes:
    if not (ROOT/recipe['imageAsset']).is_file(): errors.append(f'Missing image for {recipe["id"]}')
if errors:
    print('\n'.join(errors)); sys.exit(1)
print(f'Structural checks passed for {count} Dart files: balanced delimiters/strings and resolvable local imports.')
print(f'JSON syntax and {len(recipes)} recipe image references passed.')
print('These checks do NOT verify Dart types, Flutter compilation, rendering, or runtime behavior.')
