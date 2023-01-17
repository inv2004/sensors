import std/dynlib

const libSensors = "libsensors.so"

type
  Bus* = object
    typ*, nr*: int16
  SensorChipRef* = ref object
    prefix*: cstring
    bus*: Bus
    addrr*: int32
    path*: cstring
  SensorChip* = ptr object
    prefix*: cstring
    bus*: Bus
    addrr*: int32
    path*: cstring
  SensorFeatureKind* {.size: sizeof(cint), pure.} = enum
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
  SensorSubfeatureKind* {.size: sizeof(cint), pure.} = enum
    SubfeatureTempInput = int(FeatureTemp) shl 8
  SensorFeaturePtr* = ptr object
    name*: cstring
    number*: int32
    kind*: SensorFeatureKind
    first_subfeature*: int32
    padding1*: int32
  SensorSubfeaturePtr* = ptr object
    name*: cstring
    number*: int32
    kind*: SensorSubfeatureKind
    mapping*: int32
    flags*: uint32

var sensors_init*: proc(p: typeof(nil)): int {.cdecl.}
var sensors_get_detected_chips*: proc(p: SensorChip,
    nr: var int): SensorChip {.cdecl.}
var sensors_snprintf_chip_name*: proc(buf: pointer, size: int,
    chip: SensorChip): int {.cdecl.}
var sensors_get_features*: proc(chip: SensorChip,
    fnr: var int): SensorFeaturePtr {.cdecl.}
var sensors_get_label*: proc(chip: SensorChip,
    feature: SensorFeaturePtr): cstring {.cdecl.}
var sensors_get_subfeature*: proc(chip: SensorChip, feature: SensorFeaturePtr,
    kind: SensorSubfeatureKind): SensorSubfeaturePtr {.cdecl.}
var sensors_get_value*: proc(chip: SensorChip, nr: int,
    value: var float64): int {.cdecl.}

template setProc(name: untyped) =
  name = cast[typeof(name)](lib.symAddr(name.astToStr))
  doAssert name != nil

proc initLib*() =
  let lib = loadLib(libSensors)
  if lib == nil:
    raise newException(LibraryError, libSensors)
  setProc(sensors_init)
  setProc(sensors_get_detected_chips)
  setProc(sensors_snprintf_chip_name)
  setProc(sensors_get_features)
  setProc(sensors_get_label)
  setProc(sensors_get_subfeature)
  setProc(sensors_get_value)

when isMainModule:
  initLib()
  discard sensors_init(nil)
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


