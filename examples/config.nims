switch("path", "$projectDir/../src")
# App-level link settings for examples. libimpeller itself comes from the
# `impeller` package (passL -limpeller); here we add the include path,
# GLFW, and — on macOS — the frameworks the Metal path needs.
#
# At RUNTIME the loader must find libimpeller.dylib: use
# DYLD_FALLBACK_LIBRARY_PATH (macOS) or LD_LIBRARY_PATH (Linux).
# Do NOT use DYLD_LIBRARY_PATH=/opt/local/lib on macOS: it shadows
# Apple's system libGL with MacPorts' Mesa build and crashes GLFW.
when fileExists("/opt/local/include/GLFW/glfw3.h"):
  switch("passC", "-I/opt/local/include -Wno-incompatible-function-pointer-types")
  when defined(macosx):
    switch("passL", "-L/opt/local/lib -lglfw -Wl,-rpath,/opt/local/lib -fobjc-arc -framework Cocoa -framework Metal -framework QuartzCore -framework AppKit")
  else:
    switch("passL", "-L/opt/local/lib -lglfw -Wl,-rpath,/opt/local/lib")
else:
  switch("passC", "-Wno-incompatible-function-pointer-types")
  switch("passL", "-lglfw")
  when defined(macosx):
    switch("passL", "-fobjc-arc -framework Cocoa -framework Metal -framework QuartzCore -framework AppKit")
