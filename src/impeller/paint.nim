# Nim bindings for the Impeller graphics library - High-level Paint API
#
# (c) 2026 George Lemon | MIT License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/impeller-nim

import pkg/chroma
import ./bindings/impeller_api

## High-level wrapper around `ImpellerPaint`.
## Paints control how draw calls encoded in a display list are rendered.

type
  Paint* = object
    ## RAII wrapper around `ImpellerPaint`. Released automatically.
    handle*: ImpellerPaint

proc `=destroy`*(p: Paint) =
  if p.handle != nil:
    ImpellerPaintRelease(p.handle)

proc `=copy`*(dst: var Paint, src: Paint) {.error: "Paint cannot be copied, use retain()".}

proc newPaint*(): Paint =
  ## Creates a new paint with default values.
  Paint(handle: ImpellerPaintNew())

proc retain*(p: Paint): Paint =
  ## Retains the paint and returns a new owner. Caller must let it go out
  ## of scope (or `=destroy` runs automatically).
  ImpellerPaintRetain(p.handle)
  Paint(handle: p.handle)

proc isNil*(p: Paint): bool {.inline.} =
  p.handle == nil

# -- color ---------------------------------------------------------------

proc toImpellerColor*(c: ColorRGBA): ImpellerColor {.inline.} =
  ImpellerColor(
    red: if c.r > 1: c.r.float32 / 255 else: c.r.float32,
    green: if c.g > 1: c.g.float32 / 255 else: c.g.float32,
    blue: if c.b > 1: c.b.float32 / 255 else: c.b.float32,
    alpha: if c.a > 1: c.a.float32 / 255 else: c.a.float32,
    color_space: kImpellerColorSpaceSRGB
  )

proc setColor*(p: Paint, color: ImpellerColor) =
  ImpellerPaintSetColor(p.handle, unsafeAddr color)

proc setColor*(p: Paint, color: ColorRGBA) =
  var c = toImpellerColor(color)
  ImpellerPaintSetColor(p.handle, addr c)

proc setColor*(p: Paint, color: string) =
  ## Hex / HTML color string, e.g. "#ff0000".
  setColor(p, parseHtmlColor(color).asRgba)

proc setColor*(p: Paint, r, g, b: range[0..255], a: range[0..255] = 255) =
  setColor(p, rgba(r.uint8, g.uint8, b.uint8, a.uint8))

# -- style ---------------------------------------------------------------

proc setBlendMode*(p: Paint, mode: ImpellerBlendMode) {.inline.} =
  ImpellerPaintSetBlendMode(p.handle, mode)

proc setDrawStyle*(p: Paint, style: ImpellerDrawStyle) {.inline.} =
  ImpellerPaintSetDrawStyle(p.handle, style)

proc setStrokeCap*(p: Paint, cap: ImpellerStrokeCap) {.inline.} =
  ImpellerPaintSetStrokeCap(p.handle, cap)

proc setStrokeJoin*(p: Paint, join: ImpellerStrokeJoin) {.inline.} =
  ImpellerPaintSetStrokeJoin(p.handle, join)

proc setStrokeWidth*(p: Paint, width: float32) {.inline.} =
  ImpellerPaintSetStrokeWidth(p.handle, width.cfloat)

proc setStrokeMiter*(p: Paint, miter: float32) {.inline.} =
  ImpellerPaintSetStrokeMiter(p.handle, miter.cfloat)

# -- filters / sources ---------------------------------------------------

proc setColorFilter*(p: Paint, filter: ImpellerColorFilter) {.inline.} =
  ImpellerPaintSetColorFilter(p.handle, filter)

proc setColorSource*(p: Paint, source: ImpellerColorSource) {.inline.} =
  ImpellerPaintSetColorSource(p.handle, source)

proc setImageFilter*(p: Paint, filter: ImpellerImageFilter) {.inline.} =
  ImpellerPaintSetImageFilter(p.handle, filter)

proc setMaskFilter*(p: Paint, filter: ImpellerMaskFilter) {.inline.} =
  ImpellerPaintSetMaskFilter(p.handle, filter)

template withPaint*(name: untyped, body: untyped) =
  ## Creates a `Paint` bound to `name`, runs `body`, releases afterwards.
  ## (`=destroy` also releases, this is for explicit scopes.)
  block:
    var name = newPaint()
    defer:
      if name.handle != nil:
        ImpellerPaintRelease(name.handle)
        name.handle = nil
    body
