# High-level Path API
import ./bindings/impeller_api

type
  Path* = object
    handle*: ImpellerPath
  PathBuilder* = object
    handle*: ImpellerPathBuilder

proc `=destroy`*(p: Path) =
  if p.handle != nil: ImpellerPathRelease(p.handle)
proc `=copy`*(dst: var Path, src: Path) {.error: "Path cannot be copied, use retain()".}
proc `=destroy`*(b: PathBuilder) =
  if b.handle != nil: ImpellerPathBuilderRelease(b.handle)
proc `=copy`*(dst: var PathBuilder, src: PathBuilder) {.error: "PathBuilder cannot be copied".}

proc isNil*(p: Path): bool {.inline.} = p.handle == nil
proc isNil*(b: PathBuilder): bool {.inline.} = b.handle == nil

proc newPathBuilder*(): PathBuilder =
  PathBuilder(handle: ImpellerPathBuilderNew())

proc retain*(p: Path): Path =
  ImpellerPathRetain(p.handle)
  Path(handle: p.handle)

proc getBounds*(p: Path): ImpellerRect =
  ImpellerPathGetBounds(p.handle, addr result)

proc moveTo*(b: PathBuilder, x, y: float32) =
  var pt = ImpellerPoint(x: x.cfloat, y: y.cfloat)
  ImpellerPathBuilderMoveTo(b.handle, addr pt)

proc lineTo*(b: PathBuilder, x, y: float32) =
  var pt = ImpellerPoint(x: x.cfloat, y: y.cfloat)
  ImpellerPathBuilderLineTo(b.handle, addr pt)

proc quadraticTo*(b: PathBuilder, cx, cy, ex, ey: float32) =
  var c = ImpellerPoint(x: cx.cfloat, y: cy.cfloat)
  var e = ImpellerPoint(x: ex.cfloat, y: ey.cfloat)
  ImpellerPathBuilderQuadraticCurveTo(b.handle, addr c, addr e)

proc cubicTo*(b: PathBuilder, c1x, c1y, c2x, c2y, ex, ey: float32) =
  var c1 = ImpellerPoint(x: c1x.cfloat, y: c1y.cfloat)
  var c2 = ImpellerPoint(x: c2x.cfloat, y: c2y.cfloat)
  var e = ImpellerPoint(x: ex.cfloat, y: ey.cfloat)
  ImpellerPathBuilderCubicCurveTo(b.handle, addr c1, addr c2, addr e)

proc addRect*(b: PathBuilder, r: ImpellerRect) =
  var rr = r
  ImpellerPathBuilderAddRect(b.handle, addr rr)

proc addRect*(b: PathBuilder, x, y, w, h: float32) =
  var r = ImpellerRect(x: x.cfloat, y: y.cfloat, width: w.cfloat, height: h.cfloat)
  ImpellerPathBuilderAddRect(b.handle, addr r)

proc addArc*(b: PathBuilder, oval: ImpellerRect, startDeg, endDeg: float32) =
  var o = oval
  ImpellerPathBuilderAddArc(b.handle, addr o, startDeg.cfloat, endDeg.cfloat)

proc addOval*(b: PathBuilder, oval: ImpellerRect) =
  var o = oval
  ImpellerPathBuilderAddOval(b.handle, addr o)

proc addOval*(b: PathBuilder, cx, cy, rx, ry: float32) =
  var o = ImpellerRect(x: (cx - rx).cfloat, y: (cy - ry).cfloat,
    width: (rx * 2).cfloat, height: (ry * 2).cfloat)
  ImpellerPathBuilderAddOval(b.handle, addr o)

proc addRoundedRect*(b: PathBuilder, r: ImpellerRect, radii: ImpellerRoundingRadii) =
  var rr = r
  var rad = radii
  ImpellerPathBuilderAddRoundedRect(b.handle, addr rr, addr rad)

proc uniformRadii*(radius: float32): ImpellerRoundingRadii =
  let p = ImpellerPoint(x: radius.cfloat, y: radius.cfloat)
  ImpellerRoundingRadii(top_left: p, bottom_left: p, top_right: p, bottom_right: p)

proc close*(b: PathBuilder) {.inline.} =
  ImpellerPathBuilderClose(b.handle)

proc copyPath*(b: PathBuilder, fill: ImpellerFillType = kImpellerFillTypeNonZero): Path =
  Path(handle: ImpellerPathBuilderCopyPathNew(b.handle, fill))

proc takePath*(b: PathBuilder, fill: ImpellerFillType = kImpellerFillTypeNonZero): Path =
  ## Takes the built path, leaving the builder empty and reusable.
  Path(handle: ImpellerPathBuilderTakePathNew(b.handle, fill))

proc buildCircle*(cx, cy, r: float32): Path =
  ## Convenience: circle path via oval builder.
  var b = newPathBuilder()
  b.addOval(cx, cy, r, r)
  result = b.takePath()

proc buildRect*(x, y, w, h: float32): Path =
  var b = newPathBuilder()
  b.addRect(x, y, w, h)
  result = b.takePath()
