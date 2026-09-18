# High-level DisplayList + transform/clip/draw API
import ./bindings/impeller_api
import ./paint
import ./path

export paint, path

type
  DisplayList* = object
    handle*: ImpellerDisplayList
  DisplayListBuilder* = object
    handle*: ImpellerDisplayListBuilder

proc `=destroy`*(d: DisplayList) =
  if d.handle != nil: ImpellerDisplayListRelease(d.handle)
proc `=copy`*(dst: var DisplayList, src: DisplayList) {.error: "DisplayList cannot be copied, use retain()".}
proc `=destroy`*(b: DisplayListBuilder) =
  if b.handle != nil: ImpellerDisplayListBuilderRelease(b.handle)
proc `=copy`*(dst: var DisplayListBuilder, src: DisplayListBuilder) {.error: "DisplayListBuilder cannot be copied".}

proc isNil*(d: DisplayList): bool {.inline.} = d.handle == nil
proc isNil*(b: DisplayListBuilder): bool {.inline.} = b.handle == nil

proc retain*(d: DisplayList): DisplayList =
  ImpellerDisplayListRetain(d.handle)
  DisplayList(handle: d.handle)

proc newDisplayListBuilder*(cullRect: var ImpellerRect): DisplayListBuilder =
  DisplayListBuilder(handle: ImpellerDisplayListBuilderNew(addr cullRect))

proc newDisplayListBuilder*(x, y, w, h: float32): DisplayListBuilder =
  var r = ImpellerRect(x: x.cfloat, y: y.cfloat, width: w.cfloat, height: h.cfloat)
  DisplayListBuilder(handle: ImpellerDisplayListBuilderNew(addr r))

proc finish*(b: DisplayListBuilder): DisplayList =
  DisplayList(handle: ImpellerDisplayListBuilderCreateDisplayListNew(b.handle))

# -- matrix helpers (column-major 4x4) ------------------------------------

proc identityMatrix*(): ImpellerMatrix =
  for i in 0 ..< 16:
    result.m[i] = if i mod 5 == 0: 1.0 else: 0.0

proc translationMatrix*(x, y: float32): ImpellerMatrix =
  result = identityMatrix()
  result.m[12] = x
  result.m[13] = y

proc scaleMatrix*(sx, sy: float32): ImpellerMatrix =
  result = identityMatrix()
  result.m[0] = sx
  result.m[5] = sy

# -- transform stack -------------------------------------------------------

proc save*(b: DisplayListBuilder) {.inline.} =
  ImpellerDisplayListBuilderSave(b.handle)

proc saveLayer*(b: DisplayListBuilder, bounds: var ImpellerRect,
    p: Paint, backdrop: ImpellerImageFilter = nil) =
  ImpellerDisplayListBuilderSaveLayer(b.handle, addr bounds, p.handle, backdrop)

proc restore*(b: DisplayListBuilder) {.inline.} =
  ImpellerDisplayListBuilderRestore(b.handle)

proc scale*(b: DisplayListBuilder, sx, sy: float32) {.inline.} =
  ImpellerDisplayListBuilderScale(b.handle, sx.cfloat, sy.cfloat)

proc rotate*(b: DisplayListBuilder, degrees: float32) {.inline.} =
  ImpellerDisplayListBuilderRotate(b.handle, degrees.cfloat)

proc translate*(b: DisplayListBuilder, dx, dy: float32) {.inline.} =
  ImpellerDisplayListBuilderTranslate(b.handle, dx.cfloat, dy.cfloat)

proc transform*(b: DisplayListBuilder, m: var ImpellerMatrix) {.inline.} =
  ImpellerDisplayListBuilderTransform(b.handle, addr m)

proc setTransform*(b: DisplayListBuilder, m: var ImpellerMatrix) {.inline.} =
  ImpellerDisplayListBuilderSetTransform(b.handle, addr m)

proc getTransform*(b: DisplayListBuilder): ImpellerMatrix =
  ImpellerDisplayListBuilderGetTransform(b.handle, addr result)

proc resetTransform*(b: DisplayListBuilder) {.inline.} =
  ImpellerDisplayListBuilderResetTransform(b.handle)

proc getSaveCount*(b: DisplayListBuilder): uint32 {.inline.} =
  ImpellerDisplayListBuilderGetSaveCount(b.handle)

proc restoreToCount*(b: DisplayListBuilder, count: uint32) {.inline.} =
  ImpellerDisplayListBuilderRestoreToCount(b.handle, count)

template withSave*(b: DisplayListBuilder, body: untyped) =
  b.save()
  try: body
  finally: b.restore()

# -- clipping --------------------------------------------------------------

proc clipRect*(b: DisplayListBuilder, r: var ImpellerRect,
    op: ImpellerClipOperation = kImpellerClipOperationIntersect) {.inline.} =
  ImpellerDisplayListBuilderClipRect(b.handle, addr r, op)

