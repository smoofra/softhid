#!/usr/bin/env python3

# Build a table to translate carbon keycodes to teensy keycodes

import re

teensy_header = '/Applications/Teensyduino.app/Contents/Java/hardware/teensy/avr/cores/teensy3/keylayouts.h'
carbon_header = '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Events.h'

def match(r,s):
    return re.match(r.replace(" ", r"\s+"), s)

def norm(name):
    return name.upper().replace("_", "")

carbon_names = dict()
with open(carbon_header, 'r', encoding='latin-1') as f:
    for line in f:
        if m := re.search(r'kVK_(ANSI_)?(\w+)', line):
            ansi, name = m.groups()
            carbon_names[norm(name)] = ("ANSI_" if ansi else "") + name

carbon_names['ENTER'] = 'Return'
carbon_names['ESC'] = 'Escape'
carbon_names['LEFTBRACE'] = 'ANSI_LeftBracket'
carbon_names['RIGHTBRACE'] = 'ANSI_RightBracket'
carbon_names['RIGHT'] = 'RightArrow'
carbon_names['LEFT'] = 'LeftArrow'
carbon_names['UP'] = 'UpArrow'
carbon_names['DOWN'] = 'DownArrow'

skip = {'NON_US_NUM', 'NON_US_BS', 'TILDE', "PRINTSCREEN", "SCROLL_LOCK",
        "PAUSE", "INSERT", "NUM_LOCK", "MENU", "BACKSPACE"}

skip |= {f"F{i}" for i in range(13, 100)}

seen = set()
modifiers = list()
with open(teensy_header, 'r') as f, open("app/table.swift", "w") as o:
    o.write("import Carbon.HIToolbox.Events\n\n")
    o.write("let carbon_keycode_to_teensy = [\n");
    for line in f:
        if m := match(r"#define MODIFIERKEY_(\w+) \( (0x[a-fA-F0-9]+) \| 0xE000 \) $", line):
            modifiers.append(m)
        if m := match(r"#define KEY_(\w+) \( (\d+) \| 0xF000 \) $", line):
            (name, code) = m.groups()
            if name in skip:
                continue
            if norm(name) not in carbon_names:
                raise Exception(f"{name} not found")
            name = carbon_names[norm(name)]
            if name in seen:
                raise Exception(f"dup of {name}")
            seen.add(name)
            o.write(f'    kVK_{name}: {code} | 0xF000,\n')
    o.write("]\n\n\n")
    for m in modifiers:
        (name, code) = m.groups()
        o.write(f'let teensy_{name} = {code} | 0xE000\n')
