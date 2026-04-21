/*
  Sagemcom button pusher rig (merged, single-file edition)

  Single-source model for:
  - meter/frame reference
  - solenoid reference + cradle
  - combined placement logic

  Coordinate directions (frame reference):
  - +X: right side of the frame (looking at meter from the front)
  - -X: left side of the frame
  - +Y: upward toward the display/fork tips
  - -Y: downward toward the button/bottom edge
  - +Z: outward from housing (away from meter front face)
  - -Z: into housing / behind frame
*/

// ---------------------------------------------------------------------------
// User Parameters
// ---------------------------------------------------------------------------

// Rig render controls
/* [Rig] */

rig_part_to_render = "combined_preview";
// "combined_preview"
// "combined_printable"
// "frame_only"
// "cradle_only"
// "solenoid_only"
// "camera_holder_only"
// "camera_preview"
// "meter_preview"
// "solenoid_preview"
// "collision_check"

meter_ref_show = true;
frame_show = true;
meter_centerlines_show = true;
cradle_show = true;
solenoid_ref_show = true;
solenoid_ref_show_in_preview = true;
camera_mount_show = true;
camera_ref_show = true;

$fn = 56;

// Meter reference + frame dimensions (from sagemcom_meter_clamp.scad)
/* [Meter] */

meter_housing_w = 58;
meter_housing_h = 92;
meter_housing_corner_r = 6;

meter_button_x_from_right = 13.6;
meter_button_x_from_left = meter_housing_w - meter_button_x_from_right;
meter_button_mirror_x = false;
meter_button_y_from_bottom = 16;
meter_button_d = 12;
meter_button_stickout_z = 2;

meter_display_x_from_left = meter_housing_w / 2;
meter_display_y_from_bottom = 51;
meter_display_w = 40;
meter_display_h = 18;
meter_display_corner_r = 2;
meter_display_bezel_margin = 1.6;
meter_display_bezel_t = 1.1;
meter_display_active_inset = 2.0;
meter_display_active_t = 0.5;

/* [Frame] */
frame_thickness = 4.5;
frame_wall = 6;
frame_gap_to_display = 3;
frame_bottom_margin = 2;
frame_extend_down = 2.0;
frame_trim_x_each_side = 0.5;
frame_button_relief_d = 18;

meter_centerline_w = 0.8;
meter_ref_thickness = frame_thickness * 0.5;
meter_ref_touch_overlap = 0.04;

frame_upright_enable = true;
frame_upright_w = frame_wall;
frame_upright_above_display = 8;
frame_upright_display_clearance = 1.2;
frame_upright_max_len = 68;

frame_locator_enable = true;
frame_locator_clearance = 0.7;
frame_locator_wall = 1.8;
frame_locator_depth = 3.0;
frame_locator_frame_overlap = 0.8;
frame_locator_xy_join = 0.35;
frame_locator_region_expand = 2.5;
frame_locator_keepout_top_z = 0.2;
frame_locator_housing_keepout_xy = 0.1;

meter_ref_tab_enable = true;
meter_ref_tab_w = 5.0;
meter_ref_tab_y = 2.5;
meter_ref_tab_z = 4.0;
meter_ref_tab_from_bottom = 3.0;
frame_tab_cutout_enable = true;
frame_tab_cutout_clearance_xy = 0.25;
frame_tab_cutout_z = meter_ref_tab_z + 0.3;

// Solenoid reference dimensions (from solenoid_only.scad)
/* [SolenoidRef] */

solenoid_ref_body_l = 30;
solenoid_ref_body_w = 19;
solenoid_ref_body_h = 16;

solenoid_ref_front_piston_d = 6;
solenoid_ref_front_rest_l = 12;
solenoid_ref_front_extended_l = 17;

solenoid_ref_rear_spring_d = 15;
solenoid_ref_rear_rod_d = 5;
solenoid_ref_rear_rest_l = 19;
solenoid_ref_rear_activated_l = 14;
solenoid_ref_rear_spring_l = 12;

