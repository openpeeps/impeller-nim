const
  GLFW_TRUE* = 1
  GLFW_FALSE* = 0
  GLFW_RELEASE* = 0
  GLFW_PRESS* = 1
  GLFW_REPEAT* = 2

  GLFW_KEY_UNKNOWN* = -1
  GLFW_KEY_SPACE* = 32
  GLFW_KEY_APOSTROPHE* = 39
  GLFW_KEY_COMMA* = 44
  GLFW_KEY_MINUS* = 45
  GLFW_KEY_PERIOD* = 46
  GLFW_KEY_SLASH* = 47
  GLFW_KEY_0* = 48
  GLFW_KEY_1* = 49
  GLFW_KEY_2* = 50
  GLFW_KEY_3* = 51
  GLFW_KEY_4* = 52
  GLFW_KEY_5* = 53
  GLFW_KEY_6* = 54
  GLFW_KEY_7* = 55
  GLFW_KEY_8* = 56
  GLFW_KEY_9* = 57
  GLFW_KEY_SEMICOLON* = 59
  GLFW_KEY_EQUAL* = 61
  GLFW_KEY_A* = 65
  GLFW_KEY_B* = 66
  GLFW_KEY_C* = 67
  GLFW_KEY_D* = 68
  GLFW_KEY_E* = 69
  GLFW_KEY_F* = 70
  GLFW_KEY_G* = 71
  GLFW_KEY_H* = 72
  GLFW_KEY_I* = 73
  GLFW_KEY_J* = 74
  GLFW_KEY_K* = 75
  GLFW_KEY_L* = 76
  GLFW_KEY_M* = 77
  GLFW_KEY_N* = 78
  GLFW_KEY_O* = 79
  GLFW_KEY_P* = 80
  GLFW_KEY_Q* = 81
  GLFW_KEY_R* = 82
  GLFW_KEY_S* = 83
  GLFW_KEY_T* = 84
  GLFW_KEY_U* = 85
  GLFW_KEY_V* = 86
  GLFW_KEY_W* = 87
  GLFW_KEY_X* = 88
  GLFW_KEY_Y* = 89
  GLFW_KEY_Z* = 90
  GLFW_KEY_ESCAPE* = 256
  GLFW_KEY_ENTER* = 257
  GLFW_KEY_TAB* = 258
  GLFW_KEY_BACKSPACE* = 259
  GLFW_KEY_INSERT* = 260
  GLFW_KEY_DELETE* = 261
  GLFW_KEY_RIGHT* = 262
  GLFW_KEY_LEFT* = 263
  GLFW_KEY_DOWN* = 264
  GLFW_KEY_UP* = 265

{.push, importc, header: "GLFW/glfw3.h".}

type
  GLFWmonitor* {.byCopy, incompleteStruct.} = object
  GLFWwindow* {.byCopy, incompleteStruct.} = object
  GLFWcursor* {.byCopy, incompleteStruct.} = object

  GLFWvidmode* {.byCopy.} = object
    width*: cint
    height*: cint
    redBits*: cint
    greenBits*: cint
    blueBits*: cint
    refreshRate*: cint

  GLFWgammaramp* {.byCopy.} = object
    red*: ptr uint16
    green*: ptr uint16
    blue*: ptr uint16
    size*: uint32

  GLFWimage* {.byCopy.} = object
    width*: cint
    height*: cint
    pixels*: ptr uint8

  GLFWgamepadstate* {.byCopy.} = object
    buttons*: array[15, uint8]
    axes*: array[6, cfloat]

  GLFWallocator* {.byCopy.} = object
    allocate*: pointer
    reallocate*: pointer
    deallocate*: pointer
    user*: pointer

proc glfwInit*(): cint
proc glfwTerminate*()
proc glfwInitHint*(hint, value: cint)
proc glfwInitAllocator*(allocator: ptr GLFWallocator)
proc glfwInitVulkanLoader*(loader: pointer) # PFN_vkGetInstanceProcAddr, use pointer for simplicity
proc glfwGetVersion*(major, minor, rev: ptr cint)
proc glfwGetVersionString*(): cstring
proc glfwGetError*(description: ptr cstring): cint

type GLFWerrorfun* = proc(code: cint, description: cstring) {.cdecl.}
proc glfwSetErrorCallback*(callback: GLFWerrorfun): GLFWerrorfun

