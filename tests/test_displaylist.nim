## Context-free Impeller tests: display lists, paths, paints, filters.
## Everything here runs on the CPU with no GPU, window, or GL context.

import unittest
import chroma
import helpers

suite "display list builder":
  test "new builder, save counts, finish":
    requiresLib()
    var b = newDisplayListBuilder(0, 0, 200, 100)
    check not b.isNil
    let n = b.getSaveCount()
    b.save()
    check b.getSaveCount() == n + 1
    b.restore()
    check b.getSaveCount() == n
    let dl = b.finish()
    check not dl.isNil

  test "withSave restores the count":
    requiresLib()
    var b = newDisplayListBuilder(0, 0, 64, 64)
    let n = b.getSaveCount()
    withSave(b):
      b.translate(3, 4)
      check b.getSaveCount() == n + 1
    check b.getSaveCount() == n

  test "transform round-trips through set/get":
    requiresLib()
    var b = newDisplayListBuilder(0, 0, 64, 64)
    var m = translationMatrix(5, 7)
    b.setTransform(m)
    let got = b.getTransform()
    check abs(got.m[12] - 5) < 1e-6
    check abs(got.m[13] - 7) < 1e-6
    b.resetTransform()
    let id = b.getTransform()
    check abs(id.m[0] - 1) < 1e-6
    check abs(id.m[12]) < 1e-6

  test "draw shapes, clip, and nested display lists":
    requiresLib()
    var b = newDisplayListBuilder(0, 0, 200, 200)
    withPaint(bg):
      bg.setColor("#1a1a2e")
      b.drawPaint(bg)
    withPaint(p):
      p.setColor("#00ff00")
      var r = newRectangle(180, 180, 10, 10)
      b.drawRect(r, p)
      b.drawLine(0, 0, 200, 200, p)
      var oval = ImpellerRect(x: 50, y: 50, width: 100, height: 60)
      b.drawOval(oval, p)
      var radii = uniformRadii(8)
      b.drawRoundedRect(r, radii, p)
      b.clipRect(r)
      b.clipOval(oval)
    # Nested display list.
    var inner = newDisplayListBuilder(0, 0, 40, 40)
    withPaint(q):
      q.setColor("#ff0000")
      var r2 = newRectangle(40, 40)
      inner.drawRect(r2, q)
    let nested = inner.finish()
    b.drawDisplayList(nested, 0.5)
    let dl = b.finish()
    check not dl.isNil

  test "saveLayer + shadow record without a context":
    requiresLib()
    var b = newDisplayListBuilder(0, 0, 100, 100)
    var tri = buildRect(10, 10, 80, 80)
    withPaint(p):
      p.setColor("#00ffcc")
      var bounds = tri.getBounds()
      var imf = blurImageFilter(2.0, 2.0)
      check not imf.isNil
      b.saveLayer(bounds, p, imf.handle)
      b.drawPath(tri, p)
      var shadowCol = ImpellerColor(red: 0, green: 0, blue: 0,
        alpha: 0.5, color_space: kImpellerColorSpaceSRGB)
      b.drawShadow(tri, shadowCol, elevation = 4.0)
      b.restore()
    let dl = b.finish()
    check not dl.isNil

suite "paths":
  test "triangle path has positive bounds":
    requiresLib()
    var pb = newPathBuilder()
    pb.moveTo(10, 10)
    pb.lineTo(90, 10)
    pb.lineTo(50, 90)
    pb.close()
    var t = pb.takePath()
    check not t.isNil
    let b = t.getBounds()
    check b.width > 0 and b.height > 0

  test "curves, ovals, and copyPath":
    requiresLib()
    var pb = newPathBuilder()
    pb.moveTo(0, 0)
    pb.quadraticTo(10, 20, 30, 0)
    pb.cubicTo(40, 10, 50, 10, 60, 0)
    var cp = pb.copyPath()
    check not cp.isNil
    pb.addOval(0, 0, 10, 10)
    var taken = pb.takePath(kImpellerFillTypeOdd)
    check not taken.isNil
    var circ = buildCircle(50, 50, 20)
    check circ.getBounds().width > 0

suite "filters and color sources":
  test "color, mask, and image filters construct":
    requiresLib()
    var red = ImpellerColor(red: 1, green: 0, blue: 0, alpha: 1,
      color_space: kImpellerColorSpaceSRGB)
    var bf = blendColorFilter(red, kImpellerBlendModeMultiply)
    check not bf.isNil
    var cm = grayscaleColorMatrix()
    var gcf = colorMatrixFilter(cm)
    check not gcf.isNil
    var mf = blurMaskFilter(kImpellerBlurStyleNormal, 2.0)
    check not mf.isNil
    var imf = blurImageFilter(2.0, 3.0)
    check not imf.isNil
    var dil = dilateImageFilter(1.0, 1.0)
    check not dil.isNil
    var ero = erodeImageFilter(1.0, 1.0)
    check not ero.isNil
    var m = scaleMatrix(2.0, 2.0)
    var mat = matrixImageFilter(m)
    check not mat.isNil
    # Identity is a no-op: Impeller returns nil by design.
    var id = identityMatrix()
    var matId = matrixImageFilter(id)
    check matId.isNil
    var comp = composeImageFilter(imf, ero)
    check not comp.isNil

  test "conical and sweep gradients construct":
    requiresLib()
    let cols = @[
      ImpellerColor(red: 1, green: 0, blue: 0, alpha: 1,
        color_space: kImpellerColorSpaceSRGB),
      ImpellerColor(red: 0, green: 0, blue: 1, alpha: 1,
        color_space: kImpellerColorSpaceSRGB)]
    let stops = @[0.0.cfloat, 1.0.cfloat]
    var con = conicalGradient(ImpellerPoint(x: 10, y: 10), 5,
      ImpellerPoint(x: 50, y: 50), 40, cols, stops)
    check not con.isNil
    var sw = sweepGradient(ImpellerPoint(x: 50, y: 50), 0, 360,
      cols, stops)
    check not sw.isNil

suite "paragraph in display list":
  test "layout paragraph and record draw into builder":
    requiresLib()
    var tctx = newTypographyContext()
    var para = tctx.layoutParagraph("CPU-only rendering",
      newTextStyle(fontSize = 20), 400)
    check para.handle != nil
    check para.getLongestLineWidth() >= 0
    check para.getMinIntrinsicWidth() >= 0
    check para.getMaxIntrinsicWidth() >= 0
    var b = newDisplayListBuilder(0, 0, 400, 100)
    drawParagraph(b.handle, para, 4, 4)
    let dl = b.finish()
    check not dl.isNil
    let (w0, w1) = para.getWordBoundary(0)
    check w1 >= w0
    ImpellerParagraphRelease(para.handle)
    tctx.release()