solenoid_ref_show_rest = true;
solenoid_ref_show_activated = true;
solenoid_ref_show_centerline = true;

// Cradle geometry tuning
/* [Cradle] */
cradle_clearance = 0.20;
cradle_wall = 2.4;
cradle_floor = 1.8;
cradle_len_extra_front = 0.5;
cradle_len_extra_rear = 1.4;
cradle_opening_margin = 0.6;
cradle_rail_y_trim = 1.0;
cradle_front_plate_t = 2.0;
cradle_plunger_hole_extra_d = 2.0;
cradle_front_wire_notch_w = 4.0;
cradle_front_wire_notch_depth = 2.0;
cradle_rear_stop_t = 1.2;
cradle_rear_stop_gap = 0.2;
cradle_rear_stop_hole_extra_d = 1.5;
cradle_rear_stop_keep_fraction_y = 0.5;

/* [Camera] */
camera_board_w = 27.0;
camera_board_h = 39.6;
camera_board_t = 1.6;
camera_board_clearance = 0.4;
camera_lens_center_from_top = 9.0;
camera_lens_body_d = 8.5;
camera_holder_wall = 2.2;
camera_holder_depth = 4.0;
camera_holder_corner_tab = 3.0;
camera_holder_back_tab_t = 1.0;
camera_view_margin = 1.0;
camera_fov_h_deg = 62.0;
camera_fov_v_deg = 48.0;
camera_distance_extra = 1.5;
camera_lens_to_board_z = 0.0;
camera_arm_count = 2;
camera_arm_spacing_x = 16.0;
camera_arm_thickness = 4.0;
camera_arm_anchor_y_offset = 1.5;
camera_arm_attach_z_offset = 0.0;

// ---------------------------------------------------------------------------
// Combined assembly tuning
// ---------------------------------------------------------------------------

/* [RigBridge] */
rig_button_press_travel = 1.0;
rig_solenoid_press_margin = 0.1;

rig_bridge_enable = true;
rig_bridge_overlap_z = 2.5;
rig_bridge_join_overlap = 0.12;
rig_bridge_patch_margin_x = 3.0;
rig_bridge_patch_margin_y = 3.0;
rig_bridge_inner_keepout_margin = 0.4;

// ---------------------------------------------------------------------------
// Derived values
// ---------------------------------------------------------------------------

/* [Hidden] */
function clampv(v, lo, hi) = min(max(v, lo), hi);

meter_button_pos = [
    -meter_housing_w / 2 + (meter_button_mirror_x ? (meter_housing_w - meter_button_x_from_left) : meter_button_x_from_left),
    -meter_housing_h / 2 + meter_button_y_from_bottom
];

meter_display_pos = [
    -meter_housing_w / 2 + meter_display_x_from_left,
    -meter_housing_h / 2 + meter_display_y_from_bottom
];

meter_display_bottom_y = meter_display_pos[1] - meter_display_h / 2;
meter_display_top_y = meter_display_pos[1] + meter_display_h / 2;
frame_top_y = meter_display_bottom_y - frame_gap_to_display;
frame_bottom_y = -meter_housing_h / 2 + frame_bottom_margin - frame_extend_down;
frame_upright_top_y = min(
    meter_housing_h / 2 - 1,
    meter_display_top_y + frame_upright_above_display,
    frame_bottom_y + frame_upright_max_len
);
frame_crossbar_top_y = frame_upright_top_y;
frame_mid_y = (frame_bottom_y + frame_crossbar_top_y) / 2;
frame_housing_w = meter_housing_w - 2 * frame_trim_x_each_side;
meter_display_bezel_half_w = (meter_display_w + 2 * meter_display_bezel_margin) / 2;
frame_upright_x_abs = min(
    frame_housing_w / 2 - frame_upright_w / 2 - 0.2,
    meter_display_bezel_half_w + frame_upright_display_clearance + frame_upright_w / 2
);
meter_ref_top_z = meter_ref_touch_overlap;
meter_ref_center_z = meter_ref_top_z - meter_ref_thickness / 2;

