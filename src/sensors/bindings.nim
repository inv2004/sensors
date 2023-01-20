import std/dynlib

const libSensorsPattern = "libsensors.(so|so.5)"

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
type
  SensorFeatureKind* {.size: sizeof(cint), pure.} = enum
    FEATURE_IN = 0x00, FEATURE_FAN = 0x01,
    FEATURE_TEMP = 0x02, FEATURE_POWER = 0x03,
    FEATURE_ENERGY = 0x04, FEATURE_CURR = 0x05,
    FEATURE_HUMIDITY = 0x06, FEATURE_MAX_MAIN,
    FEATURE_VID = 0x10, FEATURE_INTRUSION = 0x11,
    FEATURE_MAX_OTHER, FEATURE_BEEP_ENABLE = 0x18,
    FEATURE_MAX, FEATURE_UNKNOWN = cint.high
  SensorSubfeatureKind* {.size: sizeof(cint), pure.} = enum
    SUBFEATURE_IN_INPUT = FEATURE_IN.cint shl 8,
    SUBFEATURE_IN_MIN, SUBFEATURE_IN_MAX,
    SUBFEATURE_IN_LCRIT, SUBFEATURE_IN_CRIT,
    SUBFEATURE_IN_AVERAGE, SUBFEATURE_IN_LOWEST,
    SUBFEATURE_IN_HIGHEST,
    SUBFEATURE_IN_ALARM = (FEATURE_IN.cint shl 8) or 0x80,
    SUBFEATURE_IN_MIN_ALARM, SUBFEATURE_IN_MAX_ALARM,
    SUBFEATURE_IN_BEEP, SUBFEATURE_IN_LCRIT_ALARM,
    SUBFEATURE_IN_CRIT_ALARM,
    SUBFEATURE_FAN_INPUT = FEATURE_FAN.cint shl 8,
    SUBFEATURE_FAN_MIN, SUBFEATURE_FAN_MAX,
    SUBFEATURE_FAN_ALARM = (FEATURE_FAN.cint shl 8) or 0x80,
    SUBFEATURE_FAN_FAULT, SUBFEATURE_FAN_DIV,
    SUBFEATURE_FAN_BEEP, SUBFEATURE_FAN_PULSES,
    SUBFEATURE_FAN_MIN_ALARM, SUBFEATURE_FAN_MAX_ALARM,
    SUBFEATURE_TEMP_INPUT = FEATURE_TEMP.cint shl 8,
    SUBFEATURE_TEMP_MAX, SUBFEATURE_TEMP_MAX_HYST,
    SUBFEATURE_TEMP_MIN, SUBFEATURE_TEMP_CRIT,
    SUBFEATURE_TEMP_CRIT_HYST, SUBFEATURE_TEMP_LCRIT,
    SUBFEATURE_TEMP_EMERGENCY, SUBFEATURE_TEMP_EMERGENCY_HYST,
    SUBFEATURE_TEMP_LOWEST, SUBFEATURE_TEMP_HIGHEST,
    SUBFEATURE_TEMP_MIN_HYST, SUBFEATURE_TEMP_LCRIT_HYST,
    SUBFEATURE_TEMP_ALARM = (FEATURE_TEMP.cint shl 8) or 0x80,
    SUBFEATURE_TEMP_MAX_ALARM, SUBFEATURE_TEMP_MIN_ALARM,
    SUBFEATURE_TEMP_CRIT_ALARM, SUBFEATURE_TEMP_FAULT,
    SUBFEATURE_TEMP_TYPE, SUBFEATURE_TEMP_OFFSET,
    SUBFEATURE_TEMP_BEEP, SUBFEATURE_TEMP_EMERGENCY_ALARM,
    SUBFEATURE_TEMP_LCRIT_ALARM,
    SUBFEATURE_POWER_AVERAGE = FEATURE_POWER.cint shl 8,
    SUBFEATURE_POWER_AVERAGE_HIGHEST,
    SUBFEATURE_POWER_AVERAGE_LOWEST, SUBFEATURE_POWER_INPUT,
    SUBFEATURE_POWER_INPUT_HIGHEST,
    SUBFEATURE_POWER_INPUT_LOWEST, SUBFEATURE_POWER_CAP,
    SUBFEATURE_POWER_CAP_HYST, SUBFEATURE_POWER_MAX,
    SUBFEATURE_POWER_CRIT, SUBFEATURE_POWER_MIN,
    SUBFEATURE_POWER_LCRIT, SUBFEATURE_POWER_AVERAGE_INTERVAL = (
        FEATURE_POWER.cint shl 8) or 0x80, SUBFEATURE_POWER_ALARM,
    SUBFEATURE_POWER_CAP_ALARM, SUBFEATURE_POWER_MAX_ALARM,
    SUBFEATURE_POWER_CRIT_ALARM, SUBFEATURE_POWER_MIN_ALARM,
    SUBFEATURE_POWER_LCRIT_ALARM,
    SUBFEATURE_ENERGY_INPUT = FEATURE_ENERGY.cint shl 8,
    SUBFEATURE_CURR_INPUT = FEATURE_CURR.cint shl 8,
    SUBFEATURE_CURR_MIN, SUBFEATURE_CURR_MAX,
    SUBFEATURE_CURR_LCRIT, SUBFEATURE_CURR_CRIT,
    SUBFEATURE_CURR_AVERAGE, SUBFEATURE_CURR_LOWEST,
    SUBFEATURE_CURR_HIGHEST,
    SUBFEATURE_CURR_ALARM = (FEATURE_CURR.cint shl 8) or 0x80,
    SUBFEATURE_CURR_MIN_ALARM, SUBFEATURE_CURR_MAX_ALARM,
    SUBFEATURE_CURR_BEEP, SUBFEATURE_CURR_LCRIT_ALARM,
    SUBFEATURE_CURR_CRIT_ALARM,
    SUBFEATURE_HUMIDITY_INPUT = FEATURE_HUMIDITY.cint shl 8,
    SUBFEATURE_VID = FEATURE_VID.cint shl 8,
    SUBFEATURE_INTRUSION_ALARM = FEATURE_INTRUSION.cint shl 8,
    SUBFEATURE_INTRUSION_BEEP,
    SUBFEATURE_BEEP_ENABLE = FEATURE_BEEP_ENABLE.cint shl 8,
    SUBFEATURE_UNKNOWN = cint.high
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
var sensors_get_all_subfeatures*: proc(chip: SensorChip,
    feature: SensorFeaturePtr, nr: var int): SensorSubfeaturePtr {.cdecl.}
var sensors_get_value*: proc(chip: SensorChip, nr: int,
    value: var float64): int {.cdecl.}

template setProc(name: untyped) =
  name = cast[typeof(name)](lib.symAddr(name.astToStr))
  doAssert name != nil

proc initLib*() =
  let lib = loadLibPattern(libSensorsPattern)
  if lib == nil:
    raise newException(LibraryError, libSensorsPattern)
  setProc(sensors_init)
  setProc(sensors_get_detected_chips)
  setProc(sensors_snprintf_chip_name)
  setProc(sensors_get_features)
  setProc(sensors_get_label)
  setProc(sensors_get_subfeature)
  setProc(sensors_get_all_subfeatures)
  setProc(sensors_get_value)
