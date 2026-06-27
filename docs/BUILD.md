# Stride: build, run, and sideload

## Prerequisites (macOS, via Homebrew)

```sh
brew install --cask connectiq          # SDK + monkeyc, monkeydo, simulator
brew install openjdk                   # JDK that monkeyc needs
# JAVA_HOME (persisted in ~/.zshrc):
export JAVA_HOME="$(/usr/libexec/java_home 2>/dev/null || echo /opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home)"
```

A developer signing key (once, no Garmin login needed):
```sh
mkdir -p ~/.Garmin
openssl genrsa -out ~/.Garmin/developer_key.pem 4096
openssl pkcs8 -topk8 -inform PEM -outform DER -nocrypt \
  -in ~/.Garmin/developer_key.pem -out ~/.Garmin/developer_key.der
```

**Device definitions** are the one account-gated step: `brew install --cask connectiq-sdk-manager`, open it, sign in with a Garmin account, and download **Forerunner 245 Music** (and Forerunner 245). They land in `~/Library/Application Support/Garmin/ConnectIQ/Devices/` as `fr245m` / `fr245`. Until then `monkeyc -d fr245m` errors with "Invalid device id".

VS Code with the official Monkey C extension also works; point it at `~/.Garmin/developer_key.der`.

## Build

```sh
# debug build for the simulator:
monkeyc -f monkey.jungle -d fr245m -y ~/.Garmin/developer_key.der -o bin/Stride.prg -w
# release build for the device (smaller, debug stripped):
monkeyc -f monkey.jungle -d fr245m -y ~/.Garmin/developer_key.der -o bin/Stride.prg -r -w
```

Keep it warning-clean (`-w`). The device id is `fr245m` (not `forerunner245m`); the manifest products match.

## Run in the simulator

```sh
connectiq &                            # launches the simulator (from the SDK bin)
monkeydo bin/Stride.prg fr245m         # loads the face onto it
```

Set `StepHistory.DEMO = true` to see the bars populated — the simulator can't backfill history, so otherwise only today's bar fills. To judge real states, use the simulator's **Simulation → Activity Monitoring** to set steps, and **Settings → Set Weather** etc. The simulator's dialogs are Qt and not scriptable; capture with **File → Save Screen Capture**.

## Sideload to the watch (FR245 Music = MTP)

The 245 **Music** connects over MTP, not USB mass storage, so it never mounts as a `GARMIN` drive in Finder. Use the helper in `tools/`:

```sh
brew install libmtp
cc tools/mtpsend.c -I"$(brew --prefix libmtp)/include" -L"$(brew --prefix libmtp)/lib" -lmtp -o tools/mtpsend
# Quit Garmin Express AND kill its background service first — it claims
# exclusive USB ownership: pkill -f "Garmin Express"
mtp-folders                            # find the GARMIN/APPS folder id
./tools/mtpsend bin/Stride.prg Stride.PRG <APPS_folder_id>
```

Then unplug the watch and pick Stride from the watch-face list (hold UP/MENU → Watch Face). The non-music FR245 mounts as a normal drive — just copy to `GARMIN/Apps/`.

## Test matrix (do not skip)

| State                       | What to check                                          |
|-----------------------------|--------------------------------------------------------|
| Morning, low steps          | today's bar short and red, corner step count low       |
| Late day, near goal         | today's bar near the 100% line                         |
| Goal reached                | today's bar at the top line                            |
| Fresh install, empty days   | older days are flat stubs, looks intentional           |
| Day rollover (midnight)     | window slides, yesterday freezes, today resets to 0    |
| 12h and 24h clock           | hour formatting correct in both; no AM/PM glyph        |
| Bottom row partial          | a null metric is omitted and the row recenters         |
| Daylight / sunlight mode    | contrast holds                                         |
| Accent changed in settings  | today's bar and date number update on next render      |
| Low-power redraw            | once-per-minute, no flicker, no seconds                |

## Memory check

After it builds, confirm watch-face memory is comfortably under the FR245M 96 KB budget (the release `.prg` is ~12 KB plus the two small font atlases). If it ever runs close, the day-number font goes first.