rig_solenoid_stroke = max(0, solenoid_ref_front_extended_l - solenoid_ref_front_rest_l);
rig_solenoid_rest_gap = max(0, rig_solenoid_stroke - rig_button_press_travel - rig_solenoid_press_margin);
rig_button_top_z_world = meter_ref_top_z + meter_button_stickout_z;
rig_solenoid_front_z_world = rig_button_top_z_world + rig_solenoid_rest_gap + solenoid_ref_front_rest_l;
rig_solenoid_mount_pos = [
    meter_button_pos[0],
    meter_button_pos[1],
    rig_solenoid_front_z_world
];

cradle_inner_x = solenoid_ref_body_w + 2 * cradle_clearance;
cradle_inner_y = solenoid_ref_body_h + 2 * cradle_clearance;
cradle_z_min = -cradle_len_extra_front;
cradle_z_max = solenoid_ref_body_l + cradle_len_extra_rear;
cradle_bot_x = cradle_inner_x + 2 * cradle_wall;
cradle_side_y = max(0.1, cradle_inner_y + cradle_opening_margin - cradle_rail_y_trim);
cradle_y_min = -cradle_inner_y / 2 - cradle_floor;
cradle_y_max = -cradle_inner_y / 2 + cradle_side_y;

camera_target_w = meter_display_w + 2 * camera_view_margin;
camera_target_h = meter_display_h + 2 * camera_view_margin;
camera_distance_for_w = (camera_target_w / 2) / tan(camera_fov_h_deg / 2);
camera_distance_for_h = (camera_target_h / 2) / tan(camera_fov_v_deg / 2);
camera_optical_distance = max(camera_distance_for_w, camera_distance_for_h) + camera_distance_extra;
camera_lens_offset_y_from_board_center = camera_board_h / 2 - camera_lens_center_from_top;
camera_target_world = [
    meter_display_pos[0],
    meter_display_pos[1],
    meter_ref_top_z + meter_display_bezel_t + meter_display_active_t
];
camera_lens_world = [
    camera_target_world[0],
    camera_target_world[1],
    camera_target_world[2] + camera_optical_distance
];
camera_board_center_world = [
    camera_lens_world[0],
    camera_lens_world[1] - camera_lens_offset_y_from_board_center,
    camera_lens_world[2] + camera_lens_to_board_z
];
camera_holder_inner_w = camera_board_w + camera_board_clearance;
camera_holder_inner_h = camera_board_h + camera_board_clearance;
camera_holder_outer_w = camera_holder_inner_w + 2 * camera_holder_wall;
camera_holder_outer_h = camera_holder_inner_h + 2 * camera_holder_wall;

// ---------------------------------------------------------------------------
// Shared helper geometry
// ---------------------------------------------------------------------------

module rounded_box(size = [20, 20, 5], r = 2, center = true) {
    sx = size[0];
    sy = size[1];
    sz = size[2];
    rr = clampv(r, 0, min(sx, sy) / 2 - 0.01);

    translate(center ? [0, 0, 0] : [sx / 2, sy / 2, sz / 2])
        linear_extrude(height = sz, center = true)
            offset(r = rr)
                square([sx - 2 * rr, sy - 2 * rr], center = true);
}

// ---------------------------------------------------------------------------
// Meter/frame modules
// ---------------------------------------------------------------------------

module housing_reference() {
    color([0.95, 0.95, 0.95, 0.35])
        translate([0, 0, meter_ref_center_z])
            rounded_box([meter_housing_w, meter_housing_h, meter_ref_thickness], meter_housing_corner_r, center = true);