proc glfwGetPlatform*(): cint
proc glfwPlatformSupported*(platform: cint): cint

proc glfwGetMonitors*(count: ptr cint): ptr ptr GLFWmonitor
proc glfwGetPrimaryMonitor*(): ptr GLFWmonitor
proc glfwGetMonitorPos*(monitor: ptr GLFWmonitor, xpos, ypos: ptr cint)
proc glfwGetMonitorWorkarea*(monitor: ptr GLFWmonitor, xpos, ypos, width, height: ptr cint)
proc glfwGetMonitorPhysicalSize*(monitor: ptr GLFWmonitor, widthMM, heightMM: ptr cint)
proc glfwGetMonitorContentScale*(monitor: ptr GLFWmonitor, xscale, yscale: ptr cfloat)
proc glfwGetMonitorName*(monitor: ptr GLFWmonitor): cstring
proc glfwSetMonitorUserPointer*(monitor: ptr GLFWmonitor, pointer: pointer)
proc glfwGetMonitorUserPointer*(monitor: ptr GLFWmonitor): pointer

type GLFWmonitorfun* = proc(monitor: ptr GLFWmonitor, event: cint) {.cdecl.}
proc glfwSetMonitorCallback*(callback: GLFWmonitorfun): GLFWmonitorfun

proc glfwGetVideoModes*(monitor: ptr GLFWmonitor, count: ptr cint): ptr GLFWvidmode
proc glfwGetVideoMode*(monitor: ptr GLFWmonitor): ptr GLFWvidmode
proc glfwSetGamma*(monitor: ptr GLFWmonitor, gamma: cfloat)
proc glfwGetGammaRamp*(monitor: ptr GLFWmonitor): ptr GLFWgammaramp
proc glfwSetGammaRamp*(monitor: ptr GLFWmonitor, ramp: ptr GLFWgammaramp)

proc glfwDefaultWindowHints*()
proc glfwWindowHint*(hint, value: cint)
proc glfwWindowHintString*(hint: cint, value: cstring)
proc glfwSetWindowIcon*(window: ptr GLFWwindow, count: cint, images: ptr GLFWimage)
proc glfwGetWindowPos*(window: ptr GLFWwindow, xpos, ypos: ptr cint)
proc glfwSetWindowPos*(window: ptr GLFWwindow, xpos, ypos: cint)
proc glfwGetWindowTitle*(window: ptr GLFWwindow): cstring

proc glfwCreateWindow*(width, height: cint, title: cstring, monitor: ptr GLFWmonitor, share: ptr GLFWwindow): ptr GLFWwindow
proc glfwDestroyWindow*(window: ptr GLFWwindow)
proc glfwWindowShouldClose*(window: ptr GLFWwindow): cint
proc glfwSetWindowShouldClose*(window: ptr GLFWwindow, value: cint)
proc glfwPollEvents*()
proc glfwWaitEvents*()
proc glfwSwapBuffers*(window: ptr GLFWwindow)
proc glfwMakeContextCurrent*(window: ptr GLFWwindow)
proc glfwGetCurrentContext*(): ptr GLFWwindow
proc glfwSwapInterval*(interval: cint)
proc glfwGetKey*(window: ptr GLFWwindow, key: cint): cint
proc glfwGetMouseButton*(window: ptr GLFWwindow, button: cint): cint
proc glfwGetCursorPos*(window: ptr GLFWwindow, xpos, ypos: ptr cdouble)
proc glfwSetCursorPos*(window: ptr GLFWwindow, xpos, ypos: cdouble)
proc glfwSetWindowTitle*(window: ptr GLFWwindow, title: cstring)
proc glfwSetWindowSize*(window: ptr GLFWwindow, width, height: cint)
proc glfwGetWindowSize*(window: ptr GLFWwindow, width, height: ptr cint)

