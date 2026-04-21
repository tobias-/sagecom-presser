# AGENTS.md

## Scope
Instructions for any coding agent working in this repository.

## Project Summary
- Purpose: parametric OpenSCAD model for a non-destructive Sagemcom water-meter button pusher rig.
- Main outputs: printable frame + solenoid cradle + combined assembly preview/print geometry.
- Source of truth: `sagemcom_button_pusher_rig.scad` (single-file model).

## Repository Layout
- `sagemcom_button_pusher_rig.scad`: all model geometry and render selector.
- `tools/scad_regression.sh`: STL regression harness using OpenSCAD mesh diff.
- `tests/scad_cases_baseline.tsv`: baseline test cases.
- `tests/scad_cases_candidate.tsv`: candidate test cases.
- `README.md`: project-facing status/design documentation.

## Model Conventions
- Coordinate system (front view):
  - `+X` right, `-X` left
  - `+Y` up, `-Y` down
  - `+Z` outward from housing
- Top-level parameter groups in SCAD:
  - `[Rig]`, `[Meter]`, `[Frame]`, `[SolenoidRef]`, `[Cradle]`, `[RigBridge]`, `[Hidden]`
- Render selector variable: `rig_part_to_render`
  - Values: `combined_preview`, `combined_printable`, `frame_only`, `cradle_only`, `solenoid_only`, `camera_holder_only`, `camera_preview`, `meter_preview`, `solenoid_preview`, `collision_check`

## Known Mechanical/Electrical Facts
- Meter reference:
  - Housing: `58 x 92 mm` (corner radius estimated).
  - Button center: `13.6 mm` from right side, `16 mm` from bottom.
  - Button stickout estimated: `~2 mm`.
- Solenoid reference:
  - Body: `30 x 19 x 16 mm`.
  - Front plunger: `6 mm` diameter, `12 mm` rest, `17 mm` extended.
  - Rear spring diameter: `15 mm`.
- Cradle:
  - Fit clearance target: `0.20 mm`.
  - Front plate plunger hole oversize: `+2.0 mm`.
  - Front wire notch: `4.0 mm` wide, `2.0 mm` deep.
- Camera holder:
  - ESP32-CAM board reference: `27.0 x 39.6 mm`.
  - Lens center reference: centered in X, `9.0 mm` below top edge.
  - Placement targets LCD center with computed standoff from FOV parameters.
- Electrical knowledge currently captured:
  - Solenoid is a 2-wire actuator.
  - Solenoid coil rated supply: `12V`.
  - Solenoid rated current: `650mA`.
  - Nominal coil power at rating: `~7.8W`.

## Editing Rules For Agents
- Keep the design non-destructive (no permanent meter modifications).
- Do not re-introduce split SCAD source files unless explicitly requested.
- Prefer parameterized changes over hardcoded one-off transforms.
- Preserve or improve printability (avoid unsupported geometry where possible).
- Avoid cradle/solenoid intersections; use `collision_check` for sanity.
- Keep render selector branches fully braced (`if { ... } else if { ... }`) to avoid dangling-`else` bugs.

## Validation Checklist (Run Before Finalizing)
1. Quick render sanity:
   - `openscad -o /tmp/preview.stl -D 'rig_part_to_render="combined_preview"' sagemcom_button_pusher_rig.scad`
   - `openscad -o /tmp/printable.stl -D 'rig_part_to_render="combined_printable"' sagemcom_button_pusher_rig.scad`
2. Regression:
   - `bash tools/scad_regression.sh compare`
3. If geometry was intentionally changed:
   - `bash tools/scad_regression.sh all` (refresh baseline + compare)

## Notes For Future Electrical Integration
Before adding drive electronics assumptions, first measure/confirm:
- Coil resistance and transient/steady current profile in real wiring
- Allowed on-time/duty cycle
- Flyback and driver requirements

## Documentation Policy
- Document newly confirmed project facts immediately.
- Put user/project-facing facts in `README.md` (architecture, wiring approach, status, known specs).
- Put agent workflow/process constraints in `AGENTS.md` (editing rules, validation steps, repo conventions).
