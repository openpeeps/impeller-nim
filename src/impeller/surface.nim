# High-level Surface + Vulkan swapchain API
import ./bindings/impeller_api
import ./displaylist

export displaylist

type
  Surface* = object
    handle*: ImpellerSurface
  VulkanSwapchain* = object
    handle*: ImpellerVulkanSwapchain

proc `=destroy`*(s: Surface) =
  if s.handle != nil: ImpellerSurfaceRelease(s.handle)
proc `=copy`*(dst: var Surface, src: Surface) {.error: "Surface cannot be copied, use retain()".}
proc `=destroy`*(s: VulkanSwapchain) =
  if s.handle != nil: ImpellerVulkanSwapchainRelease(s.handle)
proc `=copy`*(dst: var VulkanSwapchain, src: VulkanSwapchain) {.error: "VulkanSwapchain cannot be copied".}

proc isNil*(s: Surface): bool {.inline.} = s.handle == nil
proc isNil*(s: VulkanSwapchain): bool {.inline.} = s.handle == nil

proc retain*(s: Surface): Surface =
  ImpellerSurfaceRetain(s.handle)
  Surface(handle: s.handle)

proc wrapFBO*(ctx: ImpellerContext, fbo: uint64,
    format: ImpellerPixelFormat, w, h: int64): Surface =
  ## Wraps an existing complete GL framebuffer. Ideal for headless /
  ## software rendering: render to an FBO, then present or read back.
  var size = ImpellerISize(width: w, height: h)
  Surface(handle: ImpellerSurfaceCreateWrappedFBONew(ctx, fbo, format, addr size))

proc wrapMetalDrawable*(ctx: ImpellerContext, drawable: pointer): Surface =
  Surface(handle: ImpellerSurfaceCreateWrappedMetalDrawableNew(ctx, drawable))

proc draw*(s: Surface, d: DisplayList): bool {.inline.} =
  ImpellerSurfaceDrawDisplayList(s.handle, d.handle)

proc present*(s: Surface): bool {.inline.} =
  ImpellerSurfacePresent(s.handle)

proc render*(s: Surface, d: DisplayList): bool =
  ## Draws `d` and presents in one step. Returns false on failure.
  if not ImpellerSurfaceDrawDisplayList(s.handle, d.handle): return false
  ImpellerSurfacePresent(s.handle)

# -- Vulkan swapchain ------------------------------------------------------

proc newVulkanSwapchain*(ctx: ImpellerContext, vkSurface: pointer): VulkanSwapchain =
  VulkanSwapchain(handle: ImpellerVulkanSwapchainCreateNew(ctx, vkSurface))

proc acquireNextSurface*(s: VulkanSwapchain): Surface =
  Surface(handle: ImpellerVulkanSwapchainAcquireNextSurfaceNew(s.handle))
