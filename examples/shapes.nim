## Shapes, paths, gradients, transforms, clips, shadows, filters.
##
## Build: nim c examples/shapes.nim
## Run:   DYLD_FALLBACK_LIBRARY_PATH=/opt/local/lib ./examples/shapes  (macOS)

import ./common

proc drawScene(builder: var DisplayListBuilder, w, h: float32) =
  withPaint(bg):
    bg.setColor("#16213e")
    builder.drawPaint(bg)

  # Linear gradient banner.
  var grad = initLinearGradient(
    @[initGradientPoint("#ff9a3c", 0.0),
      initGradientPoint("#e94560", 0.5),
      initGradientPoint("#533483", 1.0)],
    width = w, height = 120)
  drawGradient(builder.handle, grad)

  # Clipped + rotated content.
  builder.withSave:
    var clip = newRectangle(w - 40, h - 180, 20, 160)
    builder.clipRect(clip)
    builder.translate(w / 2, 300)
    builder.rotate(15)
    builder.translate(-w / 2, -300)
    withPaint(p):
      p.setColor("#0f3460")
      var r = newRectangle(300, 120, w / 2 - 150, 240)
      builder.drawRect(r, p)
      var oval = ImpellerRect(x: w / 2 - 200, y: 400, width: 400, height: 120)
      builder.drawOval(oval, p)

  # Triangle path with shadow.
  var pb = newPathBuilder()
  pb.moveTo(60, h - 60)
  pb.lineTo(220, h - 60)
  pb.lineTo(140, h - 200)
  pb.close()
  var tri = pb.takePath()
  withPaint(p):
    p.setColor("#00ffcc")
    var shadowCol = ImpellerColor(red: 0, green: 0, blue: 0, alpha: 0.5,
      color_space: kImpellerColorSpaceSRGB)
    builder.drawShadow(tri, shadowCol, elevation = 4.0)
    builder.drawPath(tri, p)

  # Dashed line + blurred layer on the right.
  withPaint(p):
    p.setColor("#eaeaea")
    p.setStrokeWidth(3.0)
    builder.drawDashedLine(w - 220, h - 60, w - 60, h - 200, 12, 8, p)
  var layerBox = ImpellerRect(x: w - 200, y: 160, width: 140, height: 140)
  withPaint(p):
    p.setColor("#e94560")
    var blur = blurImageFilter(6.0, 6.0)
    builder.saveLayer(layerBox, p, blur.handle)
    var r = newRectangle(100, 100, w - 180, 180)
    builder.drawRect(r, p)
    builder.restore()

proc main() =
  let (ok, a) = initApp("impeller shapes", 900, 650)
  if not ok:
    quit("could not open window / backend context", 1)
  var app = a
  defer: app.shutdown()

  while not app.shouldClose():
    let (fok, b, s, fw, fh) = app.beginFrame()
    if not fok:
      continue
    var builder = b
    var surf = s
    drawScene(builder, fw, fh)
    if not app.endFrame(builder, surf):
      echo "frame failed"

main()
