import Carbon.HIToolbox.Events

let carbon_keycode_to_teensy = [
    kVK_ANSI_A: 4 | 0xF000,
    kVK_ANSI_B: 5 | 0xF000,
    kVK_ANSI_C: 6 | 0xF000,
    kVK_ANSI_D: 7 | 0xF000,
    kVK_ANSI_E: 8 | 0xF000,
    kVK_ANSI_F: 9 | 0xF000,
    kVK_ANSI_G: 10 | 0xF000,
    kVK_ANSI_H: 11 | 0xF000,
    kVK_ANSI_I: 12 | 0xF000,
    kVK_ANSI_J: 13 | 0xF000,
    kVK_ANSI_K: 14 | 0xF000,
    kVK_ANSI_L: 15 | 0xF000,
    kVK_ANSI_M: 16 | 0xF000,
    kVK_ANSI_N: 17 | 0xF000,
    kVK_ANSI_O: 18 | 0xF000,
    kVK_ANSI_P: 19 | 0xF000,
    kVK_ANSI_Q: 20 | 0xF000,
    kVK_ANSI_R: 21 | 0xF000,
    kVK_ANSI_S: 22 | 0xF000,
    kVK_ANSI_T: 23 | 0xF000,
    kVK_ANSI_U: 24 | 0xF000,
    kVK_ANSI_V: 25 | 0xF000,
    kVK_ANSI_W: 26 | 0xF000,
    kVK_ANSI_X: 27 | 0xF000,
    kVK_ANSI_Y: 28 | 0xF000,
    kVK_ANSI_Z: 29 | 0xF000,
    kVK_ANSI_1: 30 | 0xF000,
    kVK_ANSI_2: 31 | 0xF000,
    kVK_ANSI_3: 32 | 0xF000,
    kVK_ANSI_4: 33 | 0xF000,
    kVK_ANSI_5: 34 | 0xF000,
    kVK_ANSI_6: 35 | 0xF000,
    kVK_ANSI_7: 36 | 0xF000,
    kVK_ANSI_8: 37 | 0xF000,
    kVK_ANSI_9: 38 | 0xF000,
    kVK_ANSI_0: 39 | 0xF000,
    kVK_Return: 40 | 0xF000,
    kVK_Escape: 41 | 0xF000,
    kVK_Delete: 42 | 0xF000,
    kVK_Tab: 43 | 0xF000,
    kVK_Space: 44 | 0xF000,
    kVK_ANSI_Minus: 45 | 0xF000,
    kVK_ANSI_Equal: 46 | 0xF000,
    kVK_ANSI_LeftBracket: 47 | 0xF000,
    kVK_ANSI_RightBracket: 48 | 0xF000,
    kVK_ANSI_Backslash: 49 | 0xF000,
    kVK_ANSI_Semicolon: 51 | 0xF000,
    kVK_ANSI_Quote: 52 | 0xF000,
    kVK_ANSI_Comma: 54 | 0xF000,
    kVK_ANSI_Period: 55 | 0xF000,
    kVK_ANSI_Slash: 56 | 0xF000,
    kVK_CapsLock: 57 | 0xF000,
    kVK_F1: 58 | 0xF000,
    kVK_F2: 59 | 0xF000,
    kVK_F3: 60 | 0xF000,
    kVK_F4: 61 | 0xF000,
    kVK_F5: 62 | 0xF000,
    kVK_F6: 63 | 0xF000,
    kVK_F7: 64 | 0xF000,
    kVK_F8: 65 | 0xF000,
    kVK_F9: 66 | 0xF000,
    kVK_F10: 67 | 0xF000,
    kVK_F11: 68 | 0xF000,
    kVK_F12: 69 | 0xF000,
    kVK_Home: 74 | 0xF000,
    kVK_PageUp: 75 | 0xF000,
    kVK_ForwardDelete: 76 | 0xF000,
    kVK_End: 77 | 0xF000,
    kVK_PageDown: 78 | 0xF000,
    kVK_RightArrow: 79 | 0xF000,
    kVK_LeftArrow: 80 | 0xF000,
    kVK_DownArrow: 81 | 0xF000,
    kVK_UpArrow: 82 | 0xF000,
]


let teensy_CTRL = 0x01 | 0xE000
let teensy_SHIFT = 0x02 | 0xE000
let teensy_ALT = 0x04 | 0xE000
let teensy_GUI = 0x08 | 0xE000
let teensy_LEFT_CTRL = 0x01 | 0xE000
let teensy_LEFT_SHIFT = 0x02 | 0xE000
let teensy_LEFT_ALT = 0x04 | 0xE000
let teensy_LEFT_GUI = 0x08 | 0xE000
let teensy_RIGHT_CTRL = 0x10 | 0xE000
let teensy_RIGHT_SHIFT = 0x20 | 0xE000
let teensy_RIGHT_ALT = 0x40 | 0xE000
let teensy_RIGHT_GUI = 0x80 | 0xE000
