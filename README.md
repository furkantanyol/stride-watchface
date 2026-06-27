# Stride

A minimalist, elegant watch face for the Garmin Forerunner 245 and 245 Music. One job: get you to 10,000 steps a day.

Time is the hero. Your daily progress wraps the rim as an arc. The week sits in a row of bars across the lower face, GBD-200 style, adapted to a round display. A streak counts your consecutive 10k days and quietly pressures you to keep it alive.

![concept](docs/concept.md)

## What it shows

- Large center time, day and date above it
- Today's steps against a 10k goal, with a rim progress arc
- A Monday-to-Sunday bar chart of the week's steps with a goal line
- A consecutive-10k-day streak
- Optional, off by default: a small heart rate and battery readout

## Why these and nothing else

A watch face is a glance surface. It cannot be tapped and cannot buzz. So Stride does one thing well instead of five things weakly. Everything on screen either tells the time or moves you toward 10k. See `docs/SPEC.md` for the reasoning.

## Project structure

```
stride-watchface/
  manifest.xml          device targets and app metadata
  monkey.jungle         build config
  source/               Monkey C
    StrideApp.mc        app entry
    StrideView.mc       the watch face, layout and drawing
    Theme.mc            colors and the accent constant
    StepHistory.mc      self-logged weekly step model
    Streak.mc           consecutive-10k-day streak
  resources/
    strings/            app name
    settings/           user settings and defaults
    drawables/          launcher icon
    fonts/              optional custom font (see notes)
  docs/
    SPEC.md             product spec and the coaching model
    DESIGN.md           the visual system: colors, type, exact layout
    ARCHITECTURE.md     code structure, data model, storage shape
    BUILD.md            SDK setup, simulator, sideload
    ROADMAP.md          build phases
```

## Quick start

You need the Connect IQ SDK and the VS Code Monkey C extension. Full steps in `docs/BUILD.md`.

```
# build for the simulator and run
# (use the VS Code command palette: "Monkey C: Build Current Project" then "Monkey C: Run")
```

Then sideload `bin/Stride.prg` to a connected FR245M, or package a `.iq` for the Connect IQ store.

## Status

Design is locked (see DESIGN). The Monkey C is a first pass written without a compiler and will need a build-and-fix pass in the simulator. The docs are the source of truth.
