# Stride: status and roadmap

The face is built, compiles clean for `fr245m`, and runs on-device. This tracks what is done and what is left.

## Done

- **Toolchain.** SDK + JDK via Homebrew, developer key, FR245M device files. Builds warning-clean.
- **Layout.** Steps + distance corners, the seven-day chart (axis, quarter ticks, numbered bars, today in red), DSEG7 time with a ghost layer, date beside it, bottom metrics row.
- **Data.** Rolling self-logged seven-day history; live steps and distance; recovery / Body Battery / weather, each `has`-guarded.
- **Look.** Pure mono with one red accent; neutral grays (no purple); real DSEG7 LCD font.
- **Deploy.** Sideloaded to the FR245 Music over MTP (`tools/mtpsend.c`).

## Open / next

- **Verify on-wrist over a full week** that the rolling history fills correctly across midnight rollovers, and that recovery / Body Battery / weather populate once synced.
- **Tune proportions with real step data** (the simulator can only fill today's bar).
- **Memory headroom check** in the simulator after any asset change.
- **Settings polish** if wanted: the accent list is Red/Amber/Ice/White; goal scales the chart.

## Later, only if wanted

- A second DSEG size so the corner distance also uses the LCD font.
- Optional connectivity glyph (BT / notifications) back in a corner.
- A companion widget for an active 6pm nudge. Not part of this face.
