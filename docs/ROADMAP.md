# Stride: build roadmap

Phases for Claude Code. The design is locked; this is execution order. Build and verify each phase in the simulator before moving on.

## Phase 0: toolchain (your machine)

Install the Connect IQ SDK, the VS Code Monkey C extension, and a developer key. Confirm an empty build runs the FR245M simulator. See BUILD.md.

## Phase 1: compile the scaffold

Open the repo, wire the developer key, and get it to build clean for `forerunner245m`. Fix any Monkey C syntax or API-signature issues in the first-pass source. Confirm a black screen with the time renders. Nothing else needs to be perfect yet.

## Phase 2: core layout

Bring up the rim arc, date, time, and the steps pair. Match the proportion table in DESIGN. Tune the y fractions in the simulator until the vertical rhythm is calm, then update DESIGN to match.

## Phase 3: weekly bars

Wire `StepHistory`. Verify the 7-bar band, the goal line, today's bar in accent, future stubs, and a fresh-install empty week. Test a simulated week rollover.

## Phase 4: coaching layer

Wire `Streak` and the pill logic. Verify increment, hold, and reset using only today's step count. Confirm the pill priority: "10k done", then "N day streak", then "N to go".

## Phase 5: secondary, optional

Heart rate and battery, behind the ShowSecondary setting, default off. Guard the HR read so a null never crashes the face.

## Phase 6: polish and verify

Run the full BUILD test matrix. Check memory headroom. Confirm no always-on seconds and sane battery behavior. Sideload to the FR245M and read it in real sunlight.

## Later, only if wanted

Custom numeral font for the time (memory permitting). A companion widget for an active 6pm nudge. Neither is part of v1.
