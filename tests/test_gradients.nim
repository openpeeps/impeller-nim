import unittest
import chroma
import helpers

suite "gradients":
  test "initGradientPoint parses hex + position":
    let g = initGradientPoint("#ff0000", 0.0)
    check g.position == 0.0
    check abs(g.impellerColor.red - 1.0) < 1e-6

  test "initGradientPointAlpha overrides alpha":
    let g = initGradientPointAlpha("#00ff00", 128, 0.5)
    check g.position == 0.5
    check abs(g.impellerColor.alpha - 128.0 / 255.0) < 1e-6

  test "addGradientPoint appends stops":
    var grad = initLinearGradient(@[])
    grad.addGradientPoint(rgba(255, 0, 0, 255), 0.0)
    grad.addGradientPoint("#0000ff", 1.0)
    check grad.colors.len == 2
    check grad.colors[1].position == 1.0

  test "initLinearGradient stores geometry":
    var grad = initLinearGradient(
      @[initGradientPoint("#000000", 0.0),
        initGradientPoint("#ffffff", 1.0)],
      width = 200, height = 100)
    check grad.width == 200
    check grad.height == 100
    check grad.colors.len == 2

  test "colorsource rejects fewer than 2 stops":
    requiresLib()
    var cols = @[ImpellerColor(red: 1, green: 0, blue: 0, alpha: 1,
      color_space: kImpellerColorSpaceSRGB)]
    var stops = @[0.0.cfloat]
    expect AssertionDefect:
      discard linearGradient(
        ImpellerPoint(x: 0, y: 0), ImpellerPoint(x: 100, y: 0),
        cols, stops)

  test "linear + radial gradients create handles (needs lib)":
    requiresLib()
    let cols = @[
      ImpellerColor(red: 1, green: 0, blue: 0, alpha: 1,
        color_space: kImpellerColorSpaceSRGB),
      ImpellerColor(red: 0, green: 0, blue: 1, alpha: 1,
        color_space: kImpellerColorSpaceSRGB)]
    let stops = @[0.0.cfloat, 1.0.cfloat]
    var src = linearGradient(
      ImpellerPoint(x: 0, y: 0), ImpellerPoint(x: 100, y: 0),
      cols, stops)
    check not src.isNil
    var rad = radialGradient(ImpellerPoint(x: 50, y: 50), 50, cols, stops)
    check not rad.isNil
