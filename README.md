Softhid 
========

This project is a "soft HID" USB cable.   It has two micro USB ports.   One port acts like a USB keyboard (and hopefully mouse in the future).  
The other port is a usb serial port.   You can control the keyboard and mouse by sending commands to the serial port.

Parts
-----

* [Teensy 3.1](https://www.pjrc.com/store/teensy31.html)
* [CP2104 Friend](https://www.adafruit.com/product/3309)

Wiring
------

Hook up ground and RX/TX on the friend to TX1/RX1 (ie pins 1 and 0) on the teensy.

Software
-------

Teensy firmware:  see `softhid.ino`

Keyboard side: it should show up as a normal USB keyboard, no extra software required

Serial side: I've just been using GNU screen. (`screen /dev/cu.usbserial-021397D0 115200`) I'm planning on adding a desktop program that can capture keyboard and mouse input.