    color([0.08, 0.08, 0.08, 0.9])
        translate([meter_display_pos[0], meter_display_pos[1], meter_ref_top_z + meter_display_bezel_t / 2 + 0.05])
            rounded_box(
                [meter_display_w + 2 * meter_display_bezel_margin, meter_display_h + 2 * meter_display_bezel_margin, meter_display_bezel_t],
                meter_display_corner_r + 0.8,
                center = true
            );

    color([0.18, 0.42, 0.18, 0.9])
        translate([meter_display_pos[0], meter_display_pos[1], meter_ref_top_z + meter_display_bezel_t + meter_display_active_t / 2 + 0.05])
            rounded_box(
                [meter_display_w - 2 * meter_display_active_inset, meter_display_h - 2 * meter_display_active_inset, meter_display_active_t],
                max(0.6, meter_display_corner_r - 0.6),
                center = true
            );

    color([0.15, 0.35, 0.95, 0.85])
        translate([meter_button_pos[0], meter_button_pos[1], meter_ref_top_z + 0.1])
            cylinder(h = 0.8, d = meter_button_d);

    if (meter_ref_tab_enable) {
        color([0.90, 0.94, 0.98, 0.75])
            translate([
                0,
                -meter_housing_h / 2 + meter_ref_tab_from_bottom,
                meter_ref_top_z + meter_ref_tab_z / 2
            ])
                cube([meter_ref_tab_w, meter_ref_tab_y, meter_ref_tab_z], center = true);
    }
}

module housing_centerlines() {
    color([0.9, 0.2, 0.2, 0.8])
        translate([0, 0, meter_ref_top_z + 0.3])
            cube([meter_centerline_w, meter_housing_h, 0.6], center = true);
}

module frame_centerlines() {
    color([0.95, 0.05, 0.85, 0.85])
        translate([0, frame_mid_y, frame_thickness + 0.65])
            cube([meter_centerline_w, frame_crossbar_top_y - frame_bottom_y, 0.6], center = true);
}

module housing_outline_2d() {
    offset(r = meter_housing_corner_r)
        square([frame_housing_w - 2 * meter_housing_corner_r, meter_housing_h - 2 * meter_housing_corner_r], center = true);
}

module lower_band_mask_2d() {
    translate([0, (frame_bottom_y + frame_crossbar_top_y) / 2])
        square([frame_housing_w + 8, frame_crossbar_top_y - frame_bottom_y], center = true);
}

module side_upright_mask_2d() {
    rail_h = frame_upright_top_y - frame_bottom_y;
    for (sx = [-1, 1]) {
        translate([sx * frame_upright_x_abs, (frame_bottom_y + frame_upright_top_y) / 2])
            square([frame_upright_w, rail_h], center = true);
    }
}

module outer_frame_region_2d() {
    intersection() {
        housing_outline_2d();
        union() {
            lower_band_mask_2d();
            if (frame_upright_enable)
                side_upright_mask_2d();
        }
    }
}

module locator_outline_region_2d() {
    y_top_target = frame_upright_enable ? frame_upright_top_y : frame_top_y;
    side_span_h = y_top_target - frame_bottom_y;
    side_span_yc = (frame_bottom_y + y_top_target) / 2;
    side_span_w = frame_upright_w + 2 * frame_locator_region_expand;
    bottom_span_w = frame_housing_w + 8 + 2 * frame_locator_region_expand;
    bottom_span_h = frame_crossbar_top_y - frame_bottom_y;
    y_clip_h = y_top_target - frame_bottom_y;
    y_clip_w = frame_housing_w + 2 * (frame_locator_clearance + frame_locator_wall + frame_locator_region_expand + 6);

    intersection() {
        difference() {
            offset(delta = frame_locator_clearance + frame_locator_wall)
                housing_outline_2d();
            offset(delta = frame_locator_clearance - frame_locator_frame_overlap - frame_locator_xy_join)
                housing_outline_2d();
        }

        intersection() {
            union() {
                translate([0, (frame_bottom_y + frame_crossbar_top_y) / 2])
                    square([bottom_span_w, bottom_span_h], center = true);

                for (sx = [-1, 1]) {
                    translate([sx * (frame_housing_w / 2 - frame_upright_w / 2), side_span_yc])
                        square([side_span_w, side_span_h], center = true);
                }
            }

            translate([0, side_span_yc])
                square([y_clip_w, y_clip_h], center = true);
        }
    }
}

