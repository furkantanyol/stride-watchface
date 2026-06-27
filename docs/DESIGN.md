# Stride: visual design system

A monochrome LCD instrument on a round 240×240 panel — a Casio G-Shock GBD-200 in spirit, refined through the Claude Design exploration. This document is the source of truth for the look. If the code drifts from it, the code is wrong.

## Principles

- **Pure mono, one accent.** Black surface, white/gray LCD elements, a single amber accent used only for today's data (today's bar and date number). Everything else is neutral gray or white.
- **The chart is the hero.** The time is large and legible, but the seven-day bars own the center. Steps and distance whisper in the corners; recovery / Body Battery / temp along the bottom.
- **Units, not labels.** A readout shows its number and its unit (`km`, `h`, `%`, `°`) — the unit carries the meaning, so there are no word labels. Steps is a bare number.
- **Restraint.** No gradients, shadows, or skeuomorphism — the MIP panel is flat. The streak pill, rim arc, WEEKLY box, BT indicator, chart axis, and metric labels were all cut.

## Color tokens

Every channel snaps to one of four MIP levels (`00 / 55 / AA / FF`) → 64 colors, so all tokens sit on that grid and nothing shifts on-panel. Grays are strictly R=G=B (a blue tint quantizes to purple). Values live in `source/Theme.mc`.

| Token       | Hex       | Use                                                        |
|-------------|-----------|------------------------------------------------------------|
| BACKGROUND  | 0x000000  | Whole face                                                 |
| SEG_LIT     | 0xFFFFFF  | Time, all readout numbers, days that cleared the goal      |
| MUTED       | 0xAAAAAA  | Units, date, day numbers, days under goal                  |
| SEG_GHOST   | 0x555555  | The dashed goal line                                       |
| ACCENT      | 0xFFAA00  | Today's bar and today's date number — amber, only          |

Accent options (settings): Amber 0xFFAA00 (default), Hot 0xFF5500, Ice 0x55AAFF, White 0xFFFFFF.

There is **no ghost skeleton behind the time**: at four grayscale levels the only "faint" option (`#555`) competes with the lit digits and muddies them, so the time is plain white.

## Typography

Four bitmap fonts ship in `resources/fonts/`, generated from TTFs by `tools/genfont.py` (white-on-transparent so Garmin tints them with `setColor`).

| Font       | Source                      | Used for                                  |
|------------|-----------------------------|-------------------------------------------|
| `LcdTime`  | DSEG7 Classic Bold, ~38px   | The time (7-segment LCD)                   |
| `LcdSmall` | DSEG7 Classic Bold, ~15px   | Every small number: steps, distance, recovery, body, temp |
| `DayNum`   | Arial Narrow regular, ~10px | Day numbers under the bars                 |
| `Word`     | Arial Narrow Bold, ~15px    | All words/units: `km h % ° `, date `6/27` and weekday |

Every number is DSEG7; every word/unit is the condensed sans — one cohesive instrument. The distance decimal point is hand-drawn (`fillRectangle`) because DSEG7's `.` glyph can't render on Garmin.

## Layout proportions

Fractions of width (W=240) and height (H=240); the view mirrors these (`source/StrideView.mc`, `source/WeekChart.mc`).

| Element              | x (frac)        | y (frac) | Notes                                         |
|----------------------|-----------------|----------|-----------------------------------------------|
| Steps (top-left)     | 0.30            | 0.125 cy | bare number, LcdSmall                         |
| Distance (top-right) | 0.70            | 0.125 cy | number + `km`                                 |
| Chart baseline (0%)  | centered        | 0.450    | 7 bars, barW=0.066W, gap=0.022W               |
| Chart top (120%)     | —               | 0.200    | baseY − 0.250H; goal line at 100%             |
| Goal line (100%)     | across bars     | dashed   | SEG_GHOST, 120% headroom above it             |
| Day numbers          | per bar         | baseY+3  | DayNum, today in accent                       |
| Time (LcdTime)       | left of date    | 0.655 cy | centered as a group with the date             |
| Date (m/d over day)  | right of time   | 0.655 ±10| Word font, two lines                          |
| Bottom row           | 0.255/0.50/0.745| 0.815 cy | recovery `h` / body `%` / temp `°`, single-line |

## The chart

Each day is a vertical stack of discrete 10%-of-goal LCD blocks (4px tall, 1px gap), the G-Shock segment grain. A day that **cleared the goal is white**, one that **fell short is muted gray**, and **today is amber**. The dashed goal line sits at 100% with 120% headroom, so an over-goal day's blocks visibly cross it — a run of blocks over the line reads as a streak. No axis line or ticks; the goal line is the only reference.

## States to design for

- **Goal reached / exceeded:** today's blocks reach or cross the goal line, still amber.
- **Fresh install / empty days:** a day with no logged steps draws no blocks. Today grows as steps come in; older days fill over the week.
- **Bottom row partial:** recovery / Body Battery / temp each show `--` when null (temp is null until the phone syncs weather; Body Battery works on the FR245M).
- **Bright sunlight:** the common case — white and amber hold contrast on the reflective panel; test the simulator's daylight mode.
