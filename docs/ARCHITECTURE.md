# Stride: architecture

## Files

| File                    | Responsibility                                              |
|-------------------------|-------------------------------------------------------------|
| `source/StrideApp.mc`   | `AppBase`. Returns the view. Repaints on settings change.   |
| `source/StrideView.mc`  | The `WatchFace`. All layout and drawing. The only big file. |
| `source/Theme.mc`       | Color constants and the accent lookup.                      |
| `source/StepHistory.mc` | Self-logged Monday-to-Sunday step model.                    |
| `source/Streak.mc`      | Consecutive-10k-day streak.                                 |

Keep the split. The view draws; the modules own state and math. Do not move persistence into the view.

## Render flow (`onUpdate`)

1. Read settings: step goal, accent, secondary toggle.
2. Clear to black.
3. Compute time, date, and the local day number.
4. Read today's steps from `ActivityMonitor.getInfo()`.
5. Update the weekly model and the streak (both persist).
6. Draw, in order: rim arc, date, time, steps pair, streak pill, week bars, optional secondary.

`onUpdate` runs once per minute in low-power mode. Keep it allocation-light. `onPartialUpdate` is a deliberate no-op; seconds are off by default to protect the 7-day battery.

## Time and day math

- Local day number: `(Time.now().value() + ClockTime.timeZoneOffset) / 86400`. A whole-day index in the wearer's time zone. Used as the key for both streak and week.
- Monday-based weekday index: `(dayNumber + 3) % 7`. Epoch day 0 (1970-01-01) was a Thursday, which is index 3 when Monday is 0. Verified: dayNumber 0 gives 3.
- Week start (this week's Monday): `dayNumber - weekdayIndex`.

## Storage schema

Two keys in `Application.Storage`.

`"week"`:
```
{ "start" => <dayNumber of this week's Monday>,
  "days"  => [m, t, w, t, f, s, s] }   // 7 step totals, Monday first
```
On each render: if the stored `start` matches this week's Monday, reuse `days`; otherwise begin a fresh week of zeros. Then overwrite today's slot with the live step count and save. Past days retain the last value written while they were "today", i.e. their end-of-day total.

`"streak"`:
```
{ "lastHit" => <dayNumber of the most recent 10k day>,
  "count"   => <consecutive count> }
```
On each render: if today's steps reached goal and today is not already counted, increment when yesterday was the last hit, else reset to 1, and record today. The displayed streak is the count only if the last hit was today or yesterday; otherwise 0 (lapsed).

This design needs only today's step count. It never depends on a stored previous-day total, which is what makes it robust.

## Why self-logged steps, not getHistory

`ActivityMonitor.getHistory()` exists and can return up to 7 days, but its depth is device- and state-dependent and can be shallow (empty after a reboot, partial otherwise). For a feature as central as the week bars, that is too soft a foundation. Self-logging the current week from the live count is deterministic and simple. If you later confirm `getHistory()` is reliable on the FR245M, you may use it to backfill a fresh install's earlier days, but the self-logged store stays the primary source.

## Things to verify against the SDK and simulator

- `minApiLevel` in the manifest actually matches the FR245M device entry. Adjust if the build complains.
- `drawArc` direction and the negative end-angle for the progress ring. Confirm it sweeps clockwise from 12 o'clock and fills correctly at 1%, 50%, 99%, 100%.
- `fillRoundedRectangle` / `drawRoundedRectangle` signatures.
- `getTextWidthInPixels` for the centered steps pair and pill sizing.
- Storage of a Dictionary and an Array round-trips as written.
- Heart rate read path. `Activity.getActivityInfo().currentHeartRate` may be null on a watch face; if so, fall back to the newest `SensorHistory` sample, still guarded.
- Memory headroom from the device XML. Stay comfortably under the watch-face budget.
