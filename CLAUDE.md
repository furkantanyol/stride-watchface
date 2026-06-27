# Stride: Garmin Forerunner 245 / 245 Music watch face

This file is the brief for Claude Code. Read it fully before touching code. The companion docs in `docs/` hold the detail. The single rule that overrides everything: **stay minimal and elegant, and protect battery.** When in doubt, cut.

## Mission

A minimalist, elegant digital watch face whose one job is to push the wearer to 10,000 steps a day. Inspired by the Casio G-Shock GBD-200 weekly step bars, adapted to a round 240x240 display. Time is the hero, steps own the lower half, a daily goal arc wraps the rim, and a persisted streak applies gentle pressure.

This is a personal face, not a store product. Do not add configuration, telemetry, or features that are not in `docs/SPEC.md`. YAGNI is law here.

## Target device and platform

- Devices: `forerunner245m` (primary) and `forerunner245`.
- Display: 240x240, round, 64-color memory-in-pixel (always-on, transflective). Design for sunlight legibility, not OLED saturation.
- Connect IQ: System 3 device. Set `minApiLevel` in `manifest.xml` and **verify it compiles against the FR245M device entry in the SDK** before assuming an API exists.
- No barometer. No floors, no native elevation. Never reference them.

## Watch-face hard limits (do not fight these)

- A watch face is glance-only. It receives no taps and no button events. There is no interactivity.
- A watch face cannot vibrate or send notifications. "Pushing the user" is visual pressure only (see SPEC). The system's own move alert handles buzzing; we do not.
- `onUpdate()` runs once per minute in low-power mode. `onPartialUpdate()` can run at 1 Hz but is capped at roughly 30 ms of draw on the low-power coprocessor. Seconds are **off by default** and must stay cheap if ever enabled.
- Memory budget is tight (low hundreds of KB). Use system fonts and drawn vector shapes. No large bitmaps. Confirm the exact budget from the device XML in the SDK and keep well under it.

## Design non-negotiables (elegance lives here)

Full system in `docs/DESIGN.md`. The rules you must not break:

- Midnight-black background. One accent color, used only for: today's progress arc, today's step number, today's weekly bar, today's weekday label. Everything else is white or muted gray.
- Two type weights maximum. Generous negative space. Nothing decorative.
- The accent is a single constant in `source/Theme.mc`, also overridable via app settings. Changing the whole face's color is a one-line edit.
- If a feature does not help the wearer reach 10k or read the time, it does not belong on the face.

## Architecture

Detail in `docs/ARCHITECTURE.md`. Source layout:

- `source/StrideApp.mc` — `AppBase`, returns the view.
- `source/StrideView.mc` — the `WatchFace`. Owns layout and all drawing.
- `source/Theme.mc` — colors and the accent constant.
- `source/StepHistory.mc` — the weekly step model. Self-logs daily totals into `Application.Storage` keyed by local day number, so the Monday-to-Sunday bars are reliable regardless of `ActivityMonitor.getHistory()` depth.
- `source/Streak.mc` — consecutive-10k-day streak, persisted, computed from today's steps only.

Why self-logged steps instead of `getHistory()`: `getHistory()` depth is device- and state-dependent and may return shallow data. Self-logging the current week is deterministic. See ARCHITECTURE for the exact storage shape.

## Coding conventions

- Monkey C, `using Toybox.X as Y` imports. Clear names, no abbreviations in public methods.
- All layout positions derive from `dc.getWidth()` / `dc.getHeight()`, never hardcoded to 240, so the simulator and any future device scale correctly. The constants table in DESIGN gives the ratios.
- Round every number that reaches the screen. Format thousands with a separator (the helper lives in the view).
- Keep `onUpdate()` allocation-light. Pull settings once, reuse. No per-frame object churn.
- Guard every optional API (`has :method`) and every nullable read (HR, history) so a missing value never crashes the face.

## Build and test

Steps in `docs/BUILD.md`. Summary: VS Code + Monkey C extension + Connect IQ SDK, run in the FR245M simulator, then sideload the `.prg` over USB. Before calling anything done, exercise these states in the simulator: morning vs late day, goal hit vs missed, empty first-run history, week rollover (Sunday into Monday), and the always-on low-power redraw.

## Definition of done

1. Compiles clean for `forerunner245m` with no warnings you have not consciously accepted.
2. Renders the SPEC layout legibly at 240x240, matching DESIGN proportions.
3. Weekly bars are correct across a week rollover and a fresh install with no history.
4. Streak increments, holds, and resets correctly using only today's step count.
5. No per-minute crashes across the test states above. Battery behavior is sane (no always-on seconds by default).

## Status of the code in this repo

The `.mc` files are a considered first pass written without a compiler. Treat them as a strong starting point, not verified truth. Expect to fix Monkey C syntax or API-signature details against the SDK and simulator. The design intent in `docs/` is the source of truth. If code and docs disagree, the docs win and the code is the bug.

## Do not

- Do not add seconds, weather, notifications, music, or extra complications without an explicit instruction.
- Do not introduce bitmaps, animations, or anything that costs battery for vanity.
- Do not pedestal `getHistory()`. The self-logged week is the reliable path.
- Do not let the layout drift from DESIGN. Elegance is the product.
