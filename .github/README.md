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
- `FREEINK_DEVICE_WS397` board tag (`ws397`)

Target hardware: ESP32-S3 with 16 MB flash and 8 MB OPI PSRAM, SD card on 4-bit SDMMC.

Release versions follow upstream with a `-ws397` suffix, e.g. `1.6.5-ws397` is based on upstream `1.6.5`.

## Install

### From a release

Download `crosspoint-<version>-ws397.bin` from [Releases](https://github.com/corradoignoti/crosspoint-reader/releases).

The release file is the application image only. On a board that already runs a CrossPoint build with the same partition
table, flash it to `app0` and reset the OTA selector so the board boots from it:

```bash
esptool.py --chip esp32s3 erase_region 0xe000 0x2000
esptool.py --chip esp32s3 write_flash 0x10000 crosspoint-<version>-ws397.bin
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

**Do not use the on-device OTA update.** It checks upstream releases, which do not include a Waveshare 3.97 build. Update by
flashing a new fork release over USB as described above.

## Credits

All credit for CrossPoint goes to the [CrossPoint contributors](https://github.com/crosspoint-reader/crosspoint-reader/graphs/contributors).
Consider [funding them](https://app.royalty.dev/crosspoint-reader/crosspoint-reader).
