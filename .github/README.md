# CrossPoint Reader — Waveshare ESP32-S3-ePaper-3.97 fork

This is an unofficial fork of [CrossPoint Reader](https://github.com/crosspoint-reader/crosspoint-reader) that adds support for the
**Waveshare ESP32-S3-ePaper-3.97** board.

All reader features come from upstream CrossPoint. This fork only adds the build environments and board identification needed for
the Waveshare 3.97 hardware, and is rebased onto each upstream release tag. For the full feature list, documentation and
contribution guidelines, see the [upstream README](../README.md) and the
[upstream project](https://github.com/crosspoint-reader/crosspoint-reader).

> This fork is not affiliated with or supported by the CrossPoint maintainers. Please report Waveshare 3.97 issues
> [here](https://github.com/corradoignoti/crosspoint-reader/issues), not upstream.

## What this fork changes

- `[env:ws397]` — development build (serial logging, `LOG_LEVEL=2`)
- `[env:ws397-gh_release]` — release build (`LOG_LEVEL=1`)
- Both environments live in `platformio.ws397.ini`, loaded through `extra_configs` in `platformio.ini`
- `FREEINK_DEVICE_WS397` board tag (`ws397`)
- CrossShare branding: the device, web UI, hotspot (`CrossShare`), DHCP hostname (`CrossShare-<MAC>`) and USB name show
  CrossShare and its logo (source: `src/images/cross-share_logo.svg`). The web address stays `http://crosspoint.local`.
  Upstream docs that mention the `CrossPoint-Reader` hotspot or the CrossPoint logo apply with that substitution.

Target hardware: ESP32-S3 with 16 MB flash and 8 MB OPI PSRAM, SD card on 4-bit SDMMC.

Release versions follow upstream with a `-ws397` suffix, e.g. `1.6.5-ws397` is based on upstream `1.6.5`. Fork-only
revisions on the same upstream base add `.N`, e.g. `1.6.5-ws397.1`. Ports of upstream release candidates are published as
GitHub prereleases (e.g. `2.0.0rc-ws397`), so OTA does not offer them; install those over USB.

## Install

### From your browser

You can flash this firmware directly from your browser. Connect the board via USB-C and go to
https://cross-share.fizban.net/.

### From a release

Download `crosspoint-<version>.bin` (e.g. `crosspoint-2.0.0rc-ws397.bin`) from [Releases](https://github.com/corradoignoti/crosspoint-reader/releases).

The release file is the application image only. On a board that already runs a CrossPoint build with the same partition
table, flash it to `app0` and reset the OTA selector so the board boots from it:

```bash
esptool.py --chip esp32s3 erase_region 0xe000 0x2000
esptool.py --chip esp32s3 write_flash 0x10000 crosspoint-<version>.bin
```

On a blank board, or if unsure, build from source instead (below); `pio run -t upload` also writes the bootloader and
partition table.

### From source

```bash
git clone --recursive https://github.com/corradoignoti/crosspoint-reader.git
cd crosspoint-reader
pio run -e ws397-gh_release -t upload
```

## Updates

The on-device OTA update checks this fork's latest release (prereleases are skipped) and installs its
`crosspoint-<version>.bin` asset. A release candidate build is offered the final release of the same version. Builds older
than `1.6.5-ws397.1` check upstream instead, which has no Waveshare 3.97 build; update those over USB as described above.

## Maintaining the port

The fork is a patch stack: `ws397` is an upstream release tag plus the fork-only commits on top
(`git log --oneline <tag>..ws397`). Upstream is never merged into `ws397`; each new upstream tag gets the stack replayed onto it.

Branches:

- `ws397` — default branch, current tag + stack. New work lands here.
- `release/<tag>-ws397` — snapshot of each port, tagged `<tag>-ws397`.
- `develop`, `master` — untouched upstream mirrors.

New change: branch `wip/<topic>` off `ws397`, commit, build with `pio run -e ws397`, test on hardware, then
`git switch ws397 && git merge --ff-only wip/<topic>`.

Porting to a new upstream tag (needs an `upstream` remote and `git config rerere.enabled true` so repeated conflicts resolve themselves):

```bash
scripts/port-to-tag.sh <new-tag>
```

It creates `release/<new-tag>-ws397`, cherry-picks the stack, builds `ws397-gh_release` and prints the remaining steps. It never pushes.

Keeping the stack easy to replay:

- One concern per commit, so a conflicting change can be fixed or dropped on its own.
- Prefer new files over edits to upstream files. Build environments go in `platformio.ws397.ini`, not `platformio.ini`.
- When an upstream file must change, keep the hunk small and gate it with `#if defined(FREEINK_DEVICE_WS397)`.
- Never edit the root `README.md`.
- After a port, search for new upstream "CrossPoint Reader" UI text and rename it to CrossShare. Keep compatibility
  names: `crosspoint.local`, the OTA asset name, `window.CrossPoint` and the `.crosspoint` SD folder. UI branding is
  not gated by `FREEINK_DEVICE_WS397`, because generated HTML and image assets cannot be gated.
- Avoid freeink-sdk changes; if unavoidable, fork the SDK and point the submodule at it in its own commit.

## Credits

All credit for CrossPoint goes to the [CrossPoint contributors](https://github.com/crosspoint-reader/crosspoint-reader/graphs/contributors).
Consider [funding them](https://app.royalty.dev/crosspoint-reader/crosspoint-reader).
