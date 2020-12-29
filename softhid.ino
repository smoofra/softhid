
// Build with Teensyduino: https://www.pjrc.com/teensy/teensyduino.html

// Set "Tools > USB Type" to "keyboard + mouse + joystick"

void setup() {
  Serial1.setRX(0);
  Serial1.setTX(1);
  Serial1.begin(115200);
  Keyboard.set_modifier(0);
}

enum State {
  normal = 0,
  escape,
  vt100,
  vt100_O,
  rawkey,
};

struct StateMachine {
  State state;
  int code;
};

void loop() {
  static long last_hello = 0;
  long now = millis();
  if (now - last_hello > 30000) {
    last_hello = now;
    Serial1.printf("Softhid 1\r\n");
  }

  static StateMachine m = {};

  while (Serial1.available()) {
    uint8_t byte = Serial1.read();

    if (byte > 32 && byte < 128) {
      Serial1.printf("recv 0x%x <%c>\r\n", (int)byte, byte);
    } else {
      Serial1.printf("recv 0x%x\r\n", (int)byte);
    }

    switch(m.state) {
      case normal:
      switch (byte) {
        case 0:
        Keyboard.set_modifier(MODIFIERKEY_CTRL);
        Keyboard.press(KEY_SPACE);
        Keyboard.release(KEY_SPACE);
        Keyboard.set_modifier(0);
        Keyboard.send_now();
        break;

        case 8:
        Keyboard.press(KEY_BACKSPACE);
        Keyboard.release(KEY_BACKSPACE);
        Keyboard.send_now();
        break;

        case 9: // ie \t
        Keyboard.press(KEY_TAB);
        Keyboard.release(KEY_TAB);
        Keyboard.send_now();
        break;

        case 10: // ie \n
        Keyboard.press(KEY_ENTER);
        Keyboard.release(KEY_ENTER);
        Keyboard.send_now();
        break;

        case  1: case 2:  case  3: case 4:  case  5: case 6:  case 7:
                          case 11: case 12: case 13: case 14: case 15: case 16:
        case 17: case 18: case 19: case 20: case 21: case 22: case 23: case 24:
        case 25: case 26:
        Keyboard.set_modifier(MODIFIERKEY_CTRL);
        Keyboard.press(KEY_A + byte - 1);
        Keyboard.release(KEY_A + byte - 1);
        Keyboard.set_modifier(0);
        Keyboard.send_now();
        break;

        case 27:
        m.state = escape;
        break;

        case 28:
        Keyboard.set_modifier(MODIFIERKEY_CTRL);
        Keyboard.press(KEY_BACKSLASH);
        Keyboard.release(KEY_BACKSLASH);
        Keyboard.set_modifier(0);
        Keyboard.send_now();
        break;

        case 29:
        Keyboard.set_modifier(MODIFIERKEY_CTRL);
        Keyboard.press(KEY_RIGHT_BRACE);
        Keyboard.release(KEY_RIGHT_BRACE);
        Keyboard.set_modifier(0);
        Keyboard.send_now();
        break;

        case 30:
        //lol why
        Keyboard.set_modifier(MODIFIERKEY_CTRL | MODIFIERKEY_SHIFT);
        Keyboard.press(KEY_6);
        Keyboard.release(KEY_SLASH);
        Keyboard.set_modifier(0);
        Keyboard.send_now();
       break;

        case 31:
        Keyboard.set_modifier(MODIFIERKEY_CTRL);
        Keyboard.press(KEY_SLASH);
        Keyboard.release(KEY_SLASH);
        Keyboard.set_modifier(0);
        Keyboard.send_now();
        break;

        default:
        if (byte < 127)  {
          // normal character
          Keyboard.write(byte);
          Keyboard.send_now();
        } else {
          Serial1.printf("what?\r\n");
        }
        break;

        case 127:
        Keyboard.press(KEY_BACKSPACE);
        Keyboard.release(KEY_BACKSPACE);
        Keyboard.send_now();
      }
      break;

      case escape:
      switch(byte) {
        case '[':
        m.state = vt100;
        break;

        case 'O':
        m.state = vt100_O;
        break;

        case '{':
        m.state = rawkey;
        break;

        default:
        if (byte >= 32 && byte < 127) {
          Keyboard.set_modifier(MODIFIERKEY_ALT);
          Keyboard.press(byte);
          Keyboard.release(byte);
          Keyboard.set_modifier(0);
          Keyboard.send_now();
      } else {
          Serial1.printf("what?\r\n");
        }
        m = {};
        break;
      }
      break;

      case vt100:
      switch(byte) {
        case '0': case '1': case '2': case '3': case '4':
        case '5': case '6': case '7': case '8': case '9':
        {
           int digit = byte - '0';
           m.code = m.code*10 + digit;
           break;
         }
        case '~':
           switch (m.code) {
             case 15:
             Keyboard.press(KEY_F5);
             Keyboard.release(KEY_F5);
             Keyboard.send_now();
             break;
             case 17:
             Keyboard.press(KEY_F6);
             Keyboard.release(KEY_F6);
             Keyboard.send_now();
             break;
             case 18:
             Keyboard.press(KEY_F7);
             Keyboard.release(KEY_F7);
             Keyboard.send_now();
             break;
             case 19:
             Keyboard.press(KEY_F8);
             Keyboard.release(KEY_F8);
             Keyboard.send_now();
             break;
             case 20:
             Keyboard.press(KEY_F9);
             Keyboard.release(KEY_F9);
             Keyboard.send_now();
             break;
             case 21:
             Keyboard.press(KEY_F10);
             Keyboard.release(KEY_F10);
             Keyboard.send_now();
             break;
             case 23:
             Keyboard.press(KEY_F11);
             Keyboard.release(KEY_F11);
             Keyboard.send_now();
             break;
             case 24:
             Keyboard.press(KEY_F12);
             Keyboard.release(KEY_F12);
             Keyboard.send_now();
             break;
             default:
             Serial1.printf("what?\r\n");
             break;
           }
          m = {};
          break;
        case 'A':
          Keyboard.press(KEY_UP);
          Keyboard.release(KEY_UP);
          Keyboard.send_now();
          m = {};
          break;
        case 'B':
          Keyboard.press(KEY_DOWN);
          Keyboard.release(KEY_DOWN);
          Keyboard.send_now();
          m = {};
          break;
        case 'D':
          Keyboard.press(KEY_LEFT);
          Keyboard.release(KEY_LEFT);
          Keyboard.send_now();
          m = {};
          break;
        case 'C':
          Keyboard.press(KEY_RIGHT);
          Keyboard.release(KEY_RIGHT);
          Keyboard.send_now();
          m = {};
          break;
        default:
        Serial1.printf("what?\r\n");
        m = {};
        break;
      }
      break;

      case vt100_O:
      switch(byte) {
        case 'P':
          Keyboard.press(KEY_F1);
          Keyboard.release(KEY_F1);
          Keyboard.send_now();
          break;
        case 'Q':
          Keyboard.press(KEY_F2);
          Keyboard.release(KEY_F2);
          Keyboard.send_now();
          break;
        case 'R':
          Keyboard.press(KEY_F3);
          Keyboard.release(KEY_F1);
          Keyboard.send_now();
          break;
        case 'S':
          Keyboard.press(KEY_F4);
          Keyboard.release(KEY_F4);
          Keyboard.send_now();
          break;
        default:
        Serial1.printf("what?\r\n");
        break;
      }
      m = {};
      break;

      case rawkey:
      switch (byte) {
        case '0': case '1': case '2': case '3': case '4':
        case '5': case '6': case '7': case '8': case '9': {
          uint8_t digit = byte - '0';
          m.code = m.code * 10 + digit;
          break;
        }
        case 'u':
          Keyboard.release(m.code);
          Keyboard.send_now();
          m = {};
          break;
        case 'd':
          Keyboard.press(m.code);
          Keyboard.send_now();
          m = {};
          break;
        default:
          Serial1.printf("huh?\r\n");
          m = {};
          break;
      }
      break;
    }
  }
}
