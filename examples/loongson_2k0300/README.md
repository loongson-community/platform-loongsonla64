How to build PlatformIO based project
===

Preparing the essentials
---

1. [Install PlatformIO Core](https://docs.platformio.org/page/core.html)
2. Download [development platform with examples](https://github.com/platformio/platform-loongsonla64/archive/develop.zip)
3. Extract ZIP archive

Building the example project
---

This example is designed to be built directly on an x86-64 device running
GNU/Linux via cross-compilation.

```shell
# Change directory to example
$ cd platform-loongsonla64/examples/loongson_2k0300

# Build project
$ pio run

# Upload firmware
$ pio run --target upload

# Build specific environment
$ pio run -e maple

# Upload firmware for the specific environment
$ pio run -e maple --target upload

# Clean build files
$ pio run --target clean
```