proc glfwSetWindowSizeLimits*(window: ptr GLFWwindow, minwidth, minheight, maxwidth, maxheight: cint)
proc glfwSetWindowAspectRatio*(window: ptr GLFWwindow, numer, denom: cint)
proc glfwGetFramebufferSize*(window: ptr GLFWwindow, width, height: ptr cint)
proc glfwGetWindowFrameSize*(window: ptr GLFWwindow, left, top, right, bottom: ptr cint)
proc glfwGetWindowContentScale*(window: ptr GLFWwindow, xscale, yscale: ptr cfloat)
proc glfwGetWindowOpacity*(window: ptr GLFWwindow): cfloat
proc glfwSetWindowOpacity*(window: ptr GLFWwindow, opacity: cfloat)
proc glfwIconifyWindow*(window: ptr GLFWwindow)
proc glfwRestoreWindow*(window: ptr GLFWwindow)
proc glfwMaximizeWindow*(window: ptr GLFWwindow)
proc glfwShowWindow*(window: ptr GLFWwindow)
proc glfwHideWindow*(window: ptr GLFWwindow)
proc glfwFocusWindow*(window: ptr GLFWwindow)
proc glfwRequestWindowAttention*(window: ptr GLFWwindow)
proc glfwGetWindowMonitor*(window: ptr GLFWwindow): ptr GLFWmonitor
proc glfwSetWindowMonitor*(window: ptr GLFWwindow, monitor: ptr GLFWmonitor, xpos, ypos, width, height, refreshRate: cint)
proc glfwGetWindowAttrib*(window: ptr GLFWwindow, attrib: cint): cint
proc glfwSetWindowAttrib*(window: ptr GLFWwindow, attrib, value: cint)
proc glfwSetWindowUserPointer*(window: ptr GLFWwindow, pointer: pointer)
proc glfwGetWindowUserPointer*(window: ptr GLFWwindow): pointer

# Callback types
type
  GLFWwindowposfun* = proc(window: ptr GLFWwindow, xpos, ypos: cint) {.cdecl.}
  GLFWwindowsizefun* = proc(window: ptr GLFWwindow, width, height: cint) {.cdecl.}
  GLFWwindowclosefun* = proc(window: ptr GLFWwindow) {.cdecl.}
  GLFWwindowrefreshfun* = proc(window: ptr GLFWwindow) {.cdecl.}
  GLFWwindowfocusfun* = proc(window: ptr GLFWwindow, focused: cint) {.cdecl.}
  GLFWwindowiconifyfun* = proc(window: ptr GLFWwindow, iconified: cint) {.cdecl.}
  GLFWwindowmaximizefun* = proc(window: ptr GLFWwindow, maximized: cint) {.cdecl.}
  GLFWframebuffersizefun* = proc(window: ptr GLFWwindow, width, height: cint) {.cdecl.}
  GLFWwindowcontentscalefun* = proc(window: ptr GLFWwindow, xscale, yscale: cfloat) {.cdecl.}

proc glfwSetWindowPosCallback*(window: ptr GLFWwindow, callback: GLFWwindowposfun): GLFWwindowposfun
proc glfwSetWindowSizeCallback*(window: ptr GLFWwindow, callback: GLFWwindowsizefun): GLFWwindowsizefun
proc glfwSetWindowCloseCallback*(window: ptr GLFWwindow, callback: GLFWwindowclosefun): GLFWwindowclosefun
proc glfwSetWindowRefreshCallback*(window: ptr GLFWwindow, callback: GLFWwindowrefreshfun): GLFWwindowrefreshfun
proc glfwSetWindowFocusCallback*(window: ptr GLFWwindow, callback: GLFWwindowfocusfun): GLFWwindowfocusfun
proc glfwSetWindowIconifyCallback*(window: ptr GLFWwindow, callback: GLFWwindowiconifyfun): GLFWwindowiconifyfun
proc glfwSetWindowMaximizeCallback*(window: ptr GLFWwindow, callback: GLFWwindowmaximizefun): GLFWwindowmaximizefun
proc glfwSetFramebufferSizeCallback*(window: ptr GLFWwindow, callback: GLFWframebuffersizefun): GLFWframebuffersizefun
proc glfwSetWindowContentScaleCallback*(window: ptr GLFWwindow, callback: GLFWwindowcontentscalefun): GLFWwindowcontentscalefun

proc glfwWaitEventsTimeout*(timeout: cdouble)
proc glfwPostEmptyEvent*()
proc glfwGetInputMode*(window: ptr GLFWwindow, mode: cint): cint
proc glfwSetInputMode*(window: ptr GLFWwindow, mode, value: cint)
proc glfwRawMouseMotionSupported*(): cint
proc glfwGetKeyName*(key, scancode: cint): cstring
proc glfwGetKeyScancode*(key: cint): cint

