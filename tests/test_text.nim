import unittest
import std/options
import chroma
import helpers

suite "text styles":
  test "newTextStyle defaults":
    let s = newTextStyle()
    check s.fontFamily == "sans-serif"
    check s.fontSize == 14
    check s.fontWeight == kImpellerFontWeight400
    check s.fontStyle == kImpellerFontStyleNormal
    check s.direction == kImpellerTextDirectionLTR
    check s.background.isNone
    check s.decoration.isNone

  test "custom style keeps values":
    let s = newTextStyle(fontFamily = "Roboto", fontSize = 24,
      fontWeight = kImpellerFontWeight700, color = rgba(255, 0, 0, 255),
      align = kImpellerTextAlignmentCenter)
    check s.fontFamily == "Roboto"
    check s.fontSize == 24
    check s.align == kImpellerTextAlignmentCenter

  test "registerFont rejects empty data (no lib needed)":
    var ctx = TypographyContext(handle: nil)
    check not registerFont(ctx, [], "Empty") # empty -> false, no crash

  test "typography context + layout round-trip (needs lib)":
    requiresLib()
    var ctx = newTypographyContext()
    check ctx.handle != nil
    let style = newTextStyle(fontSize = 16)
    var p = ctx.layoutParagraph("Hello, Impeller!", style, 400)
    check p.handle != nil
    check p.getWidth() >= 0
    check p.getHeight() >= 0
    check p.getLineCount() >= 0
    p.release()
    check p.handle == nil
    ctx.release()

  test "rich paragraph with two spans (needs lib)":
    requiresLib()
    var ctx = newTypographyContext()
    let spans = @[
      (text: "Hello, ", style: newTextStyle(fontSize = 16)),
      (text: "world!", style: newTextStyle(fontSize = 16,
        fontWeight = kImpellerFontWeight700)),
    ]
    var p = ctx.layoutRichParagraph(spans, 400)
    check p.handle != nil
    p.release()
    ctx.release()
