import sensors/bindings

import std/dynlib
import system/ansi_c

export SensorFeatureKind, SensorSubfeatureKind

type
  SensorFeature* = object
    feature: SensorFeaturePtr
    chip: SensorChip
  SensorSubfeature* = object
    subfeature: SensorSubfeaturePtr
    chip: SensorChip
  SensorsException* = object of ValueError
    errCode*: int

proc newSensorsException*(err: int, msg = ""): ref SensorsException =
  new(result)
  result.errCode = err
  result.msg = msg & " with error code " & $err

template checkErr*(body: untyped): untyped =
  let err = body
  if err != 0:
    raise newSensorsException(err, "sensors failed")

proc init*() =
  initLib()
  checkErr sensors_init(nil)

proc name*(chip: SensorChip): string =
  result.setLen 255
  result.setLen sensors_snprintf_chip_name(result[0].addr, len(result), chip)

iterator chips*(): SensorChip =
  var n = 0
  while true:
    let chip = sensors_get_detected_chips(nil, n)
    if chip == nil:
      break
    yield chip

proc chipWithPrefix*(prefix: string): SensorChip =
  for chip in chips():
    if chip.prefix == prefix:
      return chip
  raise newException(KeyError, "chip with prefix `" & prefix & "` not found")

proc name*(feature: SensorFeature): cstring =
  feature.feature.name

proc kind*(feature: SensorFeature): SensorFeatureKind =
  feature.feature.kind

proc label*(feature: SensorFeature): string =
  var cstr = sensors_get_label(feature.chip, feature.feature)
  result = $cstr
  c_free(cstr)

iterator features*(chip: SensorChip): SensorFeature =
  var n = 0
  while true:
    let feature = sensors_get_features(chip, n)
    if feature == nil:
      break
    yield SensorFeature(feature: feature, chip: chip)

iterator items*(chip: SensorChip): SensorFeature =
  for f in chip.features(): yield f

proc feature*(chip: SensorChip, kind: SensorFeatureKind): SensorFeature =
  for feature in chip.features():
    if feature.kind == kind:
      return feature
  raise newException(KeyError, "feature with kind `" & $kind & "` not found")

proc subfeature*(feature: SensorFeature,
    kind: SensorSubfeatureKind): SensorSubfeature =
  result.subfeature = sensors_get_subfeature(feature.chip, feature.feature, kind)
  if result.subfeature == nil:
    raise newException(KeyError, "subfeature with kind `" & $kind & "` not found")
  result.chip = feature.chip

iterator subfeatures*(feature: SensorFeature): SensorSubfeature =
  var n = 0
  while true:
    let subfeature = sensors_get_all_subfeatures(feature.chip, feature.feature, n)
    if subfeature == nil:
      break
    yield SensorSubfeature(subfeature: subfeature, chip: feature.chip)

iterator items*(feature: SensorFeature): SensorSubFeature =
  for sf in feature.subfeatures(): yield sf

proc name*(subfeature: SensorSubfeature): cstring =
  subfeature.subfeature.name

proc kind*(subfeature: SensorSubFeature): SensorSubfeatureKind =
  subfeature.subfeature.kind

proc value*(subfeature: SensorSubfeature): float64 =
  if sensors_get_value(subfeature.chip, subfeature.subfeature.number, result) < 0:
    raise newException(ValueError, "sensor value failed")

proc cpuTemp*(): float64 =
  chipWithPrefix("coretemp").feature(FeatureTemp).subfeature(
      SubfeatureTempInput).value

proc nvmeTemp*(): float64 =
  chipWithPrefix("nvme").feature(FeatureTemp).subfeature(
      SubfeatureTempInput).value

