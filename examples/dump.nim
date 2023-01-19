import sensors
import strformat

init()

for chip in chips():
  echo fmt"{chip.name}: {chip.prefix}"
  for feature in chip:
    echo fmt"  {feature.label:<35} ({feature.kind})"
    for subfeature in feature:
      echo fmt"    {subfeature.name}: {subfeature.value:<20} ({subfeature.kind})"

