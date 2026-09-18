switch("path", "$projectDir/../src")

# switch("passC", "-I/opt/local/include -Wno-incompatible-function-pointer-types")

# when fileExists("/opt/local/include/GLFW/glfw3.h"):
#   when defined(macosx):
#     switch("passL", "-L/opt/local/lib -lglfw -Wl,-rpath,/opt/local/lib -fobjc-arc -framework Cocoa -framework Metal -framework QuartzCore -framework AppKit")
#   else:
#     switch("passL", "-L/opt/local/lib -lglfw -Wl,-rpath,/opt/local/lib")
# else:
#   switch("passC", "-Wno-incompatible-function-pointer-types")
#   switch("passL", "-lglfw")
#   when defined(macosx):
#     switch("passL", "-limpeller -fobjc-arc -framework Cocoa -framework Metal -framework QuartzCore -framework AppKit")

--passL:"-L /opt/local/lib -lglfw -limpeller -framework Metal -framework AppKit -framework QuartzCore"
--passC:"-I /opt/local/include"