# High-level Texture + FragmentProgram API
import ./bindings/impeller_api

type
  Texture* = object
    handle*: ImpellerTexture
  FragmentProgram* = object
    handle*: ImpellerFragmentProgram

proc `=destroy`*(t: Texture) =
  if t.handle != nil: ImpellerTextureRelease(t.handle)
proc `=copy`*(dst: var Texture, src: Texture) {.error: "Texture cannot be copied, use retain()".}
proc `=destroy`*(f: FragmentProgram) =
  if f.handle != nil: ImpellerFragmentProgramRelease(f.handle)
proc `=copy`*(dst: var FragmentProgram, src: FragmentProgram) {.error: "FragmentProgram cannot be copied".}

proc isNil*(t: Texture): bool {.inline.} = t.handle == nil
proc isNil*(f: FragmentProgram): bool {.inline.} = f.handle == nil

proc retain*(t: Texture): Texture =
  ImpellerTextureRetain(t.handle)
  Texture(handle: t.handle)

proc newTextureWithContents*(ctx: ImpellerContext, w, h: int64,
    pixels: openArray[uint8],
    format: ImpellerPixelFormat = kImpellerPixelFormatRGBA8888,
    mipCount: uint32 = 1): Texture =
  ## Uploads RGBA8 bytes to the GPU. `pixels.len` must be >= w*h*4.
  ## The bytes are copied synchronously into the call; safe with `openArray`.
  var desc = ImpellerTextureDescriptor(
    pixel_format: format,
    size: ImpellerISize(width: w, height: h),
    mip_count: mipCount)
  var mapping = ImpellerMapping(
    data: cast[ptr uint8](unsafeAddr pixels[0]),
    length: uint64(pixels.len),
    on_release: nil)
  Texture(handle: ImpellerTextureCreateWithContentsNew(
    ctx, addr desc, addr mapping, nil))

proc newTextureFromGLHandle*(ctx: ImpellerContext, glHandle: uint64,
    w, h: int64,
    format: ImpellerPixelFormat = kImpellerPixelFormatRGBA8888): Texture =
  var desc = ImpellerTextureDescriptor(
    pixel_format: format,
    size: ImpellerISize(width: w, height: h),
    mip_count: 1)
  Texture(handle: ImpellerTextureCreateWithOpenGLTextureHandleNew(
    ctx, addr desc, glHandle))

proc glHandle*(t: Texture): uint64 {.inline.} =
  ImpellerTextureGetOpenGLHandle(t.handle)

proc solidTexture*(ctx: ImpellerContext, r, g, b, a: uint8,
    w: int64 = 1, h: int64 = 1): Texture =
  ## Convenience 1x1 (or WxH) solid texture, useful for tests without
  ## image files.
  var px = newSeq[uint8](w * h * 4)
  for i in 0 ..< w * h:
    px[i * 4 + 0] = r
    px[i * 4 + 1] = g
    px[i * 4 + 2] = b
    px[i * 4 + 3] = a
  newTextureWithContents(ctx, w, h, px)

# -- fragment programs (compiled with impellerc) ---------------------------

proc newFragmentProgram*(spirv: openArray[byte]): FragmentProgram =
  var mapping = ImpellerMapping(
    data: cast[ptr uint8](unsafeAddr spirv[0]),
    length: uint64(spirv.len),
    on_release: nil)
  FragmentProgram(handle: ImpellerFragmentProgramNew(addr mapping, nil))

proc loadFragmentProgram*(path: string): FragmentProgram =
  let bytes = readFile(path)
  var mapping = ImpellerMapping(
    data: cast[ptr uint8](unsafeAddr bytes[0]),
    length: uint64(bytes.len),
    on_release: nil)
  FragmentProgram(handle: ImpellerFragmentProgramNew(addr mapping, nil))
