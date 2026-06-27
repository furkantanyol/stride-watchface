# Stride

A minimalist watch face for the Garmin Forerunner 245 / 245 Music. One job: get you to 10,000 steps a day. A faithful homage to the Casio G-Shock GBD-200 LCD, adapted to a round 240x240 display — pure monochrome with a single red accent on today.

## What it shows

- **A seven-day step bar chart** (the hero): a 0–100%-of-goal axis with quarter ticks, one bar per day numbered by date, **today in red**. A run of bars over the goal line is your streak, made visible.
- **The time** in a real DSEG7 LCD font with a dim ghost skeleton, the date stacked beside it (`6/27` over `SAT`). 12h/24h follows the watch setting.
- **Top corners:** today's step count (left) and distance (right).
- **Bottom row:** recovery hours, Body Battery, and current temperature — each hides if unavailable.

## Why these and nothing else

A watch face is a glance surface — it cannot be tapped and cannot buzz. So Stride does one thing well: everything on screen either tells the time or moves you toward 10k. See `docs/SPEC.md`.

## Project structure

```
stride-watchface/
  manifest.xml          device targets (fr245m, fr245) and app metadata
  monkey.jungle         build config
  source/               Monkey C
    StrideApp.mc        app entry
    StrideView.mc       the watch face: layout and composition
    WeekChart.mc        the seven-day bar chart
    Metrics.mc          guarded recovery / Body Battery / weather reads
    Theme.mc            colors and the accent constant
    StepHistory.mc      rolling self-logged seven-day step model
  resources/
    strings/ settings/ drawables/
    fonts/              DSEG7 time font + Arial Narrow day-number font
  tools/                font generator + MTP sideload helper
  docs/                 SPEC, DESIGN, ARCHITECTURE, BUILD, ROADMAP
```

## Quick start

Toolchain (macOS): `brew install --cask connectiq` + `brew install openjdk`, a developer key, and the FR245M device files via the SDK Manager. Then:

```sh
monkeyc -f monkey.jungle -d fr245m -y ~/.Garmin/developer_key.der -o bin/Stride.prg -w
connectiq & ; monkeydo bin/Stride.prg fr245m     # run in the simulator
```

Full setup, the simulator test matrix, and the MTP sideload steps (the 245 Music isn't a mountable drive) are in `docs/BUILD.md`.

## Status

Built, compiling clean for `fr245m`, and running on-device. The `docs/` are the source of truth and are kept in sync with the implementation.
