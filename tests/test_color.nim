import unittest
import chroma
import helpers

suite "color conversion":
  test "0-255 bytes normalize to 0.0-1.0":
    let c = toImpellerColor(rgba(255, 0, 0, 255))
    check abs(c.red - 1.0) < 1e-6
    check abs(c.green - 0.0) < 1e-6
    check abs(c.blue - 0.0) < 1e-6
    check abs(c.alpha - 1.0) < 1e-6
    check c.color_space == kImpellerColorSpaceSRGB

  test "mid values scale correctly":
    let c = toImpellerColor(rgba(0, 128, 255, 255))
    check abs(c.green - 128.0 / 255.0) < 1e-6
    check abs(c.blue - 1.0) < 1e-6

  test "half alpha":
    let c = toImpellerColor(rgba(255, 255, 255, 128))
    check abs(c.alpha - 128.0 / 255.0) < 1e-6

  test "paint setColor from hex string does not raise (needs lib)":
    requiresLib()
    var p = newPaint()
    check not p.isNil
    p.setColor("#ff8800")
    p.setColor(rgba(1, 2, 3, 4))
    var raw = ImpellerColor(red: 0, green: 1, blue: 0, alpha: 1,
      color_space: kImpellerColorSpaceSRGB)
    p.setColor(raw)
    p.setBlendMode(kImpellerBlendModeSourceOver)
    p.setDrawStyle(kImpellerDrawStyleFill)
    p.setStrokeCap(kImpellerStrokeCapRound)
    p.setStrokeJoin(kImpellerStrokeJoinRound)
    p.setStrokeWidth(2.5)
    p.setStrokeMiter(4.0)
