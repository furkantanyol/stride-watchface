# Stride: visual design system

Elegance is the product. This document is the source of truth for the look. If the code drifts from it, the code is wrong.

## Principles

- One surface, one accent. Midnight black, white time, a single accent color used only for today's data. Everything else is muted gray.
- Restraint over information. Empty space is a feature. If an element does not earn its pixels, remove it.
- Calm hierarchy. Time first, steps second, week third, everything else whispers.
- No decoration. No gradients, no shadows, no skeuomorphism. The MIP panel is flat; lean into it.

## Color tokens

The face is a fixed physical look and never inverts. Values live in `source/Theme.mc`.

| Token       | Hex       | Decimal   | Use                                            |
|-------------|-----------|-----------|------------------------------------------------|
| BACKGROUND  | 0x000000  | 0         | Whole face                                     |
| TIME        | 0xFFFFFF  | 16777215  | The time                                       |
| MUTED       | 0x6B7280  | 7041664   | Date, "of 10,000", weekday labels, goal line   |
| MUTED_DIM   | 0x3A4047  | 3817543   | Past weekly bars                               |
| STUB        | 0x1A1E24  | 1711140   | Ring track, future-day bar stubs               |
| PILL_BG     | 0x11211D  | 1122589   | Streak pill fill                               |
| PILL_EDGE   | 0x1E3B33  | 1989427   | Streak pill border                             |
| ACCENT      | 0x45C8A4  | 4573348   | Today's arc, step count, today's bar and label |

Curated accent options (settings): Teal 0x45C8A4, Amber 0xE6B450, Ice 0x8EC9FF, White 0xF3F4F2.

Note: the FR245 panel is 64-color. The system quantizes these to the nearest displayable color. Verify the accent still reads well after quantization in the simulator.

## Typography

System fonts only, to protect memory. No custom font in v1.

| Element        | Font                         | Weight feel | Justify          |
|----------------|------------------------------|-------------|------------------|
| Time           | FONT_NUMBER_THAI_HOT         | hero        | center, vcenter  |
| Step count     | FONT_SMALL                   | medium      | left of pair     |
| "of 10,000"    | FONT_XTINY                   | light muted | continues pair   |
| Date           | FONT_XTINY                   | light muted | center           |
| Streak pill    | FONT_XTINY                   | accent      | center, vcenter  |
| Weekday labels | FONT_XTINY                   | muted       | center           |

Two visual weights at most. Never shout. Sentence case everywhere.

## Layout proportions

All positions are fractions of width (W=240) and height (H=240), so the code is device-independent. The view mirrors this table exactly.

| Element             | x (frac)        | y (frac) | Notes                                  |
|---------------------|-----------------|----------|----------------------------------------|
| Rim arc / track     | center          | center   | radius = W/2 - 6, pen 6, from 12 o'clock clockwise |
| Date                | 0.50            | 0.12     | "Sat 27 Jun"                           |
| Time                | 0.50            | 0.40     | vertical center                        |
| Steps pair          | centered pair   | 0.575    | accent number + muted goal             |
| Streak pill         | 0.50            | 0.66     | height 22, fully rounded               |
| Week bars baseline  | centered row    | 0.82     | 7 bars, barW=0.066W, gap=0.025W, maxH=0.18H |
| Goal line           | across bars     | derived  | baseY - (goal/(goal*1.25)) * maxH      |
| Weekday labels      | per bar         | 0.82 +4px| M T W T F S S                          |
| HR / battery (opt)  | 0.30 / 0.70     | 0.90     | only if ShowSecondary                  |

These y fractions are a calm first pass. Nudge them in the simulator until the vertical rhythm feels balanced, then update this table so it stays the source of truth. The big number font is tall; confirm the time does not crowd the date above or the steps below.

## Round adaptation (versus the GBD-200)

The Casio is square, so its step bars sit in a clean strip. Stride is round. Two moves keep it elegant:

- The week bars live in a centered band low on the face, narrower than the diameter so they sit inside the circle with margin.
- The daily goal becomes the rim arc instead of a bar, which uses the circular edge that a square watch does not have.

## States to design for

- Goal reached: arc full, step number still accent, pill reads "10k done", today's bar at or above the goal line.
- No streak: pill shows remaining steps instead.
- Fresh install, empty week: past bars are flat stubs, today grows as steps come in. This must look intentional, not broken.
- Future days in the week: faint stubs in STUB color, no label emphasis.
- Bright sunlight: this is the common case for a runner. Contrast must hold. Test the simulator's daylight mode.
