import unittest

import sensors

test "chips":
  for chip in chips():
    echo chip.name, ": ", chip.prefix

test "prefix":
  echo chipWithPrefix("coretemp").name
  expect KeyError:
    echo chipWithPrefix("ccoretemp").name

test "feature":
  for chip in chips():
    for feature in chip.features():
      echo feature.label

test "kind":
  echo chipWithPrefix("coretemp").feature(FeatureTemp).name

test "subfeature":
  echo chipWithPrefix("coretemp").feature(FeatureTemp).subfeature(
      SubfeatureTempInput).name

test "value":
  echo chipWithPrefix("coretemp").feature(FeatureTemp).subfeature(
      SubfeatureTempInput).value

