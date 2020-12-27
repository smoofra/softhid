
// Build with Teensyduino: https://www.pjrc.com/teensy/teensyduino.html

// Set "Tools > USB Type" to "keyboard + mouse + joystick"

void setup() {
  Serial1.setRX(0);
  Serial1.setTX(1);
  Serial1.begin(115200);
}

enum Direction {
  undefined = 0,
  up = 1,
  down = 2
};

enum State {
  normal = 0,
  escape,
  vt100,
  rawkey,
};

void loop() {
  static long last_hello = 0;
  long now = millis();
  if (now - last_hello > 3000) {
    last_hello = now;
    Serial1.printf("Softhid 1\r\n");
  }

  static State state = normal;
  static int keycode = 0;
  static Direction direction = undefined;

  while (Serial1.available()) {
    uint8_t byte = Serial1.read();

    if (byte > 32 && byte < 128) {
      Serial1.printf("recv 0x%x <%c>\r\n", (int)byte, byte);
    } else {
      Serial1.printf("recv 0x%x\r\n", (int)byte);
    }


    switch(state) {

      case normal:
      if (byte == 3) {
        Keyboard.set_modifier(MODIFIERKEY_CTRL);
        Keyboard.press(KEY_C);
        Keyboard.release(KEY_C);
        Keyboard.set_modifier(0);
      }
      else if  (byte == '\e') {
        state = escape;
      } else if (byte == '\r') {
        Keyboard.write('\n');
      } else if (byte >= 32 || byte == '\t') {
        // normal character or utf8
        Keyboard.write(byte);
      } else {
        Serial1.printf("what?\r\n");
      }
      break;

      case escape:
      switch(byte) {
        case '[':
        state = vt100;
        break;

        case '{':
        state = rawkey;
        break;

        default:
        Serial1.printf("what?\r\n");
        state = normal;
        break;
      }
      break;

      case vt100:
      switch(byte) {
        case 'A':
          Keyboard.press(KEY_UP);
          Keyboard.release(KEY_UP);
          break;
        case 'B':
          Keyboard.press(KEY_DOWN);
          Keyboard.release(KEY_DOWN);
          break;
        case 'D':
          Keyboard.press(KEY_LEFT);
          Keyboard.release(KEY_LEFT);
          break;
        case 'C':
          Keyboard.press(KEY_RIGHT);
          Keyboard.release(KEY_RIGHT);
          break;
        default:
        Serial1.printf("what?\r\n");
        break;
      }
      state = normal;
      break;

      case rawkey:
      if (byte >= '0' && byte <= '9') {
        uint8_t digit = byte - '0';
        keycode = keycode * 10 + digit;
      }
      if (byte == 'u') {
        direction = up;
      }
      if (byte == 'd') {
        direction = down;
      }
      if (byte == ';') {
        if (keycode == 0 || direction == 0) {
          Serial1.printf("huh?\r\n");
        } else {
          if (direction == up) {
            Keyboard.press(keycode);
          } else {
            Keyboard.release(keycode);
          }
          state = normal;
          keycode = 0;
          direction = undefined;
        }
      }
      break;
    }
  }
}
