# Nim bindings for the Impeller graphics library - High-level Context API
#
# (c) 2026 George Lemon | MIT License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/impeller-nim

import ./bindings/impeller_api
import ./bindings/glfw3_api

## High-level wrapper around `ImpellerContext`.
## Contexts are expensive, thread-safe (except OpenGL: bound to the
## creating thread), share one per application lifetime.
##
## Software rendering: use the OpenGL backend with Mesa/llvmpipe (or the
## system GL on macOS). Create a hidden GLFW window, make its GL context
## current, then wrap an FBO as a surface. No Metal/Vulkan device needed,
## which makes this path ideal for headless tests and most examples.

type
  Context* = object
    ## RAII wrapper around `ImpellerContext`.
    handle*: ImpellerContext

proc `=destroy`*(c: Context) =
  if c.handle != nil:
    ImpellerContextRelease(c.handle)

proc `=copy`*(dst: var Context, src: Context) {.error: "Context cannot be copied, share by pointer instead".}

proc isNil*(c: Context): bool {.inline.} =
  c.handle == nil

proc getVersion*(): uint32 {.inline.} =
  ## Returns the Impeller standalone API version of the linked library.
  ImpellerGetVersion()

proc createOpenGLES*(glProcAddress: ImpellerProcAddressCallback,
    userData: pointer = nil,
    version: uint32 = ImpellerVersion): Context =
  ## Creates an OpenGL(ES) context. `glProcAddress` resolves GL symbols
  ## (e.g. `eglGetProcAddress` or `glfwGetProcAddress`). Must be called on
  ## the thread that owns the GL context.
  Context(handle: ImpellerContextCreateOpenGLESNew(
    version, glProcAddress, userData))

proc createMetal*(version: uint32 = ImpellerVersion): Context =
  ## Creates a Metal context using the system default device (macOS/iOS).
  Context(handle: ImpellerContextCreateMetalNew(version))

proc createVulkan*(settings: var ImpellerContextVulkanSettings,
    version: uint32 = ImpellerVersion): Context =
  Context(handle: ImpellerContextCreateVulkanNew(
    version, addr settings))

proc getVulkanInfo*(c: Context, info: var ImpellerContextVulkanInfo): bool =
  ImpellerContextGetVulkanInfo(c.handle, addr info)

# -- GLFW helpers for software / headless rendering -----------------------

proc glfwProcLoader*(procName: cstring, userData: pointer): pointer {.cdecl.} =
  ## Adapter turning `glfwGetProcAddress` into an
  ## `ImpellerProcAddressCallback`. Pass directly to `createOpenGLES`.
  cast[pointer](glfwGetProcAddress(procName))

proc createOpenGLESWithGlfw*(version: uint32 = ImpellerVersion): Context =
  ## Convenience: creates an OpenGL ES context using GLFW as the GL
  ## proc-address loader. A current GLFW GL context must exist on this
  ## thread (visible or hidden window). Works with software GL
  ## (llvmpipe) for headless rendering.
  createOpenGLES(glfwProcLoader, nil, version)

template withContext*(name: untyped, ctx: Context, body: untyped) =
  ## Runs `body` with `name` bound to an existing context. No ownership
  ## transfer; context is NOT released.
  block:
    let name {.inject.} = unsafeAddr ctx
    body
