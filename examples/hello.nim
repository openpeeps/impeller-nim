## Hello window: animated rect on the platform backend.
##
## Build: nim c examples/hello.nim
## Run:   DYLD_FALLBACK_LIBRARY_PATH=/opt/local/lib ./examples/hello  (macOS)
##        LD_LIBRARY_PATH=/opt/local/lib ./examples/hello              (Linux)

import std/math
import chroma
import ./common

proc main() =
  let (ok, a) = initApp("impeller hello", 800, 600)
  if not ok:
    quit("could not open window / backend context", 1)
  var app = a
  defer: app.shutdown()

  var frame = 0
  while not app.shouldClose():
    let (fok, b, s, fw, fh) = app.beginFrame()
    if not fok:
      continue
    var builder = b
    var surf = s
    inc frame

    withPaint(bg):
      bg.setColor("#1a1a2e")
      builder.drawPaint(bg)

    # Rect bouncing horizontally.
    let x = fw / 2 - 100 + cos(frame.float32 * 0.05) * (fw / 2 - 120)
    var rect = newRectangle(200, 200, x, 200)
    drawRect(builder.handle, rect, "#e94560")

    drawOval(builder.handle, fw / 2, 120, 60, 40,
      parseHtmlColor("#0f3460").asRgba)
    drawLine(builder.handle, 0, fh - 40, fw, fh - 40,
      parseHtmlColor("#eaeaea").asRgba, 2.0)

    if not app.endFrame(builder, surf):
      echo "frame failed"

main()
