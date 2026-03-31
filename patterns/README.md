# Patterns

Binary patterns for [ImHex](https://imhex.werwolv.net/) to view parts of the rom as structured data.

### `factory_high_scores.hexpat`

This pattern parses the list of high scores that are included in the ROM.

### `suspected_control_tables_007A00.hexpat`

This pattern marks the `0x00007A00-0x00007E3F` region as suspected control/curve lookup tables with conservative block boundaries.
