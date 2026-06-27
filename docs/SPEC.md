# Stride: product spec

## Purpose

One job: get the wearer to 10,000 steps a day, and make the time effortless to read. Everything else is noise and is excluded on purpose.

## The one screen

A round, midnight-black face. Top to bottom:

1. Day and date, small and muted.
2. The time, large, white, the hero element.
3. Today's steps against the goal, the step number in the accent color.
4. A streak pill: consecutive days you hit 10k.
5. A Monday-to-Sunday bar chart of the week's steps, with a goal line, today's bar in the accent color.
6. A progress arc around the rim showing today's percentage toward 10k.
7. Optional and off by default: a small heart rate and battery readout near the bottom.

## The coaching model

A watch face cannot buzz or notify. It can only show. So Stride coaches through three visual levers, all passive and always honest:

1. The rim arc. It fills clockwise from the top as you approach 10k. An empty arc late in the day is a quiet accusation.
2. The pill. Before the goal it reads "N day streak" when a streak is alive, otherwise it shows the remaining steps ("2,580 to go"). Once you cross 10k it reads "10k done". The streak is the strongest lever: loss aversion. Miss a day and it resets to zero, and you feel it.
3. The week bars. Seeing five strong days and one stub builds self-accountability without a word.

If active nudging is ever wanted (a buzz at 6pm when under target), that is the device's built-in move alert or a separate companion widget, never this face. Keep the move alert enabled on the watch.

## Settings

Three, exposed in the Connect IQ phone app:

- Daily step goal. Default 10,000. The whole face scales to this number.
- Accent color. A short curated list: Teal, Amber, Ice, White. Default Teal.
- Show heart rate and battery. Default off, to keep the face minimal.

## Explicitly out of scope (YAGNI)

No seconds by default, no weather, no notifications count, no music controls, no sunrise/sunset, no floors or elevation (the FR245 has no barometer), no multiple data screens, no animations, no menus. Adding any of these is a regression against the design goal unless explicitly requested.

## Success criteria

The wearer can read the time in a glance in sunlight, knows instantly how close they are to 10k, and feels the streak. The face looks expensive and calm. Battery life is unaffected versus a stock face.