module button_frame_base() {
    difference() {
        union() {
            linear_extrude(height = frame_thickness)
                difference() {
                    outer_frame_region_2d();

                    offset(delta = -frame_wall)
                        outer_frame_region_2d();

                    translate(meter_button_pos)
                        circle(d = frame_button_relief_d);
                }

            if (frame_locator_enable && frame_locator_depth > 0.01) {
                translate([0, 0, -frame_locator_depth])
                    difference() {
                        linear_extrude(height = frame_locator_depth + frame_thickness)
                            locator_outline_region_2d();

                        linear_extrude(height = frame_locator_depth + frame_locator_keepout_top_z)
                            offset(delta = frame_locator_housing_keepout_xy)
                                housing_outline_2d();
                    }
            }
        }

        if (frame_tab_cutout_enable && meter_ref_tab_enable) {
            translate([
                0,
                -meter_housing_h / 2 + meter_ref_tab_from_bottom,
                frame_tab_cutout_z / 2
            ])
                cube(
                    [
                        meter_ref_tab_w + 2 * frame_tab_cutout_clearance_xy,
                        meter_ref_tab_y + 2 * frame_tab_cutout_clearance_xy,
                        frame_tab_cutout_z
                    ],
                    center = true
                );
        }
    }
}

module meter_preview() {
    if (meter_ref_show)
        housing_reference();

    color([0.95, 0.7, 0.1, 0.75])
        button_frame_base();

    if (meter_centerlines_show) {
        if (meter_ref_show)
            housing_centerlines();
        frame_centerlines();
    }
}

// ---------------------------------------------------------------------------
// Solenoid + cradle modules
// ---------------------------------------------------------------------------

module solenoid_body() {
    color([0.58, 0.60, 0.64, 1.0])
        translate([0, 0, solenoid_ref_body_l / 2])
            rounded_box([solenoid_ref_body_w, solenoid_ref_body_h, solenoid_ref_body_l], 1.3, center = true);
}

module solenoid_body_envelope(clearance = 0) {
    color([0.7, 0.7, 0.75, 0.25])
        translate([0, 0, solenoid_ref_body_l / 2])
            rounded_box([solenoid_ref_body_w + 2 * clearance, solenoid_ref_body_h + 2 * clearance, solenoid_ref_body_l], 1.3, center = true);
}

module solenoid_front_plunger_rest() {
    color([0.88, 0.88, 0.88, 1.0])
        translate([0, 0, -solenoid_ref_front_rest_l])
            cylinder(h = solenoid_ref_front_rest_l, d = solenoid_ref_front_piston_d, center = false);
}

module solenoid_front_plunger_activated_marker() {
    ext_extra = max(0, solenoid_ref_front_extended_l - solenoid_ref_front_rest_l);
    if (ext_extra > 0.01) {
        color([0.95, 0.2, 0.2, 0.6])
            translate([0, 0, -solenoid_ref_front_extended_l])
                cylinder(h = ext_extra, d = solenoid_ref_front_piston_d + 0.8, center = false);
    }
}

module solenoid_rear_rest() {
    color([0.85, 0.85, 0.85, 1.0])
        translate([0, 0, solenoid_ref_body_l])
            cylinder(h = solenoid_ref_rear_rest_l, d = solenoid_ref_rear_rod_d, center = false);

    color([0.55, 0.55, 0.58, 0.85])
        translate([0, 0, solenoid_ref_body_l + 0.5])
            cylinder(h = min(solenoid_ref_rear_spring_l, solenoid_ref_rear_rest_l), d = solenoid_ref_rear_spring_d, center = false);
}

