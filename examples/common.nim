## Shared scaffold for the examples (app-level code, not the library).
##
## Opens a GLFW window and an Impeller backend context:
## - macOS: GLFW_NO_API window + CAMetalLayer + Metal context
##   (upstream `example_mtl.m` recipe).
## - Elsewhere: OpenGL window + OpenGL ES context (upstream
##   `example_gl.c` recipe).
##
## Each frame: `beginFrame` gives a display-list builder, record drawing,
## then `endFrame` presents it.

import impeller
import impeller/bindings/glfw3_api

export impeller
export glfw3_api

const
  ClientApiHint = 0x00022001 # GLFW_CLIENT_API
  NoApi = 0                  # GLFW_NO_API

when defined(macosx):
  {.emit: """
  #include <objc/message.h>
  #include <objc/runtime.h>
  #include <CoreGraphics/CoreGraphics.h>

  void* ex_objc_msgSend_noargs(void* obj, void* sel) {
    return ((void*(*)(void*, void*))objc_msgSend)(obj, sel);
  }
  void* ex_objc_msgSend_ptr(void* obj, void* sel, void* arg) {
    return ((void*(*)(void*, void*, void*))objc_msgSend)(obj, sel, arg);
  }
  void ex_objc_msgSend_bool(void* obj, void* sel, _Bool arg) {
    ((void(*)(void*, void*, _Bool))objc_msgSend)(obj, sel, arg);
  }
  void ex_objc_msgSend_ulong(void* obj, void* sel, unsigned long arg) {
    ((void(*)(void*, void*, unsigned long))objc_msgSend)(obj, sel, arg);
  }
  void ex_set_drawable_size_wh(void* layer, void* selSetDrawableSize, double w, double h) {
    CGSize s;
    s.width = w;
    s.height = h;
    ((void(*)(void*, void*, CGSize))objc_msgSend)(layer, selSetDrawableSize, s);
  }
  """.}

  proc ex_msgSend_noargs(obj: pointer, sel: pointer): pointer {.importc: "ex_objc_msgSend_noargs".}
  proc ex_msgSend_ptr(obj: pointer, sel: pointer, arg: pointer): pointer {.importc: "ex_objc_msgSend_ptr".}
  proc ex_msgSend_bool(obj: pointer, sel: pointer, arg: bool) {.importc: "ex_objc_msgSend_bool".}
  proc ex_msgSend_ulong(obj: pointer, sel: pointer, arg: culong) {.importc: "ex_objc_msgSend_ulong".}
  proc ex_set_drawable_size(layer: pointer, sel: pointer, w: cdouble, h: cdouble) {.importc: "ex_set_drawable_size_wh".}
  proc ex_objc_getClass(name: cstring): pointer {.importc: "objc_getClass", header: "<objc/runtime.h>".}
  proc ex_sel(name: cstring): pointer {.importc: "sel_registerName", header: "<objc/runtime.h>".}
  proc ex_systemDefaultDevice(): pointer {.importc: "MTLCreateSystemDefaultDevice".}
  # No header: avoids parsing Objective-C headers in C mode.
  proc ex_getCocoaWindow(win: pointer): pointer {.importc: "glfwGetCocoaWindow".}

  proc setupLayer(cocoaWindow: pointer): pointer =
    let contentView = ex_msgSend_noargs(cocoaWindow, ex_sel("contentView"))
    if contentView == nil:
      return nil
    let layerClass = ex_objc_getClass("CAMetalLayer")
    if layerClass == nil:
      return nil
    let layer = ex_msgSend_noargs(layerClass, ex_sel("layer"))
    if layer == nil:
      return nil
    let device = ex_systemDefaultDevice()
    if device == nil:
      return nil
    discard ex_msgSend_ptr(layer, ex_sel("setDevice:"), device)
    ex_msgSend_bool(layer, ex_sel("setFramebufferOnly:"), false)
    ex_msgSend_ulong(layer, ex_sel("setPixelFormat:"), 80.culong)
    ex_msgSend_bool(contentView, ex_sel("setWantsLayer:"), true)
    discard ex_msgSend_ptr(contentView, ex_sel("setLayer:"), layer)
    layer

type
  App* = object
    win*: pointer
    ctx*: Context
    layer*: pointer ## CAMetalLayer on macOS, nil elsewhere.

proc initApp*(title: string, w, h: int32): tuple[ok: bool, app: App] =
  ## Opens a window and backend context. ok=false (no raise) on failure.
  var app = App()
  if glfwInit() == 0:
    return (false, app)
  when defined(macosx):
    glfwWindowHint(ClientApiHint, NoApi)
  app.win = glfwCreateWindow(w, h, title.cstring, nil, nil)
  if app.win == nil:
    glfwTerminate()
    return (false, app)
  when defined(macosx):
    app.ctx = Context(handle: ImpellerContextCreateMetalNew(ImpellerVersion))
    if app.ctx.isNil:
      glfwDestroyWindow(cast[ptr GLFWwindow](app.win))
      glfwTerminate()
      return (false, app)
    app.layer = setupLayer(ex_getCocoaWindow(app.win))
    if app.layer == nil:
      glfwDestroyWindow(cast[ptr GLFWwindow](app.win))
      glfwTerminate()
      return (false, app)
  else:
    glfwMakeContextCurrent(cast[ptr GLFWwindow](app.win))
    app.ctx = createOpenGLESWithGlfw()
    if app.ctx.isNil:
      glfwDestroyWindow(cast[ptr GLFWwindow](app.win))
      glfwTerminate()
      return (false, app)
  (true, app)

proc beginFrame*(app: var App): tuple[ok: bool,
    builder: DisplayListBuilder, surf: Surface, w, h: float32] =
  ## Acquires a drawable surface plus a fresh builder for one frame.
  var fw, fh: cint
  glfwGetFramebufferSize(cast[ptr GLFWwindow](app.win), addr fw, addr fh)
  if fw <= 0 or fh <= 0:
    return (false, DisplayListBuilder(), Surface(), 0, 0)
  when defined(macosx):
    ex_set_drawable_size(app.layer, ex_sel("setDrawableSize:"),
      fw.cdouble, fh.cdouble)
    let drawable = ex_msgSend_noargs(app.layer, ex_sel("nextDrawable"))
    if drawable == nil:
      return (false, DisplayListBuilder(), Surface(), 0, 0)
    let surf = wrapMetalDrawable(app.ctx.handle, drawable)
    if surf.isNil:
      return (false, DisplayListBuilder(), Surface(), 0, 0)
  else:
    let surf = wrapFBO(app.ctx.handle, 0, kImpellerPixelFormatRGBA8888,
      fw.int64, fh.int64)
    if surf.isNil:
      return (false, DisplayListBuilder(), Surface(), 0, 0)
  let builder = newDisplayListBuilder(0, 0, fw.float32, fh.float32)
  (true, builder, surf, fw.float32, fh.float32)

proc endFrame*(app: var App, builder: var DisplayListBuilder,
    surf: var Surface): bool =
  ## Finishes, draws, presents, and pumps events.
  let dl = builder.finish()
  result = surf.render(dl)
  when not defined(macosx):
    glfwSwapBuffers(cast[ptr GLFWwindow](app.win))
  glfwPollEvents()

proc shouldClose*(app: App): bool {.inline.} =
  glfwWindowShouldClose(cast[ptr GLFWwindow](app.win)) != 0

proc shutdown*(app: var App) =
  if app.win != nil:
    glfwDestroyWindow(cast[ptr GLFWwindow](app.win))
    app.win = nil
  glfwTerminate()
