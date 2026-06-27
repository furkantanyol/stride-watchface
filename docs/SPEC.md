# Stride: product spec

## Purpose

One job: get the wearer to 10,000 steps a day, and make the time effortless to read. Everything else is noise and is excluded on purpose. The look is a faithful homage to the Casio G-Shock GBD-200 LCD, adapted to a round 240x240 display.

## The one screen

A round, midnight-black face, pure monochrome with a single red accent on today's data. Top to bottom:

1. **Top corners.** Today's step count (small, top-left) and today's distance in km (small, top-right). Plain readouts, like the GBD's corner indicators.
2. **The step chart — the hero.** A seven-day bar chart filling the upper-middle. A left axis runs 0% to 100% of the daily goal with tick marks at each quarter. Each bar is one day, numbered by date below. Today's bar and its date number are red; consecutive bars reaching the top read as your streak at a glance.
3. **The time.** Large, in a real DSEG7 LCD font, lower third. A dim "88:88" ghost skeleton sits behind the lit digits, the way a real segment LCD looks. 12h/24h follows the watch's own setting; there is no AM/PM indicator.
4. **The date,** stacked beside the time: month/day over the weekday (e.g. `6/27` over `SAT`).
5. **Bottom row.** Three motivating readouts: recovery hours, Body Battery, and current temperature. Each hides cleanly if its data is unavailable.

## The coaching model

A watch face cannot buzz or notify. It can only show. Stride coaches through honest, passive visual pressure:

1. **The chart.** Seven days of bars against the goal line. Seeing five strong days and one stub builds self-accountability without a word. A run of bars over the line *is* your streak, made visible.
2. **Today in red.** Today's bar and date number are the one spot of color. A short red bar late in the day is a quiet accusation.
3. **The corner step count** ticks up through the day toward the goal the bars are measured against.

If active nudging is ever wanted (a buzz at 6pm when under target), that is the device's built-in move alert, never this face. Keep the move alert enabled on the watch.

## Settings

Two, exposed in the Connect IQ phone app:

- **Daily step goal.** Default 10,000. The chart's 100% line scales to this number.
- **Accent color.** A short curated list: Red (default), Amber, Ice, White. Applied only to today's bar and today's date number.

## Explicitly out of scope (YAGNI)

No seconds by default, no weather forecast, no notifications count, no music controls, no sunrise/sunset, no floors or elevation (the FR245 has no barometer), no multiple data screens, no animations, no menus. The streak pill and rim progress arc from earlier concepts were intentionally cut — the chart carries the streak and the goal. Adding anything back is a regression against the design goal unless explicitly requested.

## Success criteria

The wearer can read the time in a glance in sunlight, sees instantly where today's bar sits against the goal line and how the week is trending, and the face looks like a calm, expensive LCD instrument. Battery life is unaffected versus a stock face.
