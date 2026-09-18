# Package

import std/os

version       = "0.1.1"
author        = "George Lemon"
description   = "Bindings to Flutter's 2D vector graphics renderer"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.0"
requires "chroma"

# The standalone libimpeller.dylib ships with a relative install name
# (`./libimpeller.dylib`), so the loader needs help finding it at test
# (and example) run time. Point it at the MacPorts prefix by default;
# override LIBIMPELLER_DIR if you installed it elsewhere.
task test, "Run the test suite (sets library search path for libimpeller)":
  # NOTE: `nim c -r` does not forward DYLD_* to the test binary on macOS,
  # so compile and run in two steps. Use DYLD_FALLBACK_LIBRARY_PATH, NOT
  # DYLD_LIBRARY_PATH: the latter shadows Apple's system libGL with
  # MacPorts' Mesa build and segfaults GLFW window creation.
  let libDir = getEnv("LIBIMPELLER_DIR", "/opt/local/lib")
  for kind, path in walkDir("tests"):
    if kind == pcFile and path.endsWith(".nim") and
        path.extractFilename.startsWith("test"):
      exec "nim c " & path
      let (dir, name, _) = path.splitFile()
      exec "DYLD_FALLBACK_LIBRARY_PATH=" & libDir &
        " LD_LIBRARY_PATH=" & libDir & " " & dir & "/" & name