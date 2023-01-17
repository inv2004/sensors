
const libSensors = "libsensors.so"


type
  Bus = object
    typ, nr: int16
  SensorChip = ptr object
    prefix: cstring
    bus: Bus
    addrr: int32
    path: cstring
  SensorFeatureKind {.size: sizeof(cint), pure.} = enum
    FeatureIn = 0x00
    FeatureFan = 0x01
    FeatureTemp = 0x02
    FeaturePower = 0x03
    FeatureEnergy = 0x04
    FeatureCurr = 0x05
    FeatureHumidity = 0x06
    FeatureMaxMain = 0x07
    FeatureVid = 0x10
    FeatureIntrusion = 0x11
    FeatureMaxOther = 0x12
    FeatureBeepEnable = 0x18
    FeatureMax = 0x19
  SensorSubfeatureKind {.size: sizeof(cint), pure.} = enum
    SubfeatureTempInput = int(FeatureTemp) shl 8
  SensorFeature = ptr object
    name: cstring
    number: int32
    kind: SensorFeatureKind
    first_subfeature: int32
    padding1: int32
  SensorSubfeature = ptr object
    name: cstring
    number: int32
    kind: SensorSubfeatureKind
    mapping: int32
    flags: uint32
  SensorsException* = object of ValueError
    errCode*: int

proc sensors_init(p: typeof(nil)): int {.cdecl, dynlib: libSensors,
    importc: "sensors_init".}

proc sensors_get_detected_chips*(p: typeof(nil),
    nr: var int): SensorChip {.cdecl, dynlib: libSensors,
    importc: "sensors_get_detected_chips".}

proc sensors_snprintf_chip_name*(buf: pointer, size: int,
    chip: SensorChip): int {.cdecl, dynlib: libSensors,
    importc: "sensors_snprintf_chip_name".}

proc sensors_get_features*(chip: SensorChip,
    fnr: var int): SensorFeature {.cdecl, dynlib: libSensors,
    importc: "sensors_get_features".}

proc sensors_get_label*(chip: SensorChip,
    feature: SensorFeature): cstring {.cdecl, dynlib: libSensors,
    importc: "sensors_get_label".}

proc sensors_get_subfeature*(chip: SensorChip,
    feature: SensorFeature): cstring {.cdecl, dynlib: libSensors,
    importc: "sensors_get_label".}

proc sensors_get_subfeature*(chip: SensorChip, feature: SensorFeature,
    kind: SensorSubfeatureKind): SensorSubfeature {.cdecl, dynlib: libSensors,
    importc: "sensors_get_subfeature".}

proc sensors_get_value(chip: SensorChip, nr: int,
    value: var float64): int {.cdecl, dynlib: libSensors,
    importc: "sensors_get_value".}

proc newSensorsException*(err: int, msg = ""): ref SensorsException =
  new(result)
  result.errCode = err
  result.msg = msg & " with error code " & $err

template checkErr*(body: untyped): untyped =
  let err = body
  if err != 0:
    raise newSensorsException(err, "sensors failed")

when isMainModule:
  proc main() =
    checkErr sensors_init(nil)
    var nr = 0
    var buf = ""
    while true:
      let chip = sensors_get_detected_chips(nil, nr)
      if chip == nil:
        break
      buf.setLen 255
      buf.setLen sensors_snprintf_chip_name(buf[0].addr, len(buf), chip)
      echo buf, ": ", chip.prefix
      var fnr = 0
      while true:
        let f = sensors_get_features(chip, fnr)
        if f == nil:
          break
        let label = sensors_get_label(chip, f)
        echo "  ", f.name, " type: ", f.kind, " label: ", $label
        let sf = sensors_get_subfeature(chip, f, SubfeatureTempInput)
        if sf == nil:
          continue
        var value: float64
        discard sensors_get_value(chip, sf.number, value)
        echo "     ", sf.number, ": ", sf.name, ": ", value, " type: ", sf.kind

  main()

