// Copyright (C) 2022 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/LICENSE file.

/**
Tests the wakeup functionality of the touch pad.

Setup:
Optionally connect a jumper wire to pin 2.
Do the same for pin 4.

Start the program, and let the device go into deep sleep.
Touch pin 4. The device should *not* wake up, as the pin was closed.
Touch pin 2. The device should wake up again.
*/

import gpio
import gpio.touch as gpio
import esp32

TOUCH_PIN1 ::= 2
TOUCH_PIN2 ::= 4

calibrate touch/gpio.Touch:
  CALIBRATION_ITERATIONS ::= 16

  sum := 0
  CALIBRATION_ITERATIONS.repeat:
    sum += touch.read --raw
  touch.threshold = sum * 2 / (3 * CALIBRATION_ITERATIONS)

main:
  if esp32.wakeup_cause == esp32.WAKEUP_TOUCHPAD:
    print "Woken up from touchpad"
    print esp32.touchpad_wakeup_status
  else:
    touch1 := gpio.Touch (gpio.Pin TOUCH_PIN1)
    calibrate touch1
    print "pin $TOUCH_PIN1: $touch1.threshold $(touch1.read --raw)"

    touch2 := gpio.Touch (gpio.Pin TOUCH_PIN2)
    calibrate touch2
    print "pin $TOUCH_PIN2: $touch2.threshold $(touch2.read --raw)"

    print "waiting for touch on pin $TOUCH_PIN1"
    while not touch1.get: sleep --ms=1

    print "waiting for touch on pin $TOUCH_PIN2"
    while not touch2.get: sleep --ms=1

    touch2.close

    print "going into deep sleep"
    sleep --ms=500
    print "ESP32 should not wake up from pin $TOUCH_PIN2, but should wake up from pin $TOUCH_PIN1"
    esp32.enable_touchpad_wakeup
    esp32.deep_sleep (Duration --s=10)
