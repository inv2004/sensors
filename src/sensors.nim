
const libSensors = "libsensors.so"

type SensorChip = pointer
type SensorFeature = pointer

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

type SensorsException* = object of ValueError
  errCode*: int

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
    var buf = newString(1000)
    while true:
      let chip = sensors_get_detected_chips(nil, nr)
      if chip == nil:
        break
      echo sensors_snprintf_chip_name(buf[0].addr, sizeof(buf), chip)
      echo nr, ": ", $buf
      var fnr = 0
      while true:
        let f = sensors_get_features(chip, fnr)
        if f == nil:
          break
        let label = sensors_get_label(chip, f)
        echo "  ", fnr, ": ", $label

  main()

