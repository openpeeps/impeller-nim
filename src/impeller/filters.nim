# High-level ColorFilter / ImageFilter / MaskFilter API
import ./bindings/impeller_api
import ./texture

export texture

type
  ColorFilter* = object
    handle*: ImpellerColorFilter
  ImageFilter* = object
    handle*: ImpellerImageFilter
  MaskFilter* = object
    handle*: ImpellerMaskFilter

proc `=destroy`*(f: ColorFilter) =
  if f.handle != nil: ImpellerColorFilterRelease(f.handle)
proc `=copy`*(dst: var ColorFilter, src: ColorFilter) {.error: "ColorFilter cannot be copied".}
proc `=destroy`*(f: ImageFilter) =
  if f.handle != nil: ImpellerImageFilterRelease(f.handle)
proc `=copy`*(dst: var ImageFilter, src: ImageFilter) {.error: "ImageFilter cannot be copied".}
proc `=destroy`*(f: MaskFilter) =
  if f.handle != nil: ImpellerMaskFilterRelease(f.handle)
proc `=copy`*(dst: var MaskFilter, src: MaskFilter) {.error: "MaskFilter cannot be copied".}

proc isNil*(f: ColorFilter): bool {.inline.} = f.handle == nil
proc isNil*(f: ImageFilter): bool {.inline.} = f.handle == nil
proc isNil*(f: MaskFilter): bool {.inline.} = f.handle == nil

# -- color filters ---------------------------------------------------------

proc blendColorFilter*(color: var ImpellerColor,
    mode: ImpellerBlendMode): ColorFilter =
  ColorFilter(handle: ImpellerColorFilterCreateBlendNew(addr color, mode))

proc colorMatrixFilter*(m: var ImpellerColorMatrix): ColorFilter =
  ColorFilter(handle: ImpellerColorFilterCreateColorMatrixNew(addr m))

proc grayscaleColorMatrix*(): ImpellerColorMatrix =
  ImpellerColorMatrix(m: [
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.0, 0.0, 0.0, 1, 0,
  ])

proc invertColorMatrix*(): ImpellerColorMatrix =
  ImpellerColorMatrix(m: [
    -1.0, 0, 0, 0, 255,
    0, -1.0, 0, 0, 255,
    0, 0, -1.0, 0, 255,
    0, 0, 0, 1, 0,
  ])

# -- mask filters ----------------------------------------------------------

proc blurMaskFilter*(style: ImpellerBlurStyle, sigma: float32): MaskFilter =
  MaskFilter(handle: ImpellerMaskFilterCreateBlurNew(style, sigma.cfloat))

# -- image filters ---------------------------------------------------------

proc blurImageFilter*(sx, sy: float32,
    tile: ImpellerTileMode = kImpellerTileModeClamp): ImageFilter =
  ImageFilter(handle: ImpellerImageFilterCreateBlurNew(
    sx.cfloat, sy.cfloat, tile))

proc dilateImageFilter*(rx, ry: float32): ImageFilter =
  ImageFilter(handle: ImpellerImageFilterCreateDilateNew(rx.cfloat, ry.cfloat))

proc erodeImageFilter*(rx, ry: float32): ImageFilter =
  ImageFilter(handle: ImpellerImageFilterCreateErodeNew(rx.cfloat, ry.cfloat))

proc matrixImageFilter*(m: var ImpellerMatrix,
    sampling: ImpellerTextureSampling = kImpellerTextureSamplingLinear): ImageFilter =
  ImageFilter(handle: ImpellerImageFilterCreateMatrixNew(addr m, sampling))

proc composeImageFilter*(outer, inner: ImageFilter): ImageFilter =
  ImageFilter(handle: ImpellerImageFilterCreateComposeNew(outer.handle, inner.handle))
