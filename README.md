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

## Known Mechanical Reference
- Meter housing: `58 x 92 mm` (corner radius estimated)
- Blue button center: `13.6 mm` from right side, `16 mm` from bottom
- Button stickout: approximately `2 mm`
- Solenoid body reference: `30 x 19 x 16 mm`
- Solenoid plunger: `6 mm` diameter, `12 mm` rest, `17 mm` extended

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

## Open Electrical Unknowns (Must Measure)
- Coil resistance
- Allowed duty cycle / max on-time
- Required MOSFET current margin and thermal behavior in enclosure

## Regression/Test
- `bash tools/scad_regression.sh compare`
- If intentional geometry change: `bash tools/scad_regression.sh all`