proc glfwCreateCursor*(image: ptr GLFWimage, xhot, yhot: cint): ptr GLFWcursor
proc glfwCreateStandardCursor*(shape: cint): ptr GLFWcursor
proc glfwDestroyCursor*(cursor: ptr GLFWcursor)
proc glfwSetCursor*(window: ptr GLFWwindow, cursor: ptr GLFWcursor)

# Callback types for input
type
  GLFWkeyfun* = proc(window: ptr GLFWwindow, key, scancode, action, mods: cint) {.cdecl.}
  GLFWcharfun* = proc(window: ptr GLFWwindow, codepoint: uint32) {.cdecl.}
  GLFWcharmodsfun* = proc(window: ptr GLFWwindow, codepoint: uint32, mods: cint) {.cdecl.}
  GLFWmousebuttonfun* = proc(window: ptr GLFWwindow, button, action, mods: cint) {.cdecl.}
  GLFWcursorposfun* = proc(window: ptr GLFWwindow, xpos, ypos: cdouble) {.cdecl.}
  GLFWcursorenterfun* = proc(window: ptr GLFWwindow, entered: cint) {.cdecl.}
  GLFWscrollfun* = proc(window: ptr GLFWwindow, xoffset, yoffset: cdouble) {.cdecl.}
  GLFWdropfun* = proc(window: ptr GLFWwindow, count: cint, paths: ptr cstring) {.cdecl.}

proc glfwSetKeyCallback*(window: ptr GLFWwindow, callback: GLFWkeyfun): GLFWkeyfun
proc glfwSetCharCallback*(window: ptr GLFWwindow, callback: GLFWcharfun): GLFWcharfun
proc glfwSetCharModsCallback*(window: ptr GLFWwindow, callback: GLFWcharmodsfun): GLFWcharmodsfun
proc glfwSetMouseButtonCallback*(window: ptr GLFWwindow, callback: GLFWmousebuttonfun): GLFWmousebuttonfun
proc glfwSetCursorPosCallback*(window: ptr GLFWwindow, callback: GLFWcursorposfun): GLFWcursorposfun
proc glfwSetCursorEnterCallback*(window: ptr GLFWwindow, callback: GLFWcursorenterfun): GLFWcursorenterfun
proc glfwSetScrollCallback*(window: ptr GLFWwindow, callback: GLFWscrollfun): GLFWscrollfun
proc glfwSetDropCallback*(window: ptr GLFWwindow, callback: GLFWdropfun): GLFWdropfun

proc glfwJoystickPresent*(jid: cint): cint
proc glfwGetJoystickAxes*(jid: cint, count: ptr cint): ptr cfloat
proc glfwGetJoystickButtons*(jid: cint, count: ptr cint): ptr uint8
proc glfwGetJoystickHats*(jid: cint, count: ptr cint): ptr uint8
proc glfwGetJoystickName*(jid: cint): cstring
proc glfwGetJoystickGUID*(jid: cint): cstring
proc glfwSetJoystickUserPointer*(jid: cint, pointer: pointer)
proc glfwGetJoystickUserPointer*(jid: cint): pointer
proc glfwJoystickIsGamepad*(jid: cint): cint

type
  GLFWjoystickfun* = proc(jid: cint, event: cint) {.cdecl.}

proc glfwSetJoystickCallback*(callback: GLFWjoystickfun): GLFWjoystickfun
proc glfwUpdateGamepadMappings*(str: cstring): cint
proc glfwGetGamepadName*(jid: cint): cstring
proc glfwGetGamepadState*(jid: cint, state: ptr GLFWgamepadstate): cint

proc glfwSetClipboardString*(window: ptr GLFWwindow, str: cstring)
proc glfwGetClipboardString*(window: ptr GLFWwindow): cstring

proc glfwGetTime*(): cdouble
proc glfwSetTime*(time: cdouble)
proc glfwGetTimerValue*(): uint64
proc glfwGetTimerFrequency*(): uint64

proc glfwExtensionSupported*(extension: cstring): cint
type GLFWglproc* = pointer
proc glfwGetProcAddress*(procname: cstring): GLFWglproc

proc glfwVulkanSupported*(): cint
proc glfwGetRequiredInstanceExtensions*(count: ptr uint32): ptr cstring

{.pop.}