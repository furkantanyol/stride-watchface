# Stride: visual design system

Elegance is the product, and the product is a Casio G-Shock GBD-200 LCD on a round watch. This document is the source of truth for the look. If the code drifts from it, the code is wrong.

## Principles

- **One surface, pure mono, one accent.** Midnight black, light-gray LCD elements, a single red accent used only for today's data. Everything else is neutral gray or white.
- **The chart is the hero.** Time is large and legible but the seven-day bars own the center. Steps and distance whisper in the corners.
- **Restraint over information.** Empty space is a feature. If an element does not earn its pixels, remove it. (The streak pill, rim arc, WEEKLY box and BT indicator were all cut for this reason.)
- **No decoration.** No gradients, shadows, or skeuomorphism. The MIP panel is flat; lean into it.

## Color tokens

Neutral grays only (R=G=B) — a blue-tinted gray quantizes to purple on the 64-color MIP panel. Values live in `source/Theme.mc`.

| Token       | Hex       | Use                                               |
|-------------|-----------|---------------------------------------------------|
| BACKGROUND  | 0x000000  | Whole face                                        |
| SEG_LIT     | 0xFFFFFF  | Lit LCD digits (time), corner step/distance       |
| SEG_GHOST   | 0x1A1A1A  | The unlit "88:88" skeleton behind the time        |
| BAR_FILL    | 0xCCCCCC  | A completed day's bar (~80% white, solid)         |
| MUTED       | 0x8C8C8C  | Axis, date, day numbers, labels                   |
| MUTED_DIM   | 0x4A4A4A  | (reserved) dim secondary marks                    |
| STUB        | 0x242424  | Empty-day bars (3px stubs)                         |
| BOX_EDGE    | 0x5A5A5A  | (reserved) boxed-label border                     |
| ACCENT      | 0xE0301A  | Today's bar and today's date number — red, only   |

Curated accent options (settings): Red 0xE0301A (default), Amber 0xE6B450, Ice 0x8EC9FF, White 0xF3F4F2.

Note: the FR245 panel is 64-color and quantizes these to the nearest displayable color. Verify in the simulator that grays stay neutral and the red still reads.

## Typography

Two bitmap fonts ship in `resources/fonts/`, generated from TTFs by `tools/genfont.py` (white-on-transparent so Garmin tints them with `setColor`). Everything else uses system fonts.

| Element        | Font                                  | Notes                                  |
|----------------|---------------------------------------|----------------------------------------|
| Time           | `LcdTime` — DSEG7 Classic Bold, ~38px | Real 7-segment LCD; ghost layer behind |
| Day numbers    | `DayNum` — Arial Narrow regular, ~10px| Tiny, under each bar                    |
| Step / distance| FONT_TINY (system)                    | Top corners                            |
| Axis 100 / 0%  | FONT_XTINY (system)                   | Left of the chart                      |
| Date m/d + day | FONT_XTINY (system)                   | Beside the time                        |
| Bottom row     | FONT_XTINY (system)                   | Recovery / Body Battery / temp         |

The time's ghost: draw the all-segments string (`8` for each digit, `:` kept) in SEG_GHOST, then the live time in SEG_LIT on top. DSEG7 lights every segment for `8`, so this is the authentic unlit-segment skeleton.

## Layout proportions

All positions are fractions of width (W=240) and height (H=240). The view mirrors these (`source/StrideView.mc`, `source/WeekChart.mc`).

| Element              | x (frac)            | y (frac) | Notes                                         |
|----------------------|---------------------|----------|-----------------------------------------------|
| Steps (top-left)     | 0.30                | 0.130    | FONT_TINY, today's step count                 |
| Distance (top-right) | 0.70                | 0.130    | FONT_TINY, `5.94km`                            |
| Chart baseline (0%)  | centered, axis left | 0.510    | 7 bars, barW=0.066W, gap=0.022W               |
| Chart top (100%)     | —                   | 0.260    | baseY − 0.250H; 100% = goal                   |
| Axis ticks           | left of bars        | 0/25/50/75/100% | short marks on a vertical axis line   |
| Day numbers          | per bar             | baseY+3  | `DayNum` font, date of each day               |
| Time (DSEG7)         | left of date group  | 0.690 cy | centered as a group with the date             |
| Date (m/d over day)  | right of time       | 0.690 ±10| FONT_XTINY, two lines                          |
| Bottom row           | 0.50                | 0.810    | recovery / Body Battery / temp                |

The group of (time + date) is centered together. Keep the chart off the round edges via `WeekChart.SIDE_MARGIN`. Tune these in the simulator and update this table so it stays the source of truth.

## Round adaptation (versus the GBD-200)

The Casio is square and fills corner to corner; Stride is round. The chart sits in a centered band, pulled in from the edges so it stays inside the circle. The time and date are centered as one group in the wider lower-middle. The square's bottom status-icon row becomes the three data readouts; its top BT/MONTHLY corners are dropped in favor of the live step and distance numbers.

## States to design for

- **Goal reached:** today's bar reaches the 100% line, still red.
- **Fresh install / empty days:** days with no logged steps are flat 3px stubs in STUB gray; today grows as steps come in. Must look intentional, not broken.
- **Bottom row partial:** any of recovery / Body Battery / temp may be null and simply omitted; the row recenters on what remains.
- **Bright sunlight:** the common case. Contrast must hold — test the simulator's daylight mode.
