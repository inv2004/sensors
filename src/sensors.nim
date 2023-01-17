import sensors/bindings
export SensorFeatureKind, SensorSubfeatureKind

checkErr sensors_init(nil)

type
  SensorFeature* = object
    feature: SensorFeaturePtr
    chip: SensorChip
  SensorSubfeature* = object
    subfeature: SensorSubfeaturePtr
    chip: SensorChip

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

proc label*(feature: SensorFeature): cstring =
  return sensors_get_label(feature.chip, feature.feature)

iterator features*(chip: SensorChip): SensorFeature =
  var n = 0
  while true:
    let feature = sensors_get_features(chip, n)
    if feature == nil:
      break
    yield SensorFeature(feature: feature, chip: chip)

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

proc name*(subfeature: SensorSubfeature): cstring =
  subfeature.subfeature.name

proc kind*(subfeature: SensorSubFeature): SensorSubfeatureKind =
  subfeature.subfeature.kind

proc value*(subfeature: SensorSubfeature): float64 =
  discard sensors_get_value(subfeature.chip, subfeature.subfeature.number, result)


