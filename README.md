# Sagemcom Button Presser

Parametric, non-destructive add-on for a Sagemcom-style water meter:
- 3D-printed frame that indexes on the housing
- solenoid cradle aligned to the blue button
- ESP32-CAM for reading the 7-segment display (planned/ongoing integration)

## Current Model
- Source of truth: `sagemcom_button_pusher_rig.scad`
- Main render modes:
  - `combined_preview`
  - `combined_printable`
  - `frame_only`
  - `cradle_only`
  - `solenoid_only`
  - `camera_holder_only`
  - `camera_preview`

## Known Mechanical Reference
- Meter housing: `58 x 92 mm` (corner radius estimated)
- Blue button center: `13.6 mm` from right side, `16 mm` from bottom
- Button stickout: approximately `2 mm`
- Solenoid body reference: `30 x 19 x 16 mm`
- Solenoid plunger: `6 mm` diameter, `12 mm` rest, `17 mm` extended
- ESP32-CAM board reference: `27.0 x 39.6 mm` (`W x H`)
- Camera optical center reference on board:
  - centered in `X`
  - `9.0 mm` below top edge (`Y`)

## Camera Placement
- Lens target point is the center of the LCD display reference.
- Camera distance is computed from FOV to capture full display with minimal extra:
  - `distance_w = (display_w/2)/tan(fov_h/2)`
  - `distance_h = (display_h/2)/tan(fov_v/2)`
  - `distance = max(distance_w, distance_h) + margin`
- Current defaults:
  - `camera_fov_h_deg = 62`
  - `camera_fov_v_deg = 48`
  - computed optical distance ≈ `36.4 mm`
- Because lens center is `9 mm` below board top, board center is placed
  `10.8 mm` below the lens target Y coordinate.

## Electrical Architecture (Current Plan)
Power:
- USB-C PD source + PD decoy set to `12V`
- `12V` rail feeds solenoid directly
- `12V -> buck converter -> 5V` to ESP32-CAM `5V` pin (preferred over raw 3.3V feed)

Confirmed solenoid electrical spec:
- Rated coil supply: `12V`
- Rated current: `650mA`
- Nominal electrical power: `~7.8W`

Solenoid drive:
- Low-side N-MOSFET switch
- Gate from ESP32-CAM GPIO through `100-220 ohm`
- `100k` gate pulldown to GND (boot-safe OFF)
- Flyback diode across solenoid coil:
  - diode cathode to `+12V`
  - diode anode to MOSFET drain/coil negative

Noise/reset protection:
- Shared GND with star-ground style routing (separate solenoid return path)
- Bulk + decoupling near ESP32 rail (example: `220-470uF` + `100nF`)
- Bulk cap near solenoid rail (example: `100-470uF`)
- Optional TVS on 12V rail for long/noisy wiring

## ESPHome Direction
- ESP32-CAM reads 7-segment display
- Solenoid activation should be pulse-based with safety guards:
  - short pulse widths
  - cooldown between pulses
  - fail-safe default OFF on boot/restart

Baseline ESPHome config:
- `esphome/sagemcom_presser.yaml`
- Includes ESP32-CAM stream setup and MOSFET-based solenoid pulse control with arming + cooldown gating.

## Action Plan So Far
Goal: automatically wake the meter display, detect a reading, and report water consumption in cubic meters.

Planned loop:
1. Every `10s`, check whether the meter display appears to be on.
2. One candidate detection method is to look for visible lit 7-segment digits in the camera image.
3. If light conditions are poor, turn on the ESP32-CAM onboard flash LED before the display check/read attempt.
4. If the display is not on, or the image is too uncertain to trust, trigger the solenoid to press the meter button.
5. Wait `10s` after a button press before checking again.
6. If a numeric reading is visible, report the raw displayed value as water consumption in cubic meters.
7. Publish the reading to Home Assistant and also log it locally.
8. If two consecutive wake/read attempts fail, expose an error state.
9. Turn the flash LED back off immediately after the image capture used for the check/read attempt.
10. Never actuate the solenoid for more than `1s`.
11. Wait `10s` and repeat.

Open implementation questions:
- How display-on detection should be made robust against glare, blur, and ambient lighting.
- How poor-light detection should be measured before deciding to enable the flash LED.
- How the numeric reading should be extracted from the 7-segment display inside ESPHome / ESP32-CAM.

## Open Electrical Unknowns (Must Measure)
- Coil resistance
- Allowed duty cycle / max on-time
- Required MOSFET current margin and thermal behavior in enclosure

## Regression/Test
- `bash tools/scad_regression.sh compare`
- If intentional geometry change: `bash tools/scad_regression.sh all`