module solenoid_rear_activated_marker() {
    delta = max(0, solenoid_ref_rear_rest_l - solenoid_ref_rear_activated_l);
    if (delta > 0.01) {
        color([0.95, 0.2, 0.2, 0.6])
            translate([0, 0, solenoid_ref_body_l + solenoid_ref_rear_activated_l])
                cylinder(h = delta, d = solenoid_ref_rear_rod_d + 0.8, center = false);
    }
}

module solenoid_centerline() {
    color([0.15, 0.75, 0.95, 0.7])
        translate([0, 0, -solenoid_ref_front_extended_l])
            cylinder(h = solenoid_ref_front_extended_l + solenoid_ref_body_l + solenoid_ref_rear_rest_l, d = 0.8, center = false);
}

module solenoid() {
    solenoid_body();

    if (solenoid_ref_show_rest) {
        solenoid_front_plunger_rest();
        solenoid_rear_rest();
    }

    if (solenoid_ref_show_activated) {
        solenoid_front_plunger_activated_marker();
        solenoid_rear_activated_marker();
    }

    if (solenoid_ref_show_centerline)
        solenoid_centerline();
}

module solenoid_cradle_u() {
    inner_x = solenoid_ref_body_w + 2 * cradle_clearance;
    inner_y = solenoid_ref_body_h + 2 * cradle_clearance;

    z_min = -cradle_len_extra_front;
    z_max = solenoid_ref_body_l + cradle_len_extra_rear;
    z_len = z_max - z_min;

    bot_x = inner_x + 2 * cradle_wall;
    bot_y = cradle_floor;
    bot_y_center = -inner_y / 2 - bot_y / 2;

    side_x = cradle_wall;
    side_y = max(0.1, inner_y + cradle_opening_margin - cradle_rail_y_trim);
    side_y_center = -inner_y / 2 + side_y / 2;
    left_x_center = -inner_x / 2 - side_x / 2;
    right_x_center = inner_x / 2 + side_x / 2;

    y_min = -inner_y / 2 - bot_y;
    y_max = -inner_y / 2 + side_y;
    plate_y = y_max - y_min;
    plate_y_center = (y_min + y_max) / 2;
    front_notch_depth = min(cradle_front_wire_notch_depth, plate_y - 0.2);
    front_notch_y_center = y_max - front_notch_depth / 2;
    plunger_hole_d = solenoid_ref_front_piston_d + cradle_plunger_hole_extra_d;
    rear_stop_hole_d = solenoid_ref_rear_spring_d + cradle_rear_stop_hole_extra_d;

    rear_stop_z_front = min(solenoid_ref_body_l + cradle_rear_stop_gap, z_max - cradle_rear_stop_t);
    rear_stop_z_center = rear_stop_z_front + cradle_rear_stop_t / 2;
    rear_keep_y = max(0.1, plate_y * cradle_rear_stop_keep_fraction_y);
    rear_keep_y_center = y_min + rear_keep_y / 2;

    color([0.20, 0.26, 0.34, 1.0])
        union() {
            translate([0, bot_y_center, z_min + z_len / 2])
                cube([bot_x, bot_y, z_len], center = true);

            translate([left_x_center, side_y_center, z_min + z_len / 2])
                cube([side_x, side_y, z_len], center = true);

            translate([right_x_center, side_y_center, z_min + z_len / 2])
                cube([side_x, side_y, z_len], center = true);

            difference() {
                translate([0, plate_y_center, z_min - cradle_front_plate_t / 2])
                    cube([bot_x, plate_y, cradle_front_plate_t], center = true);

                translate([0, 0, z_min - cradle_front_plate_t / 2])
                    cylinder(h = cradle_front_plate_t + 0.4, d = plunger_hole_d, center = true);

                // Small front-edge notch for routing the two solenoid wires.
                translate([0, front_notch_y_center, z_min - cradle_front_plate_t / 2])
                    cube([cradle_front_wire_notch_w, front_notch_depth + 0.2, cradle_front_plate_t + 0.4], center = true);
            }

