# Stride: architecture

## Files

| File                    | Responsibility                                                       |
|-------------------------|---------------------------------------------------------------------|
| `source/StrideApp.mc`   | `AppBase`. Returns the view. Repaints on settings change.           |
| `source/StrideView.mc`  | The `WatchFace`. Layout and composition; owns no persistence.       |
| `source/WeekChart.mc`   | The seven-day segmented chart: 10% blocks, goal-aware color, dashed goal line, numbered days. |
| `source/Metrics.mc`     | Guarded reads of the bottom-row metrics (recovery, BB, weather).    |
| `source/StepHistory.mc` | Self-logged rolling last-seven-days step model.                     |
| `source/Theme.mc`       | Grid-aligned color constants and the accent lookup.                 |
| `resources/fonts/`      | Four bitmap fonts: `LcdTime`/`LcdSmall` (DSEG7), `DayNum`/`Word` (Arial Narrow). |

The view draws and composes; the modules own state and math. Do not move persistence or sensor reads into the view.

Two modules from the earlier (teal, time-as-hero) concept were removed: `SevenSegment.mc` (a drawn vector 7-seg font, replaced by the real DSEG7 bitmap font) and `Streak.mc` (the streak is now read directly off the chart, not a separate pill).

## Render flow (`onUpdate`)

1. Read settings: step goal and accent.
2. Clear to black.
3. Compute `now`, the `FORMAT_SHORT` date, the clock, and the local day number.
4. Read today's steps and distance from `ActivityMonitor.getInfo()` (both null-guarded).
5. Update the rolling history (`StepHistory.lastSevenDays`, which persists).
6. Draw, in order: top metrics (steps, distance) → `WeekChart` → time + date → bottom row.

`onUpdate` runs once per minute in low-power mode. Keep it allocation-light. `onPartialUpdate` is a deliberate no-op; seconds stay off to protect battery.

## Time and day math

- **Local day number:** `(Time.now().value() + ClockTime.timeZoneOffset) / 86400` — a whole-day index in the wearer's time zone. The key for the rolling history.
- **Day-of-month labels:** for each of the last seven days, `Gregorian.info(now − offset·86400, FORMAT_SHORT).day`. Computed per render; cheap at once a minute.
- **Clock:** `is24Hour` from `DeviceSettings` decides formatting. No AM/PM indicator is drawn.

## Storage schema

One key in `Application.Storage`.

`"history"`:
```
{ "lastDay" => <local day number of the newest logged day>,
  "values"  => [d-6, d-5, d-4, d-3, d-2, d-1, today] }   // 7 step totals, oldest first
```

On each render the window slides forward by `today − lastDay` days (`shiftForward`), dropping old days off the front and zero-filling the new ones; a gap of 7 or more clears it. Then `values[6]` is overwritten with the live step count and the record is saved. Older slots retain the last value written while they were "today" — their end-of-day total. The model needs only today's live count, never a stored previous-day total, which is what makes it robust across reboots.

`StepHistory.DEMO` (a compile-time `const`) returns a fixed sample week instead, for judging the chart in the simulator, which cannot backfill real history. It must be `false` for device builds.

## Bottom-row metrics (`Metrics.mc`)

Every read is `has`-guarded and returns null on absence, so the view omits that readout:

- **Recovery:** `ActivityMonitor.Info.timeToRecovery` (hours; null until a recent activity).
- **Body Battery:** newest sample from `SensorHistory.getBodyBatteryHistory()` (requires the `SensorHistory` permission in the manifest).
- **Temperature:** `Weather.getCurrentConditions().temperature` (Celsius; null with no cached weather).

## Why self-logged steps, not getHistory

`ActivityMonitor.getHistory()` depth is device- and state-dependent and can be shallow (empty after a reboot, partial otherwise). For the central feature, that is too soft a foundation. Self-logging from the live count is deterministic. If `getHistory()` is later confirmed reliable on the FR245M, it could backfill a fresh install's earlier days, but the self-logged store stays primary.

## Things to keep verified against the SDK and simulator

- `minApiLevel` 3.3.0 matches the FR245M entry (it supports Weather and Body Battery history).
- The `SensorHistory` permission is present (Body Battery fails to compile without it).
- Custom fonts load via `Rez.Fonts.LcdTime` / `Rez.Fonts.DayNum`; the day font is lazy-loaded in `WeekChart`.
- `getTextWidthInPixels` for centering the time+date group and the corner readouts.
- Storage of a Dictionary and an Array round-trips as written.
- Memory headroom from the device XML — stay comfortably under the 96 KB watch-face budget (current release build is ~12 KB plus the small font atlases).
