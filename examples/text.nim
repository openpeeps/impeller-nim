## Text rendering: register a system font, layout paragraphs, draw them.
##
## Build: nim c examples/text.nim
## Run:   DYLD_FALLBACK_LIBRARY_PATH=/opt/local/lib ./examples/text  (macOS)

import chroma
import ./common

const MacFont = "/System/Library/Fonts/Helvetica.ttc"

proc main() =
  let (ok, a) = initApp("impeller text", 800, 400)
  if not ok:
    quit("could not open window / backend context", 1)
  var app = a
  defer: app.shutdown()

  var tctx = newTypographyContext()
  let fontFamily =
    if tctx.registerFontFile(MacFont, "Helvetica"): "Helvetica"
    else: "sans-serif"
  if fontFamily == "sans-serif":
    echo "system font not found, falling back to: ", fontFamily

  let heading = newTextStyle(fontFamily = fontFamily, fontSize = 36,
    fontWeight = kImpellerFontWeight700, color = rgba(234, 234, 234, 255))
  let body = newTextStyle(fontFamily = fontFamily, fontSize = 18,
    color = rgba(0, 255, 204, 255))
  var p1 = tctx.layoutParagraph("Impeller + Nim", heading, 760)
  var p2 = tctx.layoutParagraph(
    "Display lists, paths, gradients, and text, all GPU rendered.",
    body, 760)
  var rich = tctx.layoutRichParagraph([
    (text: "Bold ", style: newTextStyle(fontFamily = fontFamily,
      fontSize = 18, fontWeight = kImpellerFontWeight700,
      color = rgba(233, 69, 96, 255))),
    (text: "and regular, one paragraph.", style: body),
  ], 760)
  defer:
    ImpellerParagraphRelease(p1.handle)
    ImpellerParagraphRelease(p2.handle)
    ImpellerParagraphRelease(rich.handle)
    tctx.release()

  while not app.shouldClose():
    let (fok, b, s, fw, fh) = app.beginFrame()
    if not fok:
      continue
    var builder = b
    var surf = s
    withPaint(bg):
      bg.setColor("#16213e")
      builder.drawPaint(bg)
    drawParagraph(builder.handle, p1, 20, 20)
    drawParagraph(builder.handle, p2, 20, 20 + p1.getHeight() + 12)
    drawParagraph(builder.handle, rich, 20,
      20 + p1.getHeight() + 12 + p2.getHeight() + 12)
    if not app.endFrame(builder, surf):
      echo "frame failed"

main()