            if (cradle_rear_stop_t > 0.01) {
                difference() {
                    translate([0, rear_keep_y_center, rear_stop_z_center])
                        cube([bot_x, rear_keep_y, cradle_rear_stop_t], center = true);

                    translate([0, 0, rear_stop_z_center])
                        cylinder(h = cradle_rear_stop_t + 0.4, d = rear_stop_hole_d, center = true);
                }
            }
        }
}

module cradle_collision_check() {
    color([1, 0, 0, 1])
        intersection() {
            solenoid_cradle_u();
            solenoid_body_envelope(0);
        }
}

module solenoid_preview() {
    if (solenoid_ref_show_in_preview)
        solenoid();
    solenoid_cradle_u();
}

// ---------------------------------------------------------------------------
// Camera modules
// ---------------------------------------------------------------------------

module esp32_cam_reference() {
    color([0.10, 0.42, 0.10, 0.65])
        cube([camera_board_w, camera_board_h, camera_board_t], center = true);

    color([0.08, 0.08, 0.08, 0.90])
        translate([0, camera_lens_offset_y_from_board_center, camera_board_t / 2 + 1.8])
            cylinder(h = 3.6, d = camera_lens_body_d, center = true);
}

module camera_holder() {
    inner_w = camera_holder_inner_w;
    inner_h = camera_holder_inner_h;
    outer_w = camera_holder_outer_w;
    outer_h = camera_holder_outer_h;
    tab_xy = min(camera_holder_corner_tab, min(inner_w, inner_h) / 3);

    difference() {
        cube([outer_w, outer_h, camera_holder_depth], center = true);
        cube([inner_w, inner_h, camera_holder_depth + 0.4], center = true);
    }

    // Back corner tabs to keep the board from passing through the holder.
    for (sx = [-1, 1]) {
        for (sy = [-1, 1]) {
            translate([
                sx * (inner_w / 2 - tab_xy / 2),
                sy * (inner_h / 2 - tab_xy / 2),
                -camera_holder_depth / 2 + camera_holder_back_tab_t / 2
            ])
                cube([tab_xy, tab_xy, camera_holder_back_tab_t], center = true);
        }
    }
}

module placed_camera_holder() {
    color([0.18, 0.18, 0.22, 1.0])
        translate(camera_board_center_world)
            camera_holder();
}

module placed_esp32_cam_reference() {
    translate(camera_board_center_world)
        esp32_cam_reference();
}

module camera_mount_struts() {
    anchor_y = frame_crossbar_top_y - camera_arm_anchor_y_offset;
    anchor_z = frame_thickness / 2;
    attach_z = camera_board_center_world[2] - camera_holder_depth / 2 + camera_arm_attach_z_offset;
    arm_count = max(1, round(camera_arm_count));
    spacing = (arm_count <= 1) ? 0 : camera_arm_spacing_x / (arm_count - 1);
    x0 = -camera_arm_spacing_x / 2;

    color([0.20, 0.20, 0.20, 1.0])
        for (i = [0 : arm_count - 1]) {
            dx = x0 + i * spacing;
            hull() {
                translate([meter_display_pos[0] + dx, anchor_y, anchor_z])
                    cube([camera_arm_thickness, camera_arm_thickness, camera_arm_thickness], center = true);
                translate([camera_board_center_world[0] + dx, camera_board_center_world[1], attach_z])
                    cube([camera_arm_thickness, camera_arm_thickness, camera_arm_thickness], center = true);
            }
        }
}

module camera_preview() {
    if (camera_mount_show)
        camera_mount_struts();
    placed_camera_holder();
    if (camera_ref_show)
        placed_esp32_cam_reference();
}

// ---------------------------------------------------------------------------
// Combined placement modules
// ---------------------------------------------------------------------------

module meter_scene() {
    if (meter_ref_show)
        housing_reference();

    if (frame_show)
        color([0.95, 0.7, 0.1, 0.78])
            button_frame_base();