proc clipOval*(b: DisplayListBuilder, oval: var ImpellerRect,
    op: ImpellerClipOperation = kImpellerClipOperationIntersect) {.inline.} =
  ImpellerDisplayListBuilderClipOval(b.handle, addr oval, op)

proc clipRoundedRect*(b: DisplayListBuilder, r: var ImpellerRect,
    radii: var ImpellerRoundingRadii,
    op: ImpellerClipOperation = kImpellerClipOperationIntersect) {.inline.} =
  ImpellerDisplayListBuilderClipRoundedRect(b.handle, addr r, addr radii, op)

proc clipPath*(b: DisplayListBuilder, p: Path,
    op: ImpellerClipOperation = kImpellerClipOperationIntersect) {.inline.} =
  ImpellerDisplayListBuilderClipPath(b.handle, p.handle, op)

# -- drawing ---------------------------------------------------------------

proc drawPaint*(b: DisplayListBuilder, p: Paint) {.inline.} =
  ImpellerDisplayListBuilderDrawPaint(b.handle, p.handle)

proc drawLine*(b: DisplayListBuilder, x0, y0, x1, y1: float32, p: Paint) =
  var a = ImpellerPoint(x: x0.cfloat, y: y0.cfloat)
  var c = ImpellerPoint(x: x1.cfloat, y: y1.cfloat)
  ImpellerDisplayListBuilderDrawLine(b.handle, addr a, addr c, p.handle)

proc drawDashedLine*(b: DisplayListBuilder, x0, y0, x1, y1, onLen, offLen: float32, p: Paint) =
  var a = ImpellerPoint(x: x0.cfloat, y: y0.cfloat)
  var c = ImpellerPoint(x: x1.cfloat, y: y1.cfloat)
  ImpellerDisplayListBuilderDrawDashedLine(b.handle, addr a, addr c,
    onLen.cfloat, offLen.cfloat, p.handle)

proc drawRect*(b: DisplayListBuilder, r: var ImpellerRect, p: Paint) {.inline.} =
  ImpellerDisplayListBuilderDrawRect(b.handle, addr r, p.handle)

proc drawOval*(b: DisplayListBuilder, oval: var ImpellerRect, p: Paint) {.inline.} =
  ImpellerDisplayListBuilderDrawOval(b.handle, addr oval, p.handle)

proc drawRoundedRect*(b: DisplayListBuilder, r: var ImpellerRect,
    radii: var ImpellerRoundingRadii, p: Paint) {.inline.} =
  ImpellerDisplayListBuilderDrawRoundedRect(b.handle, addr r, addr radii, p.handle)

proc drawRoundedRectDifference*(b: DisplayListBuilder, outer: var ImpellerRect,
    outerRadii: var ImpellerRoundingRadii, inner: var ImpellerRect,
    innerRadii: var ImpellerRoundingRadii, p: Paint) {.inline.} =
  ImpellerDisplayListBuilderDrawRoundedRectDifference(b.handle, addr outer,
    addr outerRadii, addr inner, addr innerRadii, p.handle)

proc drawPath*(b: DisplayListBuilder, p: Path, paint: Paint) {.inline.} =
  ImpellerDisplayListBuilderDrawPath(b.handle, p.handle, paint.handle)

proc drawDisplayList*(b: DisplayListBuilder, d: DisplayList, opacity: float32 = 1.0) {.inline.} =
  ImpellerDisplayListBuilderDrawDisplayList(b.handle, d.handle, opacity.cfloat)

proc drawShadow*(b: DisplayListBuilder, p: Path, color: var ImpellerColor,
    elevation: float32, occluderTransparent: bool = false,
    devicePixelRatio: float32 = 1.0) {.inline.} =
  ImpellerDisplayListBuilderDrawShadow(b.handle, p.handle, addr color,
    elevation.cfloat, occluderTransparent, devicePixelRatio.cfloat)

proc drawTexture*(b: DisplayListBuilder, tex: ImpellerTexture, x, y: float32,
    sampling: ImpellerTextureSampling = kImpellerTextureSamplingLinear,
    p: Paint = Paint(handle: nil)) =
  var pt = ImpellerPoint(x: x.cfloat, y: y.cfloat)
  let ph = if p.handle == nil: nil else: p.handle
  ImpellerDisplayListBuilderDrawTexture(b.handle, tex, addr pt, sampling, ph)

proc drawTextureRect*(b: DisplayListBuilder, tex: ImpellerTexture,
    src: var ImpellerRect, dst: var ImpellerRect,
    sampling: ImpellerTextureSampling = kImpellerTextureSamplingLinear,
    p: Paint = Paint(handle: nil)) =
  let ph = if p.handle == nil: nil else: p.handle
  ImpellerDisplayListBuilderDrawTextureRect(b.handle, tex, addr src, addr dst,
    sampling, ph)
