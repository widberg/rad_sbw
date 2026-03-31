import std.core;
import std.sys;
#include <std/mem.pat>

/*
 * rad_sbw suspected control / curve table region
 * ROM range: 0x00007A00 - 0x00007E3F (size 0x440)
 *
 * This area does not look like tile bitplanes and does not look like
 * straightforward code. It appears to be lookup/curve-like data:
 *   - a front matter section with ramps/plateaus
 *   - several similarly-shaped 0x80-byte blocks
 *   - a 0x40-byte trailing mirror/continuation
 *
 * The exact semantic meaning is still unknown.
 */

struct SuspectedPrelude256 {
    // 0x7A00 - 0x7A1F
    u8 initial_descending_curve[0x20];

    // 0x7A20 - 0x7A6F
    u8 quantized_decay_to_floor[0x50];

    // 0x7A70 - 0x7AAF
    u8 floor_plateau_run[0x40];

    // 0x7AB0 - 0x7AFF
    u8 transition_into_profile_bank[0x50];
};

struct SuspectedProfileBlock128 {
    // Per-block shape appears mostly consistent across 0x7B00-0x7DFF.
    u8 impulse_or_seed[0x10];
    u8 negative_swing_region[0x20];
    u8 centerline_transition[0x20];
    u8 positive_swing_region[0x20];
    u8 return_tail[0x10];
};

struct SuspectedControlTables007A00 {
    // 0x7A00 - 0x7AFF
    SuspectedPrelude256 prelude;

    // 0x7B00 - 0x7DFF
    SuspectedProfileBlock128 profile_blocks[6];

    // 0x7E00 - 0x7E3F
    u8 trailing_profile_prefix_repeat[0x40];
};

SuspectedControlTables007A00 control_tables @ 0x00007A00;

/*
 * Visualizer-friendly copy:
 * Copy the raw bytes into a custom section as float arrays so ImHex line_plot
 * can be used directly from Pattern Data.
 */
std::mem::Section curve_plot_section = std::mem::create_section("rad_sbw 007A00 curves");

u8 source_region_bytes[0x440] @ 0x00007A00 [[hidden]];

float plot_whole_region_raw_u8_as_f32[0x440] @ 0x0000 in curve_plot_section
    [[name("plot_whole_region_raw_u8_as_f32"), hex::visualize("line_plot", this)]];
float plot_whole_region_centered_minus_128[0x440] @ 0x1100 in curve_plot_section
    [[name("plot_whole_region_centered_minus_128"), hex::visualize("line_plot", this)]];

float plot_profile_block_0_raw_u8_as_f32[0x80] @ 0x2200 in curve_plot_section
    [[name("plot_profile_block_0_raw_u8_as_f32"), hex::visualize("line_plot", this)]];
float plot_profile_block_1_raw_u8_as_f32[0x80] @ 0x2400 in curve_plot_section
    [[name("plot_profile_block_1_raw_u8_as_f32"), hex::visualize("line_plot", this)]];
float plot_profile_block_2_raw_u8_as_f32[0x80] @ 0x2600 in curve_plot_section
    [[name("plot_profile_block_2_raw_u8_as_f32"), hex::visualize("line_plot", this)]];
float plot_profile_block_3_raw_u8_as_f32[0x80] @ 0x2800 in curve_plot_section
    [[name("plot_profile_block_3_raw_u8_as_f32"), hex::visualize("line_plot", this)]];
float plot_profile_block_4_raw_u8_as_f32[0x80] @ 0x2A00 in curve_plot_section
    [[name("plot_profile_block_4_raw_u8_as_f32"), hex::visualize("line_plot", this)]];
float plot_profile_block_5_raw_u8_as_f32[0x80] @ 0x2C00 in curve_plot_section
    [[name("plot_profile_block_5_raw_u8_as_f32"), hex::visualize("line_plot", this)]];

fn build_curve_plots() {
    // 0x7A00 - 0x7E3F as raw float values (0..255) and centered values (-128..127).
    for (u32 i = 0, i < 0x440, i = i + 1) {
        plot_whole_region_raw_u8_as_f32[i] = float(source_region_bytes[i]);
        plot_whole_region_centered_minus_128[i] = float(source_region_bytes[i]) - 128.0f;
    }

    // 0x7B00 - 0x7DFF profile bank split into 6x 0x80-byte blocks.
    for (u32 i = 0, i < 0x80, i = i + 1) {
        plot_profile_block_0_raw_u8_as_f32[i] = float(source_region_bytes[0x100 + i]);
        plot_profile_block_1_raw_u8_as_f32[i] = float(source_region_bytes[0x180 + i]);
        plot_profile_block_2_raw_u8_as_f32[i] = float(source_region_bytes[0x200 + i]);
        plot_profile_block_3_raw_u8_as_f32[i] = float(source_region_bytes[0x280 + i]);
        plot_profile_block_4_raw_u8_as_f32[i] = float(source_region_bytes[0x300 + i]);
        plot_profile_block_5_raw_u8_as_f32[i] = float(source_region_bytes[0x380 + i]);
    }
};

build_curve_plots();
