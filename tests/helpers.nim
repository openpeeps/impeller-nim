## Shared helpers for the impeller test suite.
##
## Two tiers, both headless-safe:
## - Pure unit tests run everywhere (no native library calls).
## - CPU integration tests call the real libimpeller C API for objects
##   that need no GPU context: display-list builders, paths, paints,
##   gradients, filters, typography, and paragraphs. They skip gracefully
##   when libimpeller cannot be loaded.
## - The GPU test uses Metal on macOS (CAMetalLayer on a GLFW window,
##   upstream `example_mtl.m` recipe) and OpenGL ES elsewhere. The small
##   amount of ObjC plumbing it needs lives here, at test level, so the
##   `impeller` package itself stays free of platform GUI code.

import impeller

export impeller

proc libAvailable*(): bool =
  ## True when libimpeller is linked and answers a version query.
  try:
    discard ImpellerGetVersion()
    true
  except CatchableError:
    false

template requiresLib*() =
  ## Skip the enclosing test when libimpeller cannot be reached.
  if not libAvailable():
    skip()

when defined(macosx):
  # Declared without a header on purpose: including <GLFW/glfw3native.h>
  # requires <GLFW/glfw3.h> first (GLFWAPI macro), which Nim does not
  # guarantee in every generated C file. The symbol lives in libglfw.
  proc glfwGetCocoaWindow(win: pointer): pointer {.importc.}

  {.emit: """
  #include <objc/message.h>
  #include <objc/runtime.h>
  #include <CoreGraphics/CoreGraphics.h>

   void* test_objc_msgSend_noargs(void* obj, void* sel) {
    return ((void*(*)(void*, void*))objc_msgSend)(obj, sel);
  }
   void* test_objc_msgSend_ptr(void* obj, void* sel, void* arg) {
    return ((void*(*)(void*, void*, void*))objc_msgSend)(obj, sel, arg);
  }
   void test_objc_msgSend_bool(void* obj, void* sel, _Bool arg) {
    ((void(*)(void*, void*, _Bool))objc_msgSend)(obj, sel, arg);
  }
   void test_objc_msgSend_ulong(void* obj, void* sel, unsigned long arg) {
    ((void(*)(void*, void*, unsigned long))objc_msgSend)(obj, sel, arg);
  }
   void test_set_drawable_size_wh(void* layer, void* selSetDrawableSize, double w, double h) {
    CGSize s;
    s.width = w;
    s.height = h;
    ((void(*)(void*, void*, CGSize))objc_msgSend)(layer, selSetDrawableSize, s);
  }
  """.}

  proc test_msgSend_noargs(obj: pointer, sel: pointer): pointer {.importc: "test_objc_msgSend_noargs".}
  proc test_msgSend_ptr(obj: pointer, sel: pointer, arg: pointer): pointer {.importc: "test_objc_msgSend_ptr".}
  proc test_msgSend_bool(obj: pointer, sel: pointer, arg: bool) {.importc: "test_objc_msgSend_bool".}
  proc test_msgSend_ulong(obj: pointer, sel: pointer, arg: culong) {.importc: "test_objc_msgSend_ulong".}
  proc test_set_drawable_size(layer: pointer, sel: pointer, w: cdouble, h: cdouble) {.importc: "test_set_drawable_size_wh".}

  proc test_objc_getClass(name: cstring): pointer {.importc: "objc_getClass", header: "<objc/runtime.h>".}
  proc test_sel(name: cstring): pointer {.importc: "sel_registerName", header: "<objc/runtime.h>".}

  # No header on purpose: avoids parsing Objective-C headers in C mode.
  proc test_systemDefaultDevice(): pointer {.importc: "MTLCreateSystemDefaultDevice".}

  proc setupMetalLayerForWindow*(glfwWin: pointer): pointer =
    ## Attaches a CAMetalLayer (BGRA8Unorm, non-framebuffer-only) to the
    ## GLFW window's content view. Returns the layer, or nil on failure.
    let cocoaWindow = glfwGetCocoaWindow(glfwWin)
    if cocoaWindow == nil:
      return nil
    let contentView = test_msgSend_noargs(cocoaWindow, test_sel("contentView"))
    if contentView == nil:
      return nil
    let layerClass = test_objc_getClass("CAMetalLayer")
    if layerClass == nil:
      return nil
    let layer = test_msgSend_noargs(layerClass, test_sel("layer"))
    if layer == nil:
      return nil
    let device = test_systemDefaultDevice()
    if device == nil:
      return nil
    discard test_msgSend_ptr(layer, test_sel("setDevice:"), device)
    test_msgSend_bool(layer, test_sel("setFramebufferOnly:"), false)
    test_msgSend_ulong(layer, test_sel("setPixelFormat:"), 80.culong)
    test_msgSend_bool(contentView, test_sel("setWantsLayer:"), true)
    discard test_msgSend_ptr(contentView, test_sel("setLayer:"), layer)
    layer

  proc metalSetDrawableSize*(layer: pointer, w, h: float64) =
    test_set_drawable_size(layer, test_sel("setDrawableSize:"),
      w.cdouble, h.cdouble)

  proc metalNextDrawable*(layer: pointer): pointer {.inline.} =
    test_msgSend_noargs(layer, test_sel("nextDrawable"))
