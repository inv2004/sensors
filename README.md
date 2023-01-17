# sensors
[libsensors](https://github.com/lm-sensors/lm-sensors) wrapper

- [x] dynamic load and check of libsensors.so

#### Example
https://github.com/inv2004/sensors/blob/main/examples/dump.nim

```bash
coretemp-isa-0000: coretemp
  Package id 0: 40.0
  Core 0: 39.0
  Core 1: 40.0
thinkpad-isa-0000: thinkpad
  CPU: 34.0
  GPU: 0.0
  temp3: 0.0
  temp4: 0.0
  temp5: 0.0
  temp6: 0.0
  temp7: 0.0
  temp8: 0.0
nvme-pci-0500: nvme
  Composite: 23.85
BAT0-acpi-0: BAT0
iwlwifi_1-virtual-0: iwlwifi_1
  temp1: 28.0
pch_skylake-virtual-0: pch_skylake
  temp1: 33.0
BAT1-acpi-0: BAT1
acpitz-acpi-0: acpitz
  temp1: 34.0
```

#### Helpers example
```nim
import sensors

init()

echo cpuTemp()
echo ssdTemp()
```
