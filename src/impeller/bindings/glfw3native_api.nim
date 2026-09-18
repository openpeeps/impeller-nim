{.passC: "-DGLFW_EXPOSE_NATIVE_COCOA -DDGLFW_EXPOSE_NATIVE_COCOA".}

type
  GLFWwindow* = pointer
  GLFWmonitor* = pointer

  # These are Objective-C id types (pointer)
  NSWindow* = pointer
  NSView* = pointer

{.push, importc, header: "<GLFW/glfw3native.h>".}
proc glfwGetCocoaWindow*(window: GLFWwindow): NSWindow
proc glfwGetCocoaView*(window: GLFWwindow): NSView
proc glfwGetCocoaMonitor*(monitor: GLFWmonitor): uint32
{.pop.}
