# High-level ColorSource API (gradients, images, fragment programs)
import ./bindings/impeller_api
import ./displaylist
import ./texture

export texture

type
  ColorSource* = object
    handle*: ImpellerColorSource

proc `=destroy`*(c: ColorSource) =
  if c.handle != nil: ImpellerColorSourceRelease(c.handle)
proc `=copy`*(dst: var ColorSource, src: ColorSource) {.error: "ColorSource cannot be copied".}
proc isNil*(c: ColorSource): bool {.inline.} = c.handle == nil

proc checkStops(colors: openArray[ImpellerColor], stops: openArray[cfloat]) =
  assert colors.len == stops.len, "colors and stops must have equal length"
  assert colors.len >= 2, "gradients need at least 2 stops"

proc linearGradient*(start, stop: ImpellerPoint,
    colors: openArray[ImpellerColor], stops: openArray[cfloat],
    tile: ImpellerTileMode = kImpellerTileModeClamp,
    matrix: var ImpellerMatrix): ColorSource =
  checkStops(colors, stops)
  var a = start
  var b = stop
  ColorSource(handle: ImpellerColorSourceCreateLinearGradientNew(
    addr a, addr b, uint32(colors.len),
    unsafeAddr colors[0], unsafeAddr stops[0], tile, addr matrix))

proc linearGradient*(start, stop: ImpellerPoint,
    colors: openArray[ImpellerColor], stops: openArray[cfloat],
    tile: ImpellerTileMode = kImpellerTileModeClamp): ColorSource =
  var m = identityMatrix()
  linearGradient(start, stop, colors, stops, tile, m)

proc radialGradient*(center: ImpellerPoint, radius: float32,
    colors: openArray[ImpellerColor], stops: openArray[cfloat],
    tile: ImpellerTileMode = kImpellerTileModeClamp): ColorSource =
  checkStops(colors, stops)
  var c = center
  var m = identityMatrix()
  ColorSource(handle: ImpellerColorSourceCreateRadialGradientNew(
    addr c, radius.cfloat, uint32(colors.len),
    unsafeAddr colors[0], unsafeAddr stops[0], tile, addr m))

proc conicalGradient*(startCenter: ImpellerPoint, startRadius: float32,
    endCenter: ImpellerPoint, endRadius: float32,
    colors: openArray[ImpellerColor], stops: openArray[cfloat],
    tile: ImpellerTileMode = kImpellerTileModeClamp): ColorSource =
  checkStops(colors, stops)
  var a = startCenter
  var b = endCenter
  var m = identityMatrix()
  ColorSource(handle: ImpellerColorSourceCreateConicalGradientNew(
    addr a, startRadius.cfloat, addr b, endRadius.cfloat,
    uint32(colors.len), unsafeAddr colors[0], unsafeAddr stops[0],
    tile, addr m))

proc sweepGradient*(center: ImpellerPoint, start, stop: float32,
    colors: openArray[ImpellerColor], stops: openArray[cfloat],
    tile: ImpellerTileMode = kImpellerTileModeClamp): ColorSource =
  checkStops(colors, stops)
  var c = center
  var m = identityMatrix()
  ColorSource(handle: ImpellerColorSourceCreateSweepGradientNew(
    addr c, start.cfloat, stop.cfloat, uint32(colors.len),
    unsafeAddr colors[0], unsafeAddr stops[0], tile, addr m))

proc imageSource*(t: Texture,
    hTile: ImpellerTileMode = kImpellerTileModeClamp,
    vTile: ImpellerTileMode = kImpellerTileModeClamp,
    sampling: ImpellerTextureSampling = kImpellerTextureSamplingLinear): ColorSource =
  var m = identityMatrix()
  ColorSource(handle: ImpellerColorSourceCreateImageNew(
    t.handle, hTile, vTile, sampling, addr m))
