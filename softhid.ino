
// Build with Teensyduino: https://www.pjrc.com/teensy/teensyduino.html

// Set "Tools > USB Type" to "keyboard + mouse + joystick"

void setup() {
  Serial1.setRX(0);
  Serial1.setTX(1);
  Serial1.begin(115200);
}

enum Direction {
  up = 1,
  down = 2
};

void loop() {
  static long last_hello = 0;
  long now = millis();
  if (now - last_hello > 3000) {
    last_hello = now;
    Serial1.printf("Softhid 1\r\n");
  }

  static bool escape = false;
  static int keycode = 0;
  static Direction direction = 0;

  while (Serial1.available()) {
    uint8_t byte = Serial1.read();
    if (escape) {
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

          escape = false;
          keycode = 0;
          direction =0;
        }
      }
    } else if (byte == '\r') {
      Keyboard.write('\n');
    } else if (byte >= 32 && byte < 128 || byte == '\t') {
      // normal character
      Keyboard.write(byte);
    } else {
      Serial1.printf("what?\r\n");
    }
  }
}
