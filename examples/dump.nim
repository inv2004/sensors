import sensors
import strformat

init()

for chip in chips():
  echo fmt"{chip.name}: {chip.prefix}"
  for feature in chip.features():
    try:
      let subfeature = feature.subfeature(SubfeatureTempInput)
      echo fmt"  {feature.label}: {subfeature.value}"
    except KeyError:
      discard

