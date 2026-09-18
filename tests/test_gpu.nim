## GPU integration test: real rendering through the platform backend.
## macOS uses Metal (CAMetalLayer on a GLFW window, no GL context —
## upstream `example_mtl.m` recipe); other platforms use OpenGL ES with
## GLFW as the proc-address loader (upstream `example_gl.c` recipe).
## Skips gracefully when no display / GPU is available.

import unittest
import chroma
import helpers
import impeller/bindings/glfw3_api

const
  ClientApiHint = 0x00022001 # GLFW_CLIENT_API
  NoApi = 0                  # GLFW_NO_API

suite "gpu rendering":
  test "window, context, draw, present, close":
    if glfwInit() == 0:
      skip()
    var win: ptr GLFWwindow = nil
    var ctxH: ImpellerContext = nil
    var layer: pointer = nil
    try:
      when defined(macosx):
        glfwWindowHint(ClientApiHint, NoApi)
      win = glfwCreateWindow(128, 128, "impeller-gpu-test", nil, nil)
      if win == nil:
        glfwTerminate()
        skip()
      when defined(macosx):
        ctxH = ImpellerContextCreateMetalNew(ImpellerVersion)
        if ctxH == nil:
          skip()
        layer = setupMetalLayerForWindow(win)
        if layer == nil:
          skip()
      else:
        glfwMakeContextCurrent(win)
        ctxH = ImpellerContextCreateOpenGLESNew(
          ImpellerVersion, glfwProcLoader, nil)
        if ctxH == nil:
          skip()
      var ctx = Context(handle: ctxH)

      var fw, fh: cint
      glfwGetFramebufferSize(win, addr fw, addr fh)
      if fw <= 0 or fh <= 0:
        skip()

      var surf: Surface
      when defined(macosx):
        metalSetDrawableSize(layer, fw.float64, fh.float64)
        let drawable = metalNextDrawable(layer)
        if drawable == nil:
          skip()
        surf = wrapMetalDrawable(ctx.handle, drawable)
      else:
        surf = wrapFBO(ctx.handle, 0, kImpellerPixelFormatRGBA8888,
          fw.int64, fh.int64)
      check not surf.isNil

      var builder = newDisplayListBuilder(0, 0, fw.float32, fh.float32)
      withPaint(bg):
        bg.setColor("#1a1a2e")
        builder.drawPaint(bg)
      var rect = newRectangle(fw.float32 - 20, fh.float32 - 20, 10, 10)
      drawRect(builder.handle, rect, rgba(0, 255, 0, 255))
      drawLine(builder.handle, 0, 0, fw.float32, fh.float32,
        rgba(255, 255, 255, 255), 2.0)
      drawOval(builder.handle, fw.float32 / 2, fh.float32 / 2, 20, 12,
        rgba(255, 0, 0, 255))
      var grad = initLinearGradient(
        @[initGradientPoint("#ff0000", 0.0),
          initGradientPoint("#0000ff", 1.0)],
        width = fw.float32, height = 24)
      drawGradient(builder.handle, grad)

      let dl = builder.finish()
      check not dl.isNil
      check surf.render(dl)
      when not defined(macosx):
        glfwSwapBuffers(win)
      glfwPollEvents()
    finally:
      if win != nil:
        glfwDestroyWindow(win)
      glfwTerminate()