    if (meter_centerlines_show) {
        if (meter_ref_show)
            housing_centerlines();
        if (frame_show)
            frame_centerlines();
    }
}

module placed_solenoid_cradle() {
    color([0.22, 0.30, 0.40, 1.0])
        translate(rig_solenoid_mount_pos)
            solenoid_cradle_u();
}

module placed_solenoid_reference() {
    translate(rig_solenoid_mount_pos)
        solenoid();
}

module frame_to_cradle_bridge() {
    if (rig_bridge_enable) {
        cradle_min_z_world = rig_solenoid_mount_pos[2] + cradle_z_min;
        extension_top_z = cradle_min_z_world + rig_bridge_overlap_z;
        extension_h = max(0, extension_top_z - frame_thickness);

        if (extension_h > 0.01) {
            patch_w = cradle_bot_x + 2 * rig_bridge_patch_margin_x;
            patch_h = (cradle_y_max - cradle_y_min) + 2 * rig_bridge_patch_margin_y;
            patch_center_y = (cradle_y_min + cradle_y_max) / 2;
            inner_keepout_x = cradle_inner_x + 2 * rig_bridge_inner_keepout_margin;
            inner_keepout_y = cradle_inner_y + 2 * rig_bridge_inner_keepout_margin;
            inner_keepout_z = (cradle_z_max - cradle_z_min) + 2 * rig_bridge_inner_keepout_margin;
            inner_keepout_zc = (cradle_z_min + cradle_z_max) / 2;

            difference() {
                translate([0, 0, frame_thickness - rig_bridge_join_overlap])
                    linear_extrude(height = extension_h + rig_bridge_join_overlap)
                        intersection() {
                            projection(cut = true)
                                button_frame_base();
                            translate([rig_solenoid_mount_pos[0], rig_solenoid_mount_pos[1] + patch_center_y])
                                square([patch_w, patch_h], center = true);
                        }

                translate(rig_solenoid_mount_pos)
                    translate([0, 0, inner_keepout_zc])
                        cube([inner_keepout_x, inner_keepout_y, inner_keepout_z], center = true);
            }
        }
    }
}

module combined_preview() {
    meter_scene();
    if (cradle_show)
        placed_solenoid_cradle();
    if (frame_show && cradle_show)
        color([0.88, 0.56, 0.16, 1.0])
            frame_to_cradle_bridge();
    if (solenoid_ref_show)
        placed_solenoid_reference();
    if (camera_mount_show || camera_ref_show)
        camera_preview();
}

module combined_printable() {
    union() {
        if (frame_show)
            button_frame_base();
        if (cradle_show)
            placed_solenoid_cradle();
        if (frame_show && cradle_show)
            frame_to_cradle_bridge();
        if (camera_mount_show)
            camera_mount_struts();
        if (camera_mount_show)
            placed_camera_holder();
    }
}

// ---------------------------------------------------------------------------
// Render selector
// ---------------------------------------------------------------------------

if (rig_part_to_render == "combined_preview") {
    combined_preview();
} else if (rig_part_to_render == "combined_printable") {
    combined_printable();
} else if (rig_part_to_render == "frame_only") {
    if (frame_show)
        color([0.95, 0.7, 0.1, 0.78])
            button_frame_base();
} else if (rig_part_to_render == "cradle_only") {
    if (cradle_show)
        placed_solenoid_cradle();
} else if (rig_part_to_render == "solenoid_only") {
    if (solenoid_ref_show)
        placed_solenoid_reference();
} else if (rig_part_to_render == "camera_holder_only") {
    camera_holder();
} else if (rig_part_to_render == "camera_preview") {
    meter_scene();
    camera_preview();
} else if (rig_part_to_render == "meter_preview") {
    meter_preview();
} else if (rig_part_to_render == "solenoid_preview") {
    solenoid_preview();
} else if (rig_part_to_render == "collision_check") {
    cradle_collision_check();
}
